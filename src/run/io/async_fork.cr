module Run
  struct Io
    # :nodoc:
    class AsyncFork
      @future : Concurrent::Future(Fork)

      def initialize(@future)
      end

      @fork : Fork?
      def fork
        @fork ||= @future.get
      end

      def pipe
        fork.pipe
      end

      def pipe?
        fork.pipe?
      end

      def child
        fork.child
      end

      def child?
        fork.child?
      end

      def reopen_input(stdio)
        fork.reopen_input stdio
      end

      def reopen_output(stdio)
        fork.reopen_output stdio
      end

      def reopen_error(stdio)
        fork.reopen_error stdio
      end

      def close_child
        fork.close_child
      end
    end
  end
end
