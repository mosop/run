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

    @mutex = Mutex.new

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

    # Returns all the single processes that directly belong to this group.
    getter processes = [] of AsProcess

    # Returns all the child command processes that directly belong to this group.
    getter command_processes = [] of CommandProcess

    # Returns all the child process groups that directly belong to this group.
    getter process_groups = [] of ProcessGroup

    # Returns all the child fiber function processes that directly belong to this group.
    getter function_fibers = [] of FunctionFiber

    # Returns all the child process function processes that directly belong to this group.
    getter function_processes = [] of FunctionProcess

    # :nodoc:
    def <<(cg : CommandGroup)
      cg.children.each do |child|
        self << child.new_process(self)
      end
    end

    # :nodoc:
    def <<(process : CommandProcess)
      Run << process
      @mutex.synchronize do
        @children << process
        @processes << process
        @command_processes << process
      end
    end

    # :nodoc:
    def <<(process : FunctionFiber)
      Run << process
      @mutex.synchronize do
        @children << process
        @processes << process
        @function_fibers << process
      end
    end

    # :nodoc:
    def <<(process : FunctionProcess)
      Run << process
      @mutex.synchronize do
        @children << process
        @processes << process
        @function_processes << process
      end
    end

    # :nodoc:
    def <<(process : ProcessGroup)
      Run << process
      @mutex.synchronize do
        @children << process
        @process_groups << process
      end
    end

    # :nodoc:
    def start
      children = @mutex.synchronize do
        @children.dup
      end
      if @context.parallel?
        children.each do |child|
          child.start
        end
      else
        future do
          children.each do |child|
            child.wait
          end
        end
      end
    end

    # :nodoc:
    def unstart
      children = @mutex.synchronize do
        @children.dup
      end
      children.each do |child|
        child.unstart
      end
    end

    # Waits for all the child processes and groups to terminate.
    def wait
      wait {}
    end

    # Waits for all the child processes and groups to terminate.
    #
    # This method yields the terminated processes and groups.
    def wait(&block)
      children = @mutex.synchronize do
        @children.dup
      end
      if @context.parallel?
        fs = Array(Concurrent::Future(ProcessLike)).new(children.size)
        children.each do |child|
          fs << future do
            child.wait
            child
          end
        end
        fs.each do |f|
          yield f.get
        end
      else
        children.each do |child|
          child.wait
          yield child
        end
      end
    end

    # Aborts all the descendant processes.
    def abort(signal = nil)
      children = @mutex.synchronize do
        @children.dup
      end
      children.each do |child|
        child.abort signal
      end
    end

    # Tests if all the child processes and groups successfully terminated.
    def success?
      children = @mutex.synchronize do
        @children.dup
      end
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
