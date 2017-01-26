module Run
  class Command
    include AsCommand

    # Initializes a command with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(command : String, *nameless, **named)
      @context = Context.new(command, *nameless, **named)
    end

    # Initializes a command with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(name : Symbol, *nameless, **named)
      @context = Context.new(name, *nameless, **named)
    end

    # Executes this command with additional context attributes.
    #
    # It executes this commmand with C exec. So, the current process is replaced with the executing process.
    def exec(**attrs)
      new_process(Context.new(**attrs)).exec
    end

    # Run this command with additional context attributes.
    def run(**attrs) : Process
      new_process(Context.new(**attrs)).tap do |process|
        process.start
      end
    end

    # :nodoc:
    def new_process(attrs : Context) : Process
      new_process(nil, attrs)
    end

    # :nodoc:
    def new_process(parent : ProcessGroup) : Process
      new_process(parent, Context.new)
    end

    # :nodoc:
    def new_process(parent : ProcessGroup?, attrs : Context) : Process
      if parent
        rc = parent.run_context.dup.set(attrs)
        Process.new(parent, self, rc)
      else
        parent = ProcessGroup.new
        process = Process.new(parent, self, attrs.dup)
        parent << process
        process
      end
    end
  end
end
