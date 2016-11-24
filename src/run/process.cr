module Run
  class Process
    getter context : Context
    getter? impl : ::Process?
    getter channel = Channel(Int32).new

    def initialize(@context)
    end

    def impl
      @impl.as(::Process)
    end

    def do_exec
      Dir.mkdir_p context.chdir
      show_dir if context.shows_dir
      show_command if context.shows_command
      yield
    end

    def exec
      do_exec do
        ::Process.exec(**context.to_exec_args)
      end
    end

    def run
      do_exec do
        @impl = ::Process.new(**context.to_run_args)
        ::future do
          channel.send impl.wait.exit_code
        end
      end
    end

    def show_dir
      current_dir = context.current_dir? || Dir.current
      if File.real_path(context.chdir) != File.real_path(current_dir)
        puts "\u{1F4C2} #{context.chdir}"
      end
    end

    def show_command
      a = [context.command]
      a += context.args if context.args.size > 0
      puts a.join(" ")
    end

    @exit_code : Int32? = nil
    def exit_code?
      @exit_code ||= receive_and_close?
    end

    def exit_code
      @exit_code ||= receive_and_close
    end

    def wait
      @exit_code ||= receive_and_close
    end

    def receive_and_close?
      channel.receive?.tap do |status|
        channel.close if status
      end
    end

    def receive_and_close
      channel.receive.tap do |status|
        channel.close
      end
    end

    def success?
      exit_code == 0
    end

    def abort(signal = nil)
      impl.kill signal || context.signal_on_abort || Signal::TERM
    end
  end
end
