module Run
  @@processes = [] of Process

  # :nodoc:
  def self.processes
    @@processes
  end

  # :nodoc:
  def self.<<(process : ProcessLike)
    STDERR.puts process
    case process
    when Process
      @@processes << process
    when ProcessGroup
    end
  end

  # Aborts all processes.
  def self.abort(signal = nil)
    @@processes.dup.each do |process|
      process.abort signal
    end
  end
end
