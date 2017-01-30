module Run
  @@processes = [] of AsProcess

  # :nodoc:
  def self.processes
    @@processes
  end

  # :nodoc:
  def self.<<(process : AsProcess)
    @@processes << process
  end

  # :nodoc:
  def self.<<(process : ProcessGroup)
  end

  # Aborts all processes.
  def self.abort(signal = nil)
    @@processes.dup.each do |process|
      process.abort signal
    end
  end
end
