module Run
  # Represents a command that executes a code block in a forked process.
  class FiberFunction
    include AsCommand

    alias ProcType = Proc(Int32)

    # Returns an executed code block.
    getter proc : ProcType

    # :nodoc:
    def initialize(**attributes, &block : ProcType)
      @context = Context.new(**attributes)
      @proc = block
    end

    # :nodoc:
    def initialize(context : Context, &block : ProcType)
      @context = context
      @proc = block
    end

    # :nodoc:
    def process_class
      FunctionFiber
    end
  end
end
