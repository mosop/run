module Run
  # Represents a process that executes a command in a forked process.
  class CommandProcess
    include AsProcess

    @impl : Impl?

    # Returns the source command.
    def command : Command
      @command.as(Command)
    end

    # :nodoc:
    def exec
      with_startup do
        context.exec
      end
    end

    # :nodoc:
    def to_impl_args
      {
        command: context.command,
        args: context.args,
        env: context.env,
        clear_env: context.clears_env?,
        shell: context.shell?,
        input: context.input.for_run,
        output: context.output.for_run,
        error: context.error.for_run,
        chdir: context.chdir
      }
    end

    # :nodoc:
    class Impl
      @impl : ::Process

      def initialize(cp : CommandProcess)
        @impl = ::Process.new(**cp.to_impl_args)
      end

      def wait
        ExitStatus.new(@impl.wait.exit_code)
      end

      def exists?
        @impl.exists?
      end

      def kill(signal)
        @impl.kill signal
      end

      def input?
        @impl.input?
      end

      def output?
        @impl.output?
      end

      def error?
        @impl.error?
      end
    end

    # :nodoc:
    def new_impl
      Impl.new(self)
    end
  end
end
