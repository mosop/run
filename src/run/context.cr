class Run::Context
  # :nodoc:
  getter? command : String?
  # :nodoc:
  getter? args : Array(String)?
  # :nodoc:
  getter? parent : Context?
  # :nodoc:
  getter? env : Hash(String, String)?
  # :nodoc:
  getter? clear_env : Bool?
  # :nodoc:
  getter? shell : Bool?
  # :nodoc:
  getter? input : Io?
  # :nodoc:
  getter? output : Io?
  # :nodoc:
  getter? error : Io?
  # :nodoc:
  getter? chdir : String?
  # :nodoc:
  getter? shows_dir : Bool?
  # :nodoc:
  getter? shows_command : Bool?
  # :nodoc:
  getter? abort_signal : Signal?
  # :nodoc:
  getter? parallel : Bool?
  # :nodoc:
  getter? aborts_on_error : Bool?
  # :nodoc:
  getter? abort_timeout : Timeout?
  # :nodoc:
  getter? current_dir : String?

  # :nodoc:
  def initialize(**options)
    set **options
  end

  # :nodoc:
  def initialize(command, **options)
    @command = command
    set **options
  end

  # :nodoc:
  def initialize(command, args, **options)
    @command = command
    @args = args
    set **options
  end

  # :nodoc:
  def root?
    parent?.nil?
  end

  # :nodoc:
  def root
    root? ? self : parent.root
  end

  # :nodoc:
  def parent
    parent?.as(Context)
  end

  # Sets attributes to this context.
  #
  # If nil is specified, the attribute is not changed.
  #
  # For more information about the context attributes, see [Wiki](https://github.com/mosop/run/wiki/Context-Attributes).
  def set(command : String? = nil, args : Array(String)? = nil, parent : Context? = nil, env : Hash(String, String)? = nil, clear_env : Bool? = nil, shell : Bool? = nil, input : Io::Arg = nil, output : Io::Arg = nil, error : Io::Arg = nil, chdir : String? = nil, show_dir : Bool? = nil, show_command : Bool? = nil, abort_signal : Signal? = nil, parallel : Bool? = nil, abort_on_error : Bool? = nil, abort_timeout : Timeout::Arg = nil, current_dir : String? = nil)
    @args = args unless args.nil?
    @parent = parent unless parent.nil?
    @env = env unless env.nil?
    @clear_env = clear_env unless clear_env.nil?
    @shell = shell unless shell.nil?
    @input = Io.parse_arg(input) unless input.nil?
    @output = Io.parse_arg(output) unless output.nil?
    @error = Io.parse_arg(error) unless error.nil?
    @chdir = chdir unless chdir.nil?
    @shows_dir = show_dir unless show_dir.nil?
    @shows_command = show_command unless show_command.nil?
    @abort_signal = abort_signal unless abort_signal.nil?
    @parallel = parallel unless parallel.nil?
    @aborts_on_error = abort_on_error unless abort_on_error.nil?
    @abort_timeout = Timeout.parse_arg(abort_timeout) unless abort_timeout.nil?
    @current_dir = current_dir unless current_dir.nil?
    self
  end

  # Copies this context.
  def dup
    Context.new(**to_args)
  end

  # :nodoc:
  def to_args
    {
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
      show_dir: @shows_dir,
      show_command: @shows_command,
      parallel: @parallel,
      abort_on_error: @aborts_on_error,
      abort_timeout: @abort_timeout,
      current_dir: @current_dir
    }
  end

  # :nodoc:
  def to_exec_args
    {
      command: command,
      args: args,
      env: env,
      clear_env: clear_env,
      shell: shell,
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

  def command
    @command || (root? ? (raise "No command.") : parent.command)
  end

  def self_args
    @args || %w()
  end

  def args
    root? ? self_args :  parent.args + self_args
  end

  def self_env
    @env || {} of String => String
  end

  def env
    root? ? self_env : parent.env.merge(self_env)
  end

  def clear_env
    __get_by_each :clear_env, Bool, false
  end

  def shell
    __get_by_each :shell, Bool, true
  end

  def input
    __get_by_each :input, Io, Io::PARENT
  end

  def output
    __get_by_each :output, Io, Io::PARENT
  end

  def error
    __get_by_each :error, Io, Io::PARENT
  end

  def chdir
    File.expand_path(@chdir || "", root? ? Dir.current : parent.chdir)
  end

  def shows_dir
    __get_by_each :shows_dir, Bool, false
  end

  def shows_command
    __get_by_each :shows_command, Bool, false
  end

  def abort_signal
    __get_by_each :abort_signal, Signal, Signal::TERM
  end

  def parallel
    __get_by_each :parallel, Bool, false
  end

  def aborts_on_error
    __get_by_each :aborts_on_error, Bool, false
  end

  def abort_timeout
    __get_by_each :abort_timeout, Timeout, Timeout::NO_WAIT
  end

  # :nodoc:
  macro __get_by_each(attr, type, default)
    each do |i|
      return i.{{attr.id}}?.as({{type}}) unless i.{{attr.id}}?.nil?
    end
    {{default}}
  end
end
