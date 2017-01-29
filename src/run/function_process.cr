module Run
  # Represents a runnning process that executes a code block in a forked process.
  class FunctionProcess
    include AsProcess

    @impl : Impl?

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
          begin
            ::Process.exit fp.function.proc.call
          rescue ex
            begin
              STDERR.puts ex.message
            rescue
            end
            ::Process.exit 1
          end
        end
        input_fork.close_child
        output_fork.close_child
        error_fork.close_child
        @input = input_fork.pipe?
        @output = output_fork.pipe?
        @error = error_fork.pipe?
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

    # :nodoc:
    def new_impl
      Impl.new(self)
    end
  end
end
