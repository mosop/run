module Run
  class CommandGroup
    Callback.enable
    define_callback_group :abort, proc_type: Proc(::Run::ProcessGroup, ::Nil)
    define_callback_group :abort_process, proc_type: Proc(::Run::Process, ::Nil)

    # Returns this parent group.
    getter? parent : CommandGroup?

    # Returns this context.
    getter context : Context

    # Returns all the commands and the command groups appended to this group.
    getter children = [] of (Command | CommandGroup)

    # Returns all the commands appended to this group.
    getter commands = [] of Command

    # Returns all the command groups appended to this group.
    getter command_groups = [] of CommandGroup

    # :nodoc:
    def initialize(context : Context)
      @context = context
    end

    # Initializes a command group with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(**options)
      initialize Context.new(**options)
    end

    # Initializes a command group with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(name : Symbol, **options)
      initialize Context.new(name, **options)
    end

    # Initializes a command group with context attributes and yield a block with self.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(**options, &block : CommandGroup -> _)
      initialize **options
      yield self
    end

    # Initializes a command group with context attributes and yield a block with self.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(name : Symbol, **options, &block : CommandGroup -> _)
      initialize name, **options
      yield self
    end

    # Sets a parent group.
    def parent=(parent : CommandGroup)
      @parent = parent
      @context.set parent: parent.context
    end

    # Appends a single command.
    #
    # It sets self to the appended command as the parent.
    def <<(command : Command)
      command.parent = self
      @children << command
      @commands << command
    end

    # Appends a command group.
    #
    # It sets self to the appended group as the parent.
    def <<(group : CommandGroup)
      group.parent = self
      @children << group
      @command_groups << group
    end

    # Appends and returns a new single command.
    #
    # It initializes the command's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context#set`.
    def command(*nameless, **named)
      Command.new(*nameless, **named).tap do |cmd|
        self << cmd
      end
    end

    # Appends and returns a new command group.
    #
    # It initializes the new group's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context#set`.
    def group(**named)
      CommandGroup.new(**named).tap do |g|
        self << g
      end
    end

    # Appends and returns a new command group.
    #
    # It initializes the new group's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context#set`.
    def group(name : Symbol, **named)
      CommandGroup.new(name, **named).tap do |g|
        self << g
      end
    end

    # Appends and returns a new command group and yield a block with the group.
    #
    # It initializes the new group's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context#set`.
    def group(**named, &block : CommandGroup -> _)
      group(**named).tap do |g|
        yield g
      end
    end

    # Appends and returns a new command group and yield a block with the group.
    #
    # It initializes the new group's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context#set`.
    def group(name : Symbol, &block : CommandGroup -> _)
      group(name).tap do |g|
        yield g
      end
    end

    # Appends and returns a new command group and yield a block with the group.
    #
    # It initializes the new group's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context#set`.
    def group(name : Symbol, **named, &block : CommandGroup -> _)
      group(name, **named).tap do |g|
        yield g
      end
    end

    # Appends and returns the specified group and yield a block with the group.
    #
    # It initializes the new group's context attributes with the arguments.
    #
    # For more information about the context attributes, see `Context#set`.
    def group(child : CommandGroup, &block : CommandGroup -> _)
      group << child
      yield group
      group
    end

    # Runs all commands and command groups under this group.
    def run(**options)
      new_process(**options).tap do |pg|
        pg.start
      end
    end

    # :nodoc:
    def run(pg : ProcessGroup, **options)
      new_process(pg, **options).tap do |pg|
        pg.start
      end
    end

    # :nodoc:
    def new_process(**options)
      ProcessGroup.new(nil, self, Context.new(**options))
    end

    # :nodoc:
    def new_process(pg : ProcessGroup, **options)
      ProcessGroup.new(pg, self, Context.new(**options))
    end

    # Delegated to #[] of the result of `#commands`.
    def [](*args)
      @commands[*args]
    end

    # Delegated to #[]? of the result of `#commands`.
    def []?(*args)
      @commands[*args]?
    end
  end
end
