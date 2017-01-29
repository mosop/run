module Run
  # Represents a command that executes a code block in a forked process.
  class ProcessFunction
    include AsCommand

    alias ProcType = Proc(Int32)

    # Returns an executed code block.
    getter proc : ProcType

    # :nodoc:
    def initialize(**named, &block : ProcType)
      @context = Context.new(**named)
      @proc = block
    end

    # :nodoc:
    def new_process(parent : ProcessGroup) : FunctionProcess
      new_process(parent, Context.new)
    end

    # :nodoc:
    def new_process(parent : ProcessGroup?, attrs : Context) : FunctionProcess
      if parent
        rc = parent.run_context.dup.set(attrs)
        FunctionProcess.new(parent, self, rc)
      else
        parent = ProcessGroup.new
        process = FunctionProcess.new(parent, self, attrs.dup)
        parent << process
        process
      end
    end
  end
end
