module Run
  class Command
    # Returns this parent group.
    getter? parent : CommandGroup?

    # Returns this context.
    getter context : Context

    # Initializes a command with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(command : String, *nameless, **named)
      @context = Context.new(command, *nameless, **named)
    end

    # Initializes a command with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(name : Symbol, command : String, args : Array(String), *nameless, **named)
      @context = Context.new(name, command, args, *nameless, **named)
    end

    # Returns this parent group.
    def parent : CommandGroup
      @parent.as(CommandGroup)
    end

    # Sets a parent group.
    def parent=(parent : CommandGroup)
      @parent = parent
      @context.set parent: parent.context
    end

    # Executes this command with additional context attributes.
    #
    # It executes this commmand with C exec. So, the current process is replaced with the executing process.
    def exec(**options)
      new_process(**options).exec
    end

    # :nodoc:
    def exec(pg : ProcessGroup, run_context : Context)
      new_process(pg, run_context).exec
    end

    # Run this command with additional context attributes.
    def run(**options) : Process
      new_process(**options).tap do |process|
        process.start
      end
    end

    # :nodoc:
    def run(pg : ProcessGroup, run_context : Context) : Process
      new_process(pg, run_context).tap do |process|
        process.start
      end
    end

    # :nodoc:
    def new_process(**attrs) : Process
      rc = Context.new(**attrs)
      Process.new(nil, self, rc)
    end

    # :nodoc:
    def new_process(pg : ProcessGroup) : Process
      new_process pg, Context.new
    end

    # :nodoc:
    def new_process(pg : ProcessGroup, attrs : Context) : Process
      rc = pg.run_context.dup.set(attrs)
      Process.new(pg, self, rc)
    end
  end
end
