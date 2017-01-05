module Run
  abstract struct Io
    PIPE = Pipe.new
    PARENT = Parent.new
    NULL = Null.new

    # :nodoc:
    alias ArgNotNil = Bool | IO | Io

    alias Arg = ArgNotNil | Nil

    # :nodoc:
    def self.parse_arg(arg : ArgNotNil)
      case arg
      when Io
        arg
      when IO
        GenericIo.new(arg)
      when Bool
        arg ? PARENT : NULL
      end
    end
  end
end

require "./io/*"
