module Run
  class ProcessGroup
    # Returns this parent group.
    getter? parent : ProcessGroup?

    # Returns this parent group.
    def parent : ProcessGroup
      @parent.as(ProcessGroup)
    end

    # Tests if this group is the root.
    def root?
      !parent?
    end

    # Returns this root group.
    def root : ProcessGroup
      root? ? self : parent.root
    end

    # Returns this source command group.
    getter source : CommandGroup

    # :nodoc:
    getter run_context : Context

    # Returns this context.
    getter context : Context

    @wait_channel : Channel(Process | ProcessGroup)
    @wait_count : Int32
    @wait_mutex = Mutex.new
    @abort_mutex = Mutex.new

    # :nodoc:
    def initialize(@parent, @source, @run_context)
      @context = @run_context.dup.parent(@source.context)
        .set(name: @source.context.name, parallel: @source.context.self_parallel)
      @wait_channel = Channel(Process | ProcessGroup).new(@source.children.size)
      @wait_count = @source.children.size
    end

    @futures = [] of Concurrent::Future(Nil)

    # Returns all the child processes and groups that directly belong to this group.
    getter children = [] of (Process | ProcessGroup)

    # Returns all the child processes that directly belong to this group.
    getter processes = [] of Process

    # Returns all the child process groups that directly belong to this group.
    getter process_groups = [] of ProcessGroup

    # :nodoc:
    def start
      context.parallel? ? run_parallel : run_sequential
    end

    # :nodoc:
    def unstart
      @started = false
    end

    # :nodoc:
    def run_sequential
      current_dir = Dir.current
      @source.children.each_with_index do |cmd, i|
        cmd.new_process(self, Context.new(current_dir: current_dir)).tap do |process|
          register_process i, process
          current_dir = process.context.chdir
        end
      end
      future do
        @futures[0].get
      end
    end

    # :nodoc:
    def run_parallel
      @source.children.each_with_index do |cmd, i|
        cmd.new_process(self).tap do |process|
          register_process i, process
        end
      end
      @futures.each do |f|
        future do
          f.get
        end
      end
    end

    # :nodoc:
    def register_process(index, process)
      @children << process
      case process
      when Process
        @processes << process
      else
        @process_groups << process
      end
      f = if context.parallel?
        lazy do
          start_and_wait_process process
          nil
        end
      else
        lazy do
          start_and_wait_process process
          @futures[index + 1].get if index < @futures.size
          nil
        end
      end
      @futures << f
    end

    # :nodoc:
    def start_and_wait_process(process)
      process.start
      process.wait
      @wait_channel.send process
    end

    # Waits for all the child processes and groups to terminate.
    def wait
      @wait_mutex.synchronize do
        if @wait_count > 0
          until @wait_count == 0
            @wait_channel.receive
            @wait_count -= 1
          end
          @wait_channel.close
          if children_success?
            success!
          else
            error!
          end
        end
      end
    end

    # :nodoc:
    def success!
      source.run_callbacks_for_group_success(self) do
      end
    end

    # :nodoc:
    def error!
      source.run_callbacks_for_group_error(self) do
      end
    end

    # Aborts all the descendant processes.
    def abort(signal = nil)
      @abort_mutex.synchronize do
        if @wait_count > 0
          @source.run_callbacks_for_group_abort(self) do
            @children.each do |process|
              process.abort signal
            end
          end
        end
      end
    end

    # Tests if all the child processes and groups successfully terminated.
    def success?
      wait
      children_success?
    end

    # :nodoc:
    def children_success?
      children.all?{|i| i.success?}
    end

    # Delegated to [] of the result of `#processes`.
    def [](*args)
      @processes[*args]
    end

    # Delegated to []? of the result of `#processes`.
    def []?(*args)
      @processes[*args]?
    end
  end
end
