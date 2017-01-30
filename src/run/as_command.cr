module Run
  module AsCommand
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
      if parent
        rc = parent.run_context.dup.set(attrs)
        process_class.new(parent, self, rc)
      else
        parent = ProcessGroup.new
        process = process_class.new(parent, self, attrs.dup)
        parent << process
        process
      end
    end
  end
end
