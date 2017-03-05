module Run
  class Exit < Exception
    getter status : ExitStatus

    def initialize(@status : ExitStatus)
    end
  end
end
