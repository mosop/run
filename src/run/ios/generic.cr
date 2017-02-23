module Run
  module Ios
    # :nodoc:
    struct Generic < Io
      @io : IO

      def initialize(@io : IO)
      end

      def for_exec
        false
      end

      def for_run
        @io
      end

      def fork_input
        io = @io
        r, w = IO.pipe(read_blocking: true)
        f = future do
          begin
            IO.copy(io, w)
            Fork.new(self, w, r)
          rescue ex
            Fork.new(self, w, r, exception: ex)
          ensure
            w.close
          end
        end
        AsyncFork.new(f)
      end

      def fork_output
        io = @io
        r, w = IO.pipe(write_blocking: true)
        f = future do
          begin
            IO.copy(io, r)
            Fork.new(self, r, w)
          rescue ex
            Fork.new(self, r, w, exception: ex)
          ensure
            w.close
          end
        end
        AsyncFork.new(f)
      end

      def fork_error
        fork_output
      end

      def reopen_input(stdio, fork)
        fork.child.blocking = true
        reopen stdio, fork.child
      end

      def reopen_output(stdio, fork)
        fork.child.blocking = true
        reopen stdio, fork.child
      end

      def reopen_error(stdio, fork)
        reopen_output stdio, fork
      end

      def input_for_process?(p)
        if p
          p.input?
        end
      end

      def output_for_process?(p)
        if p
          p.output?
        end
      end

      def error_for_process?(p)
        if p
          p.error?
        end
      end
    end
  end
end
