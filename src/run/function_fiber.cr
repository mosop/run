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
      @future : Concurrent::Future(ExitStatus)?
      @wait_mutex = Mutex.new
      @exit_status = ExitStatus.new(-1)

      def initialize(ff : FunctionFiber)
        @future = future do
          begin
            raise Exit.new(ExitStatus.new(ff.function.proc.call))
          rescue ex
            case ex
            when Exit
              ex.status
            else
              begin
                STDERR.puts ex.message
              rescue
              end
              ExitStatus.new(1)
            end
          end
        end
      end

      def wait
        @wait_mutex.synchronize do
          if future = @future
            @exit_status = future.get
            @future = nil
          end
        end
        @exit_status
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
