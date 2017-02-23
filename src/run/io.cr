module Run
  abstract struct Io
    PARENT = Ios::Parent.new
    NULL = Ios::Null.new
    PIPE = Ios::Pipe.new

    alias Like = Bool | IO | Io
    alias Arg = Like?

    # :nodoc:
    def self.parse_arg(arg : Like)
      case arg
      when Io
        arg
      when IO::FileDescriptor
        Ios::Fd.new(arg)
      when IO
        Ios::Generic.new(arg)
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
