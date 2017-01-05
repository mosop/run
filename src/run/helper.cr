module Run
  # Creates a new command with context attributes.
  #
  # For more information about the arguments, see `Context#set`.
  def self.command(command : String, *nameless, **named)
    Command.new(command, *nameless, **named)
  end

  # Creates a new command with context attributes.
  #
  # For more information about the arguments, see `Context#set`.
  def self.command(name : Symbol, *nameless, **named)
    Command.new(name, *nameless, **named)
  end

  # Creates a new command group with context attributes.
  #
  # For more information about the arguments, see `Context#set`.
  def self.group(**attrs)
    CommandGroup.new(**attrs)
  end

  # Creates a new command group with context attributes.
  #
  # For more information about the arguments, see `Context#set`.
  def self.group(name : Symbol, **attrs)
    CommandGroup.new(name, **attrs)
  end

  # Creates a new command group with context attributes and yield a block with the command group.
  #
  # For more information about the arguments, see `Context#set`.
  def self.group(**attrs, &block : CommandGroup -> _)
    CommandGroup.new(**attrs) do |g|
      yield g
    end
  end

  # Creates a new command group with context attributes and yield a block with the command group.
  #
  # For more information about the arguments, see `Context#set`.
  def self.group(name : Symbol, **attrs, &block : CommandGroup -> _)
    CommandGroup.new(name, **attrs) do |g|
      yield g
    end
  end
end
