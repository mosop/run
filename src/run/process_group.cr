module Run
  class ProcessGroup
    # Returns this parent group.
    getter? parent : ProcessGroup?

    # Returns this source command group.
    getter source : CommandGroup

    @run_context : Context

    # Returns this context.
    getter context : Context

    # :nodoc:
    getter? started : Bool?

    # :nodoc:
    getter? waited : Bool?

    # :nodoc:
    getter? aborted : Bool?

    @start_channel : Channel(Process | ProcessGroup)
    @wait_channel : Channel(Process | ProcessGroup)
    @abort_channel : Channel(Bool)
    @receive_mutex = Mutex.new
    @abort_mutex = Mutex.new
    @needs_abort : Bool?

    # :nodoc:
    def initialize(@parent, @source, @run_context)
      @context = @run_context.dup.set(parent: source.context)
      @start_channel = Channel(Process | ProcessGroup).new(@source.children.size)
      @wait_channel = Channel(Process | ProcessGroup).new(@source.children.size)
      @abort_channel = Channel(Bool).new(@source.children.size)
    end

    # Returns this parent group.
    def parent : ProcessGroup
      @parent.as(ProcessGroup)
    end

    @futures = [] of Concurrent::Future(Nil)

    # Returns all the child processes and groups that directly belong to this group.
    getter children = [] of (Process | ProcessGroup)
    # :nodoc:
    getter started_children = [] of (Process | ProcessGroup)
    # :nodoc:
    getter unstarted_children = [] of (Process | ProcessGroup)
    # :nodoc:
    getter waiting_children = [] of (Process | ProcessGroup)
    # :nodoc:
    getter terminated_children = [] of (Process | ProcessGroup)
    # :nodoc:
    getter succeeded_children = [] of (Process | ProcessGroup)
    # :nodoc:
    getter unsucceeded_children = [] of (Process | ProcessGroup)
    # :nodoc:
    # getter aborted_children = [] of (Process | ProcessGroup)

    # Returns all the child processes that directly belong to this group.
    getter processes = [] of Process

    # :nodoc:
    def start
      @context.parallel ? run_parallel : run_serial
    end

    # :nodoc:
    def unstart
      @started = false
    end

    # :nodoc:
    def run_serial
      current_dir = Dir.current
      @source.children.each_with_index do |cmd, i|
        cmd.new_process(self, **@run_context.set(current_dir: current_dir).to_args).tap do |process|
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
        cmd.new_process(self, **@run_context.to_args).tap do |process|
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
      @processes << process if process.is_a?(Process)
      f = if @context.parallel
        lazy do
          start_and_wait_process process
          nil
        end
      else
        lazy do
          start_and_wait_process process
          @futures[index + 1].get if @futures.size > index
          nil
        end
      end
      @futures << f
    end

    # :nodoc:
    def start_and_wait_process(process)
      process.unstart if @needs_abort
      if process.start
        @started_children << process
        @waiting_children << process
        @start_channel.send process
        process.wait
        @wait_channel.send process
      else
        @unstarted_children << process
        @start_channel.send process
        @wait_channel.send process
      end
    end

    # Waits for all the child processes and groups to terminate.
    def wait
      _wait true
      abort if @needs_abort
    end

    # :nodoc:
    def wait_without_abort
      _wait false
    end

    def _wait(abort)
      receive_start
      receive_wait abort
    end

    # :nodoc:
    def receive_start
      @receive_mutex.synchronize do
        unless @started
          while (@started_children.size + @unstarted_children.size) < @source.children.size
            process = @start_channel.receive
          end
          @started = true
          @start_channel.close
        end
      end
    end

    # :nodoc:
    def receive_wait(abort)
      @receive_mutex.synchronize do
        unless @waited
          while @waiting_children.size > 0
            process = @wait_channel.receive
            if process.started?
              @waiting_children.delete process
              @terminated_children << process
              if process.success?
                @succeeded_children << process
              else
                @unsucceeded_children << process
              end
              if !process.success? && process.context.aborts_on_error
                @needs_abort = true
              end
            end
            break if @needs_abort && abort
          end
          if @waiting_children.size == 0
            @waited = true
            @wait_channel.close
            @abort_channel.close
          end
        end
      end
    end

    # Aborts all the child processes and groups.
    def abort(signal = nil)
      @abort_mutex.synchronize do
        unless @aborted
          @source.run_callbacks_for_abort(self) do
            @waiting_children.each do |process|
              process.abort signal
            end
            wait_without_abort
            @aborted = true
          end
        end
      end
    end

    # Tests if all the child processes and groups successfully terminated.
    def success?
      wait
      @source.children.size == @succeeded_children.size
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
