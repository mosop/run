module Run
  module Ios
    # :nodoc:
    struct Parent < Io
      def for_exec
        true
      end

      def for_run
        true
      end

      def fork_input
        Fork.new(self, nil, nil)
      end

      def fork_output
        Fork.new(self, nil, nil)
      end

      def fork_error
        Fork.new(self, nil, nil)
      end

      def reopen_input(stdio, fork)
        stdio.blocking = true
      end

      def reopen_output(stdio, fork)
        stdio.blocking = true
      end

      def reopen_error(stdio, fork)
        reopen_output stdio, fork
      end

      def input_for_process?(p)
        STDIN
      end

      def output_for_process?(p)
        STDOUT
      end

      def error_for_process?(p)
        STDERR
      end
    end
  end
end
