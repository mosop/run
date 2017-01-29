module Run
  # Represents a set of processes.
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

    # :nodoc:
    getter run_context : Context

    # Returns this context.
    getter context : Context

    @start_mutex = Mutex.new
    @wait_mutex = Mutex.new
    @abort_mutex = Mutex.new

    # :nodoc:
    def initialize
      @context = Context.new
      @run_context = Context.new
    end

    # :nodoc:
    def initialize(@parent, @context, @run_context)
    end

    # Returns all the child processes and groups that directly belong to this group.
    getter children = [] of ProcessLike

    # Returns all the child processes that directly belong to this group.
    getter processes = [] of Process

    # Returns all the child process groups that directly belong to this group.
    getter process_groups = [] of ProcessGroup

    # :nodoc:
    def <<(cg : CommandGroup)
      cg.children.each do |child|
        self << child.new_process(self)
      end
    end

    # :nodoc:
    def <<(process : ProcessLike)
      Run << process
      @children << process
      case process
      when Process
        @processes << process
      when ProcessGroup
        @process_groups << process
      end
    end

    # :nodoc:
    def start
      @start_mutex.synchronize do
        if @context.parallel?
          @children.dup.each do |child|
            child.start
          end
        else
          future do
            @children.dup.each do |child|
              child.wait
            end
          end
        end
      end
    end

    # :nodoc:
    def unstart
      @start_mutex.synchronize do
        @children.dup.each do |child|
          child.unstart
        end
      end
    end

    # Waits for all the child processes and groups to terminate.
    def wait
      @wait_mutex.synchronize do
        children = @children.dup
        if @context.parallel?
          fs = Array(Concurrent::Future(Nil)).new(children.size)
          children.each do |child|
            fs << future do
              child.wait
              nil
            end
          end
          fs.each do |f|
            f.get
          end
        else
          children.each do |child|
            child.wait
          end
        end
      end
    end

    # Aborts all the descendant processes.
    def abort(signal = nil)
      @abort_mutex.synchronize do
        @children.each do |child|
          child.abort signal
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

    # Calls the `#processes` array' s [] method.
    def [](*args)
      @processes[*args]
    end

    # Calls the `#processes` array' s []? method.
    def []?(*args)
      @processes[*args]?
    end
  end
end
