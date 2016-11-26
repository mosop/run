struct Run::Io
  # :nodoc:
  struct Pipe < Io
    def for_exec
      true
    end

    def for_run
      nil
    end

    def input
    end

    def output
    end

    def error
    end
  end
end
