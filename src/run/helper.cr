module Run
  # Creates a new command with a context.
  def self.command(context : Context)
    Command.new(context)
  end

  # :nodoc:
  macro __command(&block)
  # Creates a new command with context attributes.
  #
  # For more information about the arguments, see `Context`.
  {{block.body}}
  end

  __command do
    def self.command(command : String, **optional_context_attributes)
      Command.new(Context.new(**optional_context_attributes).command(command))
    end
  end

  __command do
    def self.command(command : String, args : Array(String), **optional_context_attributes)
      Command.new(Context.new(**optional_context_attributes).command(command).args(args))
    end
  end

  # Creates a new command group with a context.
  def self.group(context : Context)
    CommandGroup.new(context)
  end

  # Creates a new command group with a context yielding the command group.
  def self.group(context : Context, &block)
    CommandGroup.new(context) do |g|
      yield g
    end
  end

  # :nodoc:
  macro __group(with_block = false, &block)
  {% if with_block %}
  # Creates a new command group with context attributes.
  {% else %}
  # Creates a new command group with context attributes yielding the command group.
  {% end %}
  #
  # For more information about the arguments, see `Context`.
  {{block.body}}
  end

  __group do
    def self.group(**context_attributes)
      CommandGroup.new(**context_attributes)
    end
  end

  __group do
    def self.group(name : Symbol, **optional_context_attributes)
      CommandGroup.new(Context.new(**optional_context_attributes).name(name))
    end
  end

  __group with_block: true do
    def self.group(**context_attributes, &block)
      CommandGroup.new(**context_attributes) do |g|
        yield g
      end
    end
  end

  __group with_block: true do
    def self.group(name : Symbol, **optional_context_attributes, &block)
      CommandGroup.new(Context.new(**optional_context_attributes).name(name)) do |g|
        yield g
      end
    end
  end
end
