module Run
  module Ios
    # :nodoc:
    struct Fd < Io
      @io : IO::FileDescriptor

      def initialize(@io : IO::FileDescriptor)
      end

      def for_exec
        @io
      end

      def for_run
        @io
      end

      def fork_input
        Fork.new(self, @io, @io)
      end

      def fork_output
        Fork.new(self, @io, @io)
      end

      def fork_error
        fork_output
      end

      def reopen_input(stdio, fork)
        @io.blocking = true
        reopen stdio, @io
      end

      def reopen_output(stdio, fork)
        @io.blocking = true
        reopen stdio, @io
      end

      def reopen_error(stdio, fork)
        reopen_output stdio, fork
      end

      def input_for_process?(p)
        @io
      end

      def output_for_process?(p)
        @io
      end

      def error_for_process?(p)
        @io
      end
    end
  end
end
