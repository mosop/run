module Run
  class Function
    include AsCommand

    alias ProcType = Proc(FunctionProcess, Int32)

    getter proc : ProcType

    # Initializes a function with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(**named, &block : ProcType)
      @proc = block
      @context = Context.new(**named)
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
