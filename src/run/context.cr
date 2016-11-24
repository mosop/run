class Run::Context
  getter? command : String?
  getter? args : Array(String)?
  getter? parent : Context?
  getter? env : Hash(String, String)?
  getter? clear_env : Bool?
  getter? shell : Bool?
  getter? input : Io?
  getter? output : Io?
  getter? error : Io?
  getter? chdir : String?
  getter? shows_dir : Bool?
  getter? shows_command : Bool?
  getter? signal_on_abort : Signal?
  getter? async : Bool?
  getter? aborts_on_error : Bool?
  getter? current_dir : String?

  def initialize(**options)
    set **options
  end

  def initialize(command, **options)
    @command = command
    set **options
  end

  def initialize(command, args, **options)
    @command = command
    @args = args
    set **options
  end

  def parent(parent)
    @parent = parent
    self
  end

  def current_dir(dir)
    @current_dir = dir
    self
  end

  def root?
    parent?.nil?
  end

  def root
    root? ? self : parent.root
  end

  def parent
    parent?.as(Context)
  end

  def set(command = nil, args = nil, parent = nil, env = nil, clear_env = nil, shell = nil, input = nil, output = nil, error = nil, chdir = nil, show_dir = nil, show_command = nil, signal_on_abort = nil, async = nil, abort_on_error = nil, current_dir = nil)
    @args = args unless args.nil?
    @parent = parent unless parent.nil?
    @env = env unless env.nil?
    @clear_env = clear_env unless clear_env.nil?
    @shell = shell unless shell.nil?
    @input = Io.parse_arg(@input, input)
    @output = Io.parse_arg(@output, output)
    @error = Io.parse_arg(@error, error)
    @chdir = chdir unless chdir.nil?
    @shows_dir = show_dir unless show_dir.nil?
    @shows_command = show_command unless show_command.nil?
    @signal_on_abort = signal_on_abort unless signal_on_abort.nil?
    @async = async unless async.nil?
    @aborts_on_error = abort_on_error unless abort_on_error.nil?
    @current_dir = current_dir unless current_dir.nil?
    self
  end

  def dup
    Context.new(**to_args)
  end

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
      signal_on_abort: @signal_on_abort,
      show_dir: @shows_dir,
      show_command: @shows_command,
      async: @async,
      abort_on_error: @aborts_on_error,
      current_dir: @current_dir
    }
  end

  def to_exec_args
    {
      command: command,
      args: args,
      env: env,
      clear_env: clear_env,
      shell: shell,
      input: input(&.for_exec),
      output: output(&.for_exec),
      error: error(&.for_exec),
      chdir: chdir
    }
  end

  def to_run_args
    {
      command: command,
      args: args,
      env: env,
      clear_env: clear_env,
      shell: shell,
      input: input(&.for_run),
      output: output(&.for_run),
      error: error(&.for_run),
      chdir: chdir
    }
  end

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
    each do |i|
      return yield Io.from_arg(i.input?) unless i.input?.nil?
    end
    true
  end

  def output
    each do |i|
      return yield Io.from_arg(i.output?) unless i.output?.nil?
    end
    true
  end

  def error
    each do |i|
      return yield Io.from_arg(i.error?) unless i.error?.nil?
    end
    true
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

  def signal_on_abort
    __get_by_each :signal_on_abort, Signal, nil
  end

  def async
    __get_by_each :async, Bool, false
  end

  def aborts_on_error
    __get_by_each :aborts_on_error, Bool, false
  end

  macro __get_by_each(attr, type, default)
    each do |i|
      return i.{{attr.id}}?.as({{type}}) unless i.{{attr.id}}?.nil?
    end
    {{default}}
  end
end
