module Run
  struct Io
    # :nodoc:
    struct Null < Io
      def for_exec
        false
      end

      def for_run
        false
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
        File.open("/dev/null", "rw") do |f|
          reopen stdio, f
        end
      end

      def reopen_output(stdio, fork)
        File.open("/dev/null", "rw") do |f|
          reopen stdio, f
        end
      end

      def reopen_error(stdio, fork)
        reopen_output stdio, fork
      end

      def input_for_process?(p)
      end

      def output_for_process?(p)
      end

      def error_for_process?(p)
      end
    end
  end
end
