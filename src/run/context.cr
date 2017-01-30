module Run
  # Represents a set of combinable attributes that determines how a command executes.
  #
  # ### Attributes
  #
  # #### command_name
  #
  # A command name. If given in multiple nested contexts, the nearest one is used.
  #
  # #### args
  #
  # Command arguments. If given in multiple nested contexts, all the values are concatenated from the earliest ancestor context.
  #
  # #### env
  #
  # Environment variables. If given in multiple nested contexts, all the values are merged from the earliest ancestor context.
  #
  # #### clear_env
  #
  # Specifies whether to pass the current environment variables to forked processes. If true, the variables are not passed. If given in multiple nested contexts, the nearest one is used. The default value is false.
  #
  # #### input, output, error
  #
  # Specifies IOs passed to forked processes.
  #
  # The types are:
  #
  # * `Run::Io::PIPE` : a new pipe
  # * an arbitrary IO object
  # * true or `Run::Io::PARENT` : the standard IO of the current process
  # * false or `Run::Io::NULL` : no IO (/dev/null)
  #
  # If given in multiple nested contexts, the nearest one is used. The default value is `Run::Io::PARENT`.
  #
  # #### shell
  #
  # Specifies whether to run commands in the system's shell. If given in multiple nested contexts, the nearest one is used. The default value is true.
  #
  # #### chdir
  #
  # A working directory's path. If given in multiple nested contexts, all the paths are joined, with File.expand_path, from the earliest ancestor context.
  #
  # If the joined path is relative, the path is expanded with the current directory's path.
  #
  # #### parallel
  #
  # Specifies whether to run child commands asynchronously. Even if given in parent contexts, the current context's value is always used. The default value is false.
  #
  # Note: This attribute is only for command groups.
  #
  # #### abort_on_error
  #
  # Specifies whether to abort all processes when the process returns an error. If given in multiple nested contexts, the nearest one is used. The default value is false.
  #
  # #### abort_wait
  #
  # Specifies how it waits for processes to abort. If given in multiple nested contexts, the nearest one is used. The default value is `Run::NO_WAIT`.
  #
  # #### abort_signal
  #
  # A signal number that is sent on abort. If given in multiple nested contexts, the nearest one is used. The default value is Signal::TERM.
  #
  # #### attempt
  #
  # Specifies how it attempts to start a process again when failed. Even if given in parent contexts, the current context's value is always used. The default value is `Run::NO_RETRY`.
  class Context
    alias Name = String | Symbol
    alias NameArg = Name?

    # Initializes a new context with the attributes.
    #
    # For more information about the arguments, see `#set`.
    def initialize(**attributes)
      set **attributes
    end

    # Returns this parent context.
    getter? parent : Context?

    # Returns this parent context.
    #
    # It raises an exception if this context is the root.
    def parent
      parent?.as(Context)
    end

    # Tests if this context is the root in the nested contexts.
    def root?
      parent?.nil?
    end

    # Returns the root context in the nested contexts.
    def root : Context
      root? ? self : parent.root
    end

    # Sets the attributes and returns self.
    #
    # If nil is specified, the attribute is not changed.
    #
    # For more information about the attributes, see [Wiki](https://github.com/mosop/run/wiki/Context-Attributes).
    def set(
      name : NameArg = nil,
      command : String? = nil,
      args : Array(String)? = nil,
      parent : Context? = nil,
      env : Hash(String, String)? = nil,
      clear_env : Bool? = nil,
      shell : Bool? = nil,
      input : Io::Arg = nil,
      output : Io::Arg = nil,
      error : Io::Arg = nil,
      chdir : String? = nil,
      show_dir : Bool? = nil,
      show_command : Bool? = nil,
      abort_signal : Signal? = nil,
      parallel : Bool? = nil,
      abort_on_error : Bool? = nil,
      abort_wait : Attempt? = nil,
      attempt : Attempt? = nil
    )
      @name = name.to_s unless name.nil?
      @command = command unless command.nil?
      @args = args unless args.nil?
      @parent = parent unless parent.nil?
      @env = env unless env.nil?
      @clear_env = clear_env unless clear_env.nil?
      @shell = shell unless shell.nil?
      @input = Io.parse_arg(input) unless input.nil?
      @output = Io.parse_arg(output) unless output.nil?
      @error = Io.parse_arg(error) unless error.nil?
      @chdir = chdir unless chdir.nil?
      @show_dir = show_dir unless show_dir.nil?
      @show_command = show_command unless show_command.nil?
      @abort_signal = abort_signal unless abort_signal.nil?
      @parallel = parallel unless parallel.nil?
      @abort_on_error = abort_on_error unless abort_on_error.nil?
      @abort_wait = abort_wait unless abort_wait.nil?
      @attempt = attempt unless attempt.nil?
      self
    end

    # :nodoc:
    def set(context : Context)
      set **context.to_args
    end

    # Copies this context.
    def dup
      Context.new(**to_args)
    end

    # :nodoc:
    def to_args
      {
        name: @name,
        command: @command,
        args: @args,
        parent: @parent,
        env: @env,
        clear_env: @clear_env,
        shell: @shell,
        input: @input,
        output: @output,
        error: @error,
        chdir: @chdir,
        abort_signal: @abort_signal,
        show_dir: @show_dir,
        show_command: @show_command,
        parallel: @parallel,
        abort_on_error: @abort_on_error,
        abort_wait: @abort_wait,
        attempt: @attempt
      }
    end

    # :nodoc:
    def to_exec_args
      {
        command: command,
        args: args,
        env: env,
        clear_env: clears_env?,
        shell: shell?,
        input: input.for_exec,
        output: output.for_exec,
        error: error.for_exec,
        chdir: chdir
      }
    end

    # :nodoc:
    def exec
      ::Process.exec(**to_exec_args)
    end

    # :nodoc:
    def each
      current = self
      loop do
        yield current
        return if current.root?
        current = current.parent
      end
    end

    # :nodoc:
    macro __get_by_each(attr, type, default)
      each do |i|
        return i.self_{{attr.id}}.as({{type}}) unless i.self_{{attr.id}}.nil?
      end
      {{default}}
    end

    # :nodoc:
    macro __property(name, type, combined_type = nil, getter = true, parse_arg = false, &block)
      {%
        name = name.id
        var = "@#{name}".id
        arg_type = parse_arg ? "#{type}::Arg".id : type
        combined_type = arg_type unless combined_type
      %}

      # Sets the {{name}} attribute.
      def {{name}}=(value : {{arg_type}}?)
        {% if parse_arg %}
        {{var}} = {{type}}.parse_arg(value)
        {% else %}
        {{var}} = value
        {% end %}
      end

      # Sets the {{name}} attribute and returns self.
      def {{name}}(value : {{arg_type}}?)
        self.{{name}}= value
        self
      end

      {% if getter %}
      # Returns the {{name}} attribute.
      def self_{{name}} : {{arg_type}}?
        {{var}}
      end

      # Returns the combined value of the {{name}} attribute in the nested context.
      def {{name}} : {{combined_type}}
        {{block.body}}
      end
      {% end %}
    end

    # :nodoc:
    macro __property?(name, verb = nil, &block)
      {%
        name = name.id
        predicate = (verb || name).id
        negate = verb ? "not_to_#{verb.id}".id : "not_#{name}".id
        var = "@#{name}".id
      %}

      # Sets the {{name}} attribute to true and returns self.
      def {{name}}! : Context
        {{var}} = true
        self
      end

      # Sets the {{name}} attribute to false and returns self.
      def {{negate}}! : Context
        {{var}} = false
        self
      end

      # Sets the {{name}} attribute and returns self.
      def {{name}}(value : Bool?) : Context
        {{var}} = value
        self
      end

      # Returns the {{name}} attribute.
      def self_{{name}} : Bool?
        {{var}}
      end

      # Returns the combined value of the {{name}} attribute in the context.
      def {{predicate}}? : Bool
        {{block.body}}
      end
    end

    __property :name, String, String? do
      self_name
    end

    __property :command, String do
      self_command || (root? ? (raise "No command.") : parent.command)
    end

    __property :args, Array(String) do
      root? ? self_args_or_default : parent.args + self_args_or_default
    end

    __property :parent, Context, getter: false {}

    __property :env, Hash(String, String) do
      root? ? self_env_or_default : parent.env.merge(self_env_or_default)
    end

    __property? :clear_env, :clears_env do
      __get_by_each :clear_env, Bool, false
    end

    __property? :shell do
      __get_by_each :shell, Bool, true
    end

    __property :input, Io, parse_arg: true do
      __get_by_each :input, Io, Io::PARENT
    end

    __property :output, Io, parse_arg: true do
      __get_by_each :output, Io, Io::PARENT
    end

    __property :error, Io, parse_arg: true do
      __get_by_each :error, Io, Io::PARENT
    end

    __property :chdir, String do
      File.expand_path(self_chdir || "", root? ? Dir.current : parent.chdir)
    end

    __property? :show_dir, :shows_dir do
      __get_by_each :show_dir, Bool, false
    end

    __property? :show_command, :shows_command do
      __get_by_each :show_command, Bool, false
    end

    __property :abort_signal, Signal do
      __get_by_each :abort_signal, Signal, Signal::TERM
    end

    __property? :parallel do
      !!self_parallel
    end

    __property? :abort_on_error, :aborts_on_error do
      __get_by_each :abort_on_error, Bool, false
    end

    __property :abort_wait, Attempt do
      __get_by_each :abort_wait, Attempt, Run::NO_WAIT
    end

    __property :attempt, Attempt do
      self_attempt || Run::NO_RETRY
    end

    # :nodoc:
    def self_args_or_default
      self_args || %w()
    end

    # :nodoc:
    def self_env_or_default
      self_env || {} of String => String
    end
  end
end
