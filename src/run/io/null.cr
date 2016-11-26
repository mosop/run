struct Run::Io
  # :nodoc:
  struct Null < Io
    def for_exec
      false
    end

    def for_run
      false
    end

    def input
      File.open("/dev/null", "rw")
    end

    def output
      File.open("/dev/null", "rw")
    end

    def error
      File.open("/dev/null", "rw")
    end
  end
end
