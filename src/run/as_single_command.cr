module Run
  module AsSingleCommand
    # Returns this parent group.
    getter? parent : CommandGroup?

    # Returns this parent group.
    def parent : CommandGroup
      @parent.as(CommandGroup)
    end

    # Returns this context.
    getter context : Context

    # Sets a parent group.
    def parent=(parent : CommandGroup)
      @parent = parent
      @context.set parent: parent.context
    end
  end
end
