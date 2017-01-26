module Run
  class FunctionProcess
    include AsProcess

    @impl : Impl?
    getter signal_channel = Channel(Signal).new

    # Returns the source function.
    def function : ProcessFunction
      @command.as(ProcessFunction)
    end

    # :nodoc:
    class Impl
      @impl : ::Process

      def initialize(@process : FunctionProcess)
        @impl = ::Process.fork do
          ::Process.exit @process.function.proc.call
        end
      end

      def input
      end

      def output
      end

      def error
      end

      def wait
        @impl.wait
      end

      def exists?
        @impl.exists?
      end

      def kill(signal)
        @impl.kill signal
      end
    end

    def new_impl
      Impl.new(self)
    end
  end
end
