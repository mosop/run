module Run
  module Ios
    # :nodoc:
    struct Pipe < Io
      def for_exec
        true
      end

      def for_run
      end

      def fork_input
        r, w = IO.pipe(read_blocking: true)
        Fork.new(self, w, r)
      end

      def fork_output
        r, w = IO.pipe(write_blocking: true)
        Fork.new(self, r, w)
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
