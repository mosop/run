require "spec"
require "stdio"
require "crystal_plus/dir/.tmp"
require "../src/run"

# TRAP_SIGNAL = File.expand_path("#{__DIR__}/../bin/trap-signal")
TRAP_SIGNAL = File.expand_path("#{__DIR__}/../scripts/trap-signal")
SLEEP_AND_ERROR = File.expand_path("#{__DIR__}/../scripts/sleep-and-error")
