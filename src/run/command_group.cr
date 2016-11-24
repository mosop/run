module Run
  class CommandGroup
    macro method_missing(call)
      {%
        args = call.args.map{|i| i.id}.join(", ")
      %}

      {% if call.name == "[]" %}
        @children[{{args.id}}]
      {% elsif call.name == "[]?" %}
        @children[{{args.id}}]?
      {% elsif call.name == "[]=" %}
        @children[{{call.args[0..-2].map{|i| i.id}.join(", ").id}}] = {{call.args.last.id}}
      {% elsif call.name =~ /^\w/ %}
        @children.{{call}}
      {% else %}
        @children {{call.name.id}} {{args.id}}
      {% end %}
    end

    getter? parent : CommandGroup?
    getter context : Context

    def initialize(**options)
      @context = Context.new(**options)
    end

    def initialize(**options, &block : CommandGroup -> _)
      initialize **options
      yield self
    end

    def parent(parent)
      @parent = parent
      @context.parent(parent.context)
      self
    end

    getter children = [] of (Command | CommandGroup)

    def <<(command : Command)
      @children << command.parent(self)
    end

    def <<(group : CommandGroup)
      @children << group.parent(self)
    end

    def command(*nameless, **named)
      Command.new(*nameless, **named).tap do |cmd|
        self << cmd
      end
    end

    def group(**named)
      CommandGroup.new(**named).tap do |g|
        self << g
      end
    end

    def group(**named, &block : CommandGroup -> _)
      group(**named).tap do |g|
        yield g
      end
    end

    def run(**options)
      ProcessGroup.new(self, Context.new(**options)).tap do |pg|
        pg.run
      end
    end
  end
end
