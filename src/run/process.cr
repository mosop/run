module Run
  class Process
    # Returns this parent group.
    getter? parent : ProcessGroup?

    # Returns this source command group.
    getter source : Command

    # Returns this context.
    getter context : Context

    # :nodoc:
    getter? impl : ::Process?

    # Tests if the running process is started.
    getter? started : Bool?

    # Waits for the running process to be started.
    def wait_to_start
      if @started.nil?
        @start_channel.receive
        @start_channel.close
      end
    end

    # :nodoc:
    getter? aborted : Bool?

    @start_channel = Channel(Nil).new(1)
    @wait_channel = Channel(Int32).new(1)
    @start_mutex = Mutex.new
    @abort_mutex = Mutex.new

    # :nodoc:
    def initialize(@parent, @source, @context)
    end

    # Returns this parent group.
    def parent : ProcessGroup
      @parent.as(ProcessGroup)
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
      show_dir if context.shows_dir
      show_command if context.shows_command
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
        clear_env: context.clear_env,
        shell: context.shell,
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
          @abort_mutex.synchronize do
            unless @aborted
              with_startup do
                @impl = new_impl
              end
            end
          end
          future do
            if impl = @impl
              @wait_channel.send impl.wait.exit_code
            end
          end
          @started = !!@impl
          @start_channel.send nil
        end
      end
      @started
    end

    # :nodoc:
    def unstart
      @start_mutex.synchronize do
        if @started.nil?
          @started = false
          @start_channel.send nil
        end
      end
      @started
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
    def exit_code : Int32
      @exit_code ||= receive_and_close
    end

    # Waits for the running process to terminate.
    def wait
      @exit_code ||= receive_and_close
    end

    # :nodoc:
    def receive_and_close
      @wait_channel.receive.tap do |status|
        @wait_channel.close
      end
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
        if started? && !aborted?
          if parent?
            parent.source.run_callbacks_for_abort_process(self) do
              _abort signal
            end
          else
            _abort signal
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

    # Kill this process.
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
      started? && !aborted? && !terminated? && impl.exists?
    end

    # Tests if the running process is terminated.
    def terminated?
      exit_code?
    end
  end
end
