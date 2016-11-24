module Run
  class ProcessGroup
    getter commands : CommandGroup
    getter context : Context
    getter group_context : Context
    getter? aborted : Bool?
    @channel : Channel(Bool)

    def initialize(@commands, @context)
      @group_context = @context.dup.parent(commands.context)
      @channel = Channel(Bool).new(@commands.size)
    end

    getter processes = [] of (Process | ProcessGroup)
    getter running = [] of (Process | ProcessGroup)
    getter exited = [] of (Process | ProcessGroup)
    getter succeeded = [] of (Process | ProcessGroup)
    getter unsucceeded = [] of (Process | ProcessGroup)

    def run(**args)
      @group_context.async ? run_async : run_sync
    end

    def run_sync
      current_dir = Dir.current
      @commands.each do |cmd|
        cmd.run(**@context.current_dir(current_dir).to_args).tap do |process|
          wait_process process
          current_dir = process.context.chdir
        end
      end
      wait
    end

    def run_async
      @commands.each do |cmd|
        cmd.run(**@context.to_args).tap do |process|
          wait_process process
        end
      end
    end

    def wait_process(process)
      @processes << process
      @running << process
      if @group_context.async
        future do
          wait_process2 process
        end
      else
        wait_process2 process
      end
    end

    def wait_process2(process)
      process.wait
      @running.delete process
      @exited << process
      if process.success?
        @succeeded << process
      else
        @unsucceeded << process
      end
      @channel.send process.success? || !process.context.aborts_on_error
    end

    def wait
      while @running.size > 0
        return abort unless @channel.receive
      end
      @channel.close
    end

    def abort(signal = nil)
      @aborted = true
      @channel.close
      @running.each do |process|
        process.abort signal
      end
    end

    def success?
      return false if @aborted
      wait
      @commands.size == @succeeded.size
    end
  end
end
