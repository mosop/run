struct Run::Io
  # :nodoc:
  struct Parent < Io
    def for_exec
      true
    end

    def for_run
      true
    end

    def input
      STDIN
    end

    def output
      STDOUT
    end

    def error
      STDERR
    end
  end
end
