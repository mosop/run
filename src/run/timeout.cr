module Run
  struct Timeout
    # :nodoc:
    class Elapsed < Exception
    end

    INFINITE = new(-1)
    NO_WAIT = new(nil)

    # :nodoc:
    alias Type = Number::Primitive | Nil

    # :nodoc:
    alias ArgNotNil = Number::Primitive | Timeout

    alias Arg = ArgNotNil | Nil

    # :nodoc:
    alias Var = Timeout?

    # :nodoc:
    getter? value : Type

    # :nodoc:
    def initialize(@value)
    end

    # :nodoc:
    def value
      @value.as(Number::Primitive)
    end

    # :nodoc:
    def try_and_wait(interval : Number::Primitive, prewait : Number::Primitive)
      return if value?.nil?
      sleep prewait if prewait > 0
      left = value
      loop do
        break if yield
        sleep interval
        next if left == -1
        left -= interval
        raise Elapsed.new if left <= 0
      end
    end

    # :nodoc:
    def self.parse_arg(arg : ArgNotNil)
      case arg
      when Timeout
        arg
      when Number::Primitive
        new(arg.to_f64)
      end
    end
  end
end
