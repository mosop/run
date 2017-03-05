module Run
  struct ExitStatus
    getter code : Int32
    getter? data : String?

    def initialize(@code, @data : String? = nil)
    end

    def success?
      @code == 0
    end

    def error?
      !success?
    end

    def exit!
      raise Exit.new(self)
    end
  end
end
