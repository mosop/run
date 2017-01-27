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
      getter? input : IO::FileDescriptor?
      getter? output : IO::FileDescriptor?
      getter? error : IO::FileDescriptor?

      def initialize(fp : FunctionProcess)
        context = fp.context
        input_fork = context.input.fork_input
        output_fork = context.output.fork_output
        error_fork = context.error.fork_error
        chdir = context.chdir
        @impl = ::Process.fork do
          ENV.clear if context.clears_env?
          context.env.each do |k, v|
            if v
              ENV[k] = v
            else
              ENV.delete k
            end
          end
          input_fork.reopen_input STDIN
          output_fork.reopen_output STDOUT
          error_fork.reopen_error STDERR
          STDIN.close_on_exec = false
          STDOUT.close_on_exec = false
          STDERR.close_on_exec = false
          Dir.cd context.chdir
          ::Process.exit fp.function.proc.call
        end
        input_fork.close_child
        output_fork.close_child
        error_fork.close_child
        @input = input_fork.piped?
        @output = output_fork.piped?
        @error = error_fork.piped?
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
