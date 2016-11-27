module Run
  class Process
    # Returns this parent group.
    getter? parent : ProcessGroup?

    # Returns this parent group.
    def parent : ProcessGroup
      @parent.as(ProcessGroup)
    end

    # Tests if this process is the root.
    def root?
      !parent?
    end

    # Returns this root group.
    def root_group? : ProcessGroup?
      root? ? nil : parent.root
    end

    # Returns this root group.
    def root_group : ProcessGroup
      root_group?.as(ProcessGroup)
    end

    # Returns this source command group.
    getter source : Command

    @run_context : Context

    # Returns this context.
    getter context : Context

    # :nodoc:
    getter? impl : ::Process?

    # Tests if the running process is started.
    getter? started : Bool?

    # :nodoc:
    getter? aborted : Bool?

    @start_mutex = Mutex.new
    @wait_mutex = Mutex.new
    @abort_mutex = Mutex.new

    # :nodoc:
    def initialize(@parent, @source, @run_context)
      @context = @run_context.dup.parent(@source.context).name(@source.context.name)
    end

    # :nodoc:
    def impl
      @impl.as(::Process)
    end

    # Returns this input IO.
    def input : IO
      context.input.input || impl.input
    end

    # Returns this output IO.
    def output : IO
      context.output.output || impl.output
    end

    # Returns this error IO.
    def error : IO
      context.error.error || impl.error
    end

    # :nodoc:
    def with_startup
      Dir.mkdir_p context.chdir
      show_dir if context.shows_dir?
      show_command if context.shows_command?
      yield
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

    # :nodoc:
    def start
      @start_mutex.synchronize do
        if @started.nil?
          unless aborted?
            with_startup do
              @impl = new_impl
            end
            @started = true
          else
            @started = false
          end
        end
      end
      @started
    end

    # :nodoc:
    def unstart
      @start_mutex.synchronize do
        if @started.nil?
          @started = false
        end
      end
      @started
    end

    # :nodoc:
    def wait
      @wait_mutex.synchronize do
        if @terminated.nil?
          if start
            @exit_code = status = impl.wait.exit_code
            @terminated = true
            if status == 0
              success!
            else
              error!
            end
          else
            @terminated = false
          end
        end
      end
      @terminated
    end

    # :nodoc:
    def success!
      if parent?
        parent.source.run_callbacks_for_success(self) do
        end
      end
    end

    # :nodoc:
    def error!
      if parent?
        parent.source.run_callbacks_for_error(self) do
        end
        root_group.abort if context.aborts_on_error?
      end
    end

    # :nodoc:
    def show_dir
      current_dir = context.current_dir? || Dir.current
      if File.real_path(context.chdir) != File.real_path(current_dir)
        output.puts "\u{1F4C2} #{context.chdir}"
      end
    end

    # :nodoc:
    def show_command
      a = [context.command]
      a += context.args if context.args.size > 0
      output.puts a.join(" ")
    end

    # Returns the exit status returned by the running process.
    #
    # Returns nil if the process is not terminated.
    getter? exit_code : Int32?

    # Returns the exit status returned by the running process.
    #
    # It waits for the running process to terminate.
    def exit_code : Int32?
      @exit_code if wait
    end

    # Tests if the running process is successfully terminated.
    #
    # It waits for the running process to terminate.
    def success?
      exit_code == 0
    end

    # Aborts this process.
    def abort(signal : Signal? = nil)
      @abort_mutex.synchronize do
        if @aborted.nil?
          if unstart && !terminated?
            if parent?
              parent.source.run_callbacks_for_abort(self) do
                _abort signal
              end
            else
              _abort signal
            end
          else
            @aborted = false
          end
        end
      end
    end

    # :nodoc:
    def _abort(signal)
      kill signal
      begin
        context.abort_timeout.try_and_wait(interval: 0.1, prewait: 0.1) do
          break true unless exists?
        end
      rescue Timeout::Elapsed
      end
      @aborted = true
    end

    # Kills this process.
    def kill(signal : Signal? = nil)
      begin
        kill! signal
      rescue ex : Errno
        raise ex if ex.errno != Errno::ESRCH
      end
    end

    # Kills this process.
    #
    # Raises an Errno (ESRCH) exception if no process or process group can be found.
    def kill!(signal : Signal? = nil)
      impl.kill signal || context.abort_signal if exists?
    end

    # Tests if the running process exists.
    def exists?
      started? && !terminated? && !aborted? && impl.exists?
    end

    # Tests if the running process is terminated.
    def terminated?
      exit_code?
    end
  end
end
