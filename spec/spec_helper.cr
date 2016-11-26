require "spec"
require "stdio"
require "crystal_plus/dir/.tmp"
require "../src/run"

TRAP_SIGNAL = File.expand_path("#{__DIR__}/../bin/trap-signal")
