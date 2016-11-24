module Run
  class Command
    getter? parent : CommandGroup?
    getter context : Context

    def initialize(command : String, *nameless, **named)
      @context = Context.new(command, *nameless, **named)
    end

    def parent(parent)
      @parent = parent
      @context.parent(parent.context)
      self
    end

    def exec(**options)
      new_process(**options).exec
    end

    def run(**options)
      new_process(**options).tap do |process|
        process.run
      end
    end

    def new_process(**options)
      Process.new(Context.new(**options).parent(context))
    end
  end
end
