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

  # Waits for all processes.
  def self.wait(signal = nil)
    @@processes.dup.each do |process|
      process.wait
    end
  end
end
