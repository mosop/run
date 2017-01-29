module Run
  # Represents a runnning process that executes a code block in a fiber.
  #
  # `FunctionFiber` does not handle singal messages sent by `AsProcess#abort` and `AsProcess#kill`. You have to implement inter-fiber communication with arbitrary methods, such as *Channel*.
  class FunctionFiber
    include AsProcess

    @impl : Impl?

    # Returns the source function.
    def function : FiberFunction
      @command.as(FiberFunction)
    end

    # :nodoc:
    class Impl
      @future : Concurrent::Future(Int32)?
      @wait_mutex = Mutex.new

      def initialize(@process : FunctionFiber)
        @future = future do
          begin
            @process.function.proc.call
          rescue
            1
          end
        end
      end

      @exit_code : Int32?
      def exit_code
        wait
        @exit_code.not_nil!
      end

      def wait
        @wait_mutex.synchronize do
          if future = @future
            @exit_code = future.get
            @future = nil
          end
        end
        self
      end

      def input?
      end

      def output?
      end

      def error?
      end

      def exists?
        @future
      end

      def kill(signal)
      end
    end

    # :nodoc:
    def new_impl
      Impl.new(self)
    end
  end
end
