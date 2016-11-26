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
    def exec(pg : ProcessGroup, **options)
      new_process(pg, **options).exec
    end

    # Run this command with additional context attributes.
    def run(**options) : Process
      new_process(**options).tap do |process|
        process.start
      end
    end

    # :nodoc:
    def run(pg : ProcessGroup, **options) : Process
      new_process(**options).tap do |process|
        process.start
      end
    end

    # :nodoc:
    def new_process(**options) : Process
      Process.new(nil, self, Context.new(**options).set(parent: context))
    end

    # :nodoc:
    def new_process(pg : ProcessGroup?, **options) : Process
      Process.new(pg, self, Context.new(**options).set(parent: context))
    end
  end
end
