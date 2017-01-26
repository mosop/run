module Run
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

    # :nodoc:
    def initialize(context : Context)
      @context = context
    end

    # Initializes a command group with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(**attrs)
      initialize Context.new(**attrs)
    end

    # Initializes a command group with context attributes.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(name : Symbol, **attrs)
      initialize Context.new(name, **attrs)
    end

    # Initializes a command group with context attributes and yield a block with self.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(**attrs, &block : CommandGroup -> _)
      initialize **attrs
      yield self
    end

    # Initializes a command group with context attributes and yield a block with self.
    #
    # For more information about the arguments, see `Context#set`.
    def initialize(name : Symbol, **attrs, &block : CommandGroup -> _)
      initialize name, **attrs
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

    # Appends a fiber function.
    #
    # It sets self to the appended function as the parent.
    def <<(function : FiberFunction)
      function.parent = self
      @children << function
      @fiber_functions << function
    end

    # Appends a process function.
    #
    # It sets self to the appended function as the parent.
    def <<(function : ProcessFunction)
      function.parent = self
      @children << function
      @process_functions << function
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
      self << child
      yield child
      child
    end

    # Appends and returns a new fiber function.
    #
    # The function will be run in a new fiber.
    #
    # This method initializes the function's context attributes with the *named* arguments.
    #
    # For more information about the *named* arguments, see `Context#set`.
    def spawn(**named, &block : FiberFunction::ProcType)
      cmd = FiberFunction.new(**named, &block)
      self << cmd
      cmd
    end

    # Appends and returns a new process function.
    #
    # The function will be run in a new forked process.
    #
    # This method initializes the function's context attributes with the *named* arguments.
    #
    # For more information about the *named* arguments, see `Context#set`.
    def fork(**named, &block : ProcessFunction::ProcType)
      cmd = ProcessFunction.new(**named, &block)
      self << cmd
      cmd
    end

    # Runs all children under this group.
    def run(**attrs)
      new_process(Context.new(**attrs)).tap do |pg|
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
