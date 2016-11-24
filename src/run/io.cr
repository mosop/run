module Run
  struct Io
    alias Type = Bool | IO::FileDescriptor | Nil
    alias Arg = Type | Io
    @value : Type

    def initialize(@value : Type)
    end

    def self.parse_arg(current : Arg, arg : Arg)
      case current
      when Io
        from_arg(arg)
      else
        case arg
        when Nil
          nil
        when Bool
          new(arg)
        when IO::FileDescriptor
          new(arg)
        when Io
          arg
        end
      end
    end

    def self.from_arg(arg : Arg)
      case arg
      when Io
        arg
      else
        new(arg)
      end
    end

    def self.null
      new(nil)
    end

    def for_exec
      case v = @value
      when Bool, IO::FileDescriptor
        v
      else
        true
      end
    end

    def for_run
      @value
    end
  end
end
