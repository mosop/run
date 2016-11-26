struct Run::Io
  # :nodoc:
  struct GenericIo < Io
    @io : IO

    def initialize(@io : IO)
    end

    def for_exec
      @io
    end

    def for_run
      @io
    end

    def input
      @io
    end

    def output
      @io
    end

    def error
      @io
    end
  end
end
