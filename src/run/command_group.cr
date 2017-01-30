module Run
  # Represents a set of commands.
  class CommandGroup
    # Returns this parent group.
    getter? parent : CommandGroup?

    # Returns this context.
    getter context : Context

    # Returns all the children appended to this group.
    getter children = [] of CommandLike

    # Returns all the commands appended to this group.
    getter commands = [] of Command

    # Returns all the command groups appended to this group.
    getter command_groups = [] of CommandGroup

    # Returns all the fiber functions appended to this group.
    getter fiber_functions = [] of FiberFunction

    # Returns all the process functions appended to this group.
    getter process_functions = [] of ProcessFunction

    # Initializes a command group with a context.
    def initialize(context : Context)
      @context = context
    end

    # Initializes a command group with a context yielding the command group.
    def initialize(context : Context)
      @context = context
      yield self
    end

    # :nodoc:
    macro __initialize(with_block = false, &block)
    {% if with_block %}
    # Initializes a command group with context attributes yielding the command group.
    {% else %}
    # Initializes a command group with context attributes.
    {% end %}
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
      def initialize(name : Symbol, **optional_attributes)
        @context = Context.new(**optional_attributes).name(name)
      end
    end

    __initialize with_block: true do
      def initialize(**attributes, &block)
        @context = Context.new(**attributes)
        yield self
      end
    end

    __initialize with_block: true do
      def initialize(name : Symbol, **optional_attributes)
        @context = Context.new(**optional_attributes).name(name)
        yield self
      end
    end

    # Sets a parent group.
    def parent=(parent : CommandGroup)
      @parent = parent
      @context.set parent: parent.context
    end

    # Appends a command.
    #
    # This instance is set to the appended command as its parent.
    def <<(command : Command)
      command.parent = self
      @children << command
      @commands << command
    end

    # Appends a command group.
    #
    # This instance is set to the appended group as its parent.
    def <<(group : CommandGroup)
      group.parent = self
      @children << group
      @command_groups << group
    end

    # Appends a fiber function.
    #
    # This instance is set to the appended function as its parent.
    def <<(function : FiberFunction)
      function.parent = self
      @children << function
      @fiber_functions << function
    end

    # Appends a process function.
    #
    # This instance is set to the appended function as its parent.
    def <<(function : ProcessFunction)
      function.parent = self
      @children << function
      @process_functions << function
    end

    # Append and returns a new command.
    #
    # This method sets the *context* to the command.
    def command(context : Context)
      cmd = Command.new(context)
      self << cmd
      cmd
    end

    # :nodoc:
    macro __command(&block)
    # Appends and returns a new command.
    #
    # This method initializes the command's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context`.
    {{block.body}}
    end

    __command do
      def command(**attributes)
        command(Context.new(**attributes))
      end
    end

    __command do
      def command(command : String, **optional_attributes)
        command(Context.new(**optional_attributes).command(command))
      end
    end

    __command do
      def command(command : String, args : Array(String), **optional_attributes)
        command(Context.new(**optional_attributes).command(command).args(args))
      end
    end

    __command do
      def command(name : Symbol, **optional_attributes)
        command(Context.new(**optional_attributes).name(name))
      end
    end

    __command do
      def command(name : Symbol, command : String, **optional_attributes)
        command(Context.new(**optional_attributes).name(name).command(command))
      end
    end

    __command do
      def command(name : Symbol, command : String, args : Array(String), **optional_attributes)
        command(Context.new(**optional_attributes).name(name).command(command))
      end
    end

    # Appends and returns a new command group.
    #
    # This method sets the *context* to the command group.
    def group(context : Context)
      cmd = CommandGroup.new(context)
      self << cmd
      cmd
    end

    # Appends and returns a new command group yielding the command group.
    #
    # This method sets the *context* to the command group.
    def group(context : Context, &block)
      cmd = CommandGroup.new(context)
      self << cmd
      yield cmd
      cmd
    end

    # :nodoc:
    macro __group(with_block = false, &block)
    {% if with_block %}
    # Appends and returns a new command group yielding the new command group.
    {% else %}
    # Appends and returns a new command group.
    {% end %}
    #
    # This method initializes the new command group's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context`.
    {{block.body}}
    end

    __group do
      def group(**attributes)
        group(Context.new(**attributes))
      end
    end

    __group do
      def group(name : Symbol, **optional_attributes)
        group(Context.new(**optional_attributes).name(name))
      end
    end

    __group with_block: true do
      def group(**attributes, &block)
        group(Context.new(**attributes)) do |g|
          yield g
        end
      end
    end

    __group with_block: true do
      def group(name : Symbol, **optional_attributes, &block)
        group(Context.new(**optional_attributes).name(name)) do |g|
          yield g
        end
      end
    end

    # Appends and returns a new fiber function.
    #
    # The *block* will be invoked in a new fiber.
    #
    # The *block* must returns 0 if the process is succeeded. Otherwise, non-zero.
    #
    # This method initializes the function's context attributes with the *context* argument.
    #
    # For more information about the context, see `Context`.
    def future(context : Context, &block : FiberFunction::ProcType)
      cmd = FiberFunction.new(context, &block)
      self << cmd
      cmd
    end

    # :nodoc:
    macro __future(&block)
    # Appends and returns a new fiber function.
    #
    # The *block* will be invoked in a new fiber.
    #
    # The *block* must returns 0 if the process is succeeded. Otherwise, non-zero.
    #
    # This method initializes the function's context attributes with the arguments.
    #
    # For more information about the arguments, see `Context`.
    {{block.body}}
    end

    # Appends and returns a new fiber function.
    #
    # The *block* will be invoked in a new fiber.
    #
    # The *block* must returns 0 if the process is succeeded. Otherwise, non-zero.
    #
    # This method initializes the function's context attributes with the arguments.
    #
    # For more information about the arguments, see `Context`.
    def future(**attributes, &block : FiberFunction::ProcType)
      future(Context.new(**attributes), &block)
    end

    # Appends and returns a new fiber function.
    #
    # The *block* will be invoked in a new fiber.
    #
    # The *block* must returns 0 if the process is succeeded. Otherwise, non-zero.
    #
    # This method initializes the function's context attributes with the arguments.
    #
    # For more information about the arguments, see `Context`.
    def future(name : Symbol, **optional_attributes, &block : FiberFunction::ProcType)
      future(Context.new(**optional_attributes).name(name), &block)
    end

    # Appends and returns a new process function.
    #
    # The *block* will be invoked in a forked process.
    #
    # The *block* must returns 0 if the process is succeeded. Otherwise, non-zero.
    #
    # This method initializes the function's context attributes with the *context* argument.
    #
    # For more information about the context, see `Context`.
    def fork(context : Context, &block : ProcessFunction::ProcType)
      cmd = ProcessFunction.new(context, &block)
      self << cmd
      cmd
    end

    # Appends and returns a new process function.
    #
    # The *block* will be invoked in a forked process.
    #
    # The *block* must returns 0 if the process is succeeded. Otherwise, non-zero.
    #
    # This method initializes the function's context attributes with the arguments.
    #
    # For more information about the arguments, see `Context`.
    def fork(**attributes, &block : ProcessFunction::ProcType)
      fork(Context.new(**attributes), &block)
    end

    # Appends and returns a new process function.
    #
    # The *block* will be invoked in a forked process.
    #
    # The *block* must returns 0 if the process is succeeded. Otherwise, non-zero.
    #
    # This method initializes the function's context attributes with the arguments.
    #
    # For more information about the arguments, see `Context`.
    def fork(name : Symbol, **optional_attributes, &block : ProcessFunction::ProcType)
      fork(Context.new(optional_attributes).name(name), &block)
    end

    # Runs all children under this group.
    def run(**attributes)
      new_process(Context.new(**attributes)).tap do |pg|
        pg.start
      end
    end

    # :nodoc:
    def new_process_context(run_context : Context)
      run_context.dup
        .parent(context)
        .name(context.name)
        .set(parallel: context.self_parallel)
    end

    # :nodoc:
    def new_process(attrs : Context)
      new_process(nil, attrs)
    end

    # :nodoc:
    def new_process(parent : ProcessGroup)
      new_process(parent, Context.new)
    end

    # :nodoc:
    def new_process(parent : ProcessGroup?, attrs : Context)
      rc = if parent
        parent.run_context.dup.set(attrs)
      else
        attrs.dup
      end
      pg = ProcessGroup.new(parent, new_process_context(rc), rc)
      parent << pg if parent
      pg << self
      pg
    end

    # Calls the `#commands` array's #[] method.
    def [](*args)
      @commands[*args]
    end

    # Calls the `#commands` array's #[]? method.
    def []?(*args)
      @commands[*args]?
    end
  end
end
