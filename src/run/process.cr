module Run
  # Represents a process that executes a command in a forked process.
  class Process
    include AsProcess

    @impl : ::Process?

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
    def new_impl
      ::Process.new(**to_impl_args)
    end
  end
end
