module Run
  struct Io
    struct Fork
      @io : Io
      getter! piped : IO::FileDescriptor?
      getter! child : IO::FileDescriptor?
      getter! exception : Exception?

      def initialize(@io, @piped, @child, @exception = nil)
      end

      def reopen_input(stdio)
        @io.reopen_input stdio, self
      end

      def reopen_output(stdio)
        @io.reopen_output stdio, self
      end

      def reopen_error(stdio)
        @io.reopen_error stdio, self
      end

      def close_child
        if child = @child
          child.close
          @child = nil
        end
      end
    end
  end
end
