module Run
  abstract struct Io
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
      when IO::FileDescriptor
        Fd.new(arg)
      when IO
        Generic.new(arg)
      when Bool
        arg ? PARENT : NULL
      end
    end

    # :nodoc:
    def reopen(old, new)
      if C.dup2(old.fd, new.fd) == -1
        raise Errno.new("dup2() error.")
      end
    end
  end
end

require "./io/*"
