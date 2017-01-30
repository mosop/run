module Run
  # Represents a command that executes a command in a forked process.
  class Command
    include AsCommand

    # Initializes a command with a context.
    def initialize(context : Context)
      @context = context
    end

    # :nodoc:
    macro __initialize(&block)
    # Initializes a command with context attributes.
    #
    # For more information about the arguments, see `Context`.
    {{block.body}}
    end

    __initialize do
      def initialize(**attributes)
        @context = Context.new(**attributes)
      end
    end

    __initialize do
      def initialize(command : String, **optional_attributes)
        @context = Context.new(**optional_attributes).command(command)
      end
    end

    __initialize do
      def initialize(command : String, args : Array(String), **optional_attributes)
        @context = Context.new(**optional_attributes).command(command).args(args)
      end
    end

    __initialize do
      def initialize(name : Symbol, **optional_attributes)
        @context = Context.new(**optional_attributes).name(name)
      end
    end

    __initialize do
      def initialize(name : Symbol, command : String, **optional_attributes)
        @context = Context.new(**optional_attributes).name(name).command(command)
      end
    end

    __initialize do
      def initialize(name : Symbol, command : String, args : Array(String), **optional_attributes)
        @context = Context.new(**optional_attributes).name(name).command(command).args(args)
      end
    end

    # Executes this command with additional context attributes.
    #
    # It executes this commmand with C exec. So, the current process is replaced with the executing process.
    def exec(**attributes)
      new_process(Context.new(**attributes)).exec
    end

    # Run this command with additional context attributes.
    def run(**attributes)
      new_process(Context.new(**attributes)).tap do |process|
        process.start
      end
    end

    # :nodoc:
    def process_class
      CommandProcess
    end
  end
end
