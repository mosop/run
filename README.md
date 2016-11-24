# Crystal Run

A Crystal library for running commands in reusable contexts.

[![Build Status](https://travis-ci.org/mosop/run.svg?branch=master)](https://travis-ci.org/mosop/run)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  run:
    github: mosop/run
```

## Code Samples

### Smiley

```crystal
cmd = Run::Command.new("echo", [":)"])
cmd.run.wait # => prints ":)"
```

### Additional Arguments

```crystal
cmd = Run::Command.new("echo", [":)"])
%w(hello goodbye).each do |i|
  cmd.run(args: [i]).wait
end
```

This prints:

```
:) hello
:) goodbye
```

### Over and Over

```crystal
cmd = Run::Command.new("echo", [":)"])
100.times do
  cmd.run.wait
end
```

This prints 100 of :).

### Multiple at Once

```crystal
cg = Run::CommandGroup.new
100.times do
  cg.command "echo", [":)"]
end
cg.run
```

This prints 100 of :) too.

### Relative Paths

```crystal
cg = Run::CommandGroup.new(chdir: "path")
cg.command "pwd"
cg.command "pwd", chdir: "to"
cg.command "pwd", chdir: ".."
cg.run
```

If the current directory is */Users/mosop*, this code prints:

```
/Users/mosop/path
/Users/mosop/path/to
/Users/mosop
```

### Async

```crystal
cg = Run::CommandGroup.new
cg.command "wget", %w(http://mosop.rocks)
cg.command "wget", %w(http://mosop.yoga)
cg.command "wget", %w(http://mosop.ninja)
process_group = cg.run(async: true)

# do another thing

process_group.wait
```

Note: Running a single command is always asynchronous and you need to manually wait.

```crystal
cmd = Run::Command.new("sleep", %w(100))
process = cmd.run
process.wait
```

### Group of Group

```crystal
dirs = %w(foo bar baz)
cg = Run::CommandGroup.new do |g|
  g.group do |g| # synchronous builds
    dirs.each do |dir|
      g.command "npm", %w(run build), chdir: dir
    end
  end
  g.group(async: true) do |g| # asynchronous watches
    dirs.each do |dir|
      g.command "npm", %w(run watch), chdir: dir
    end
  end
end
cg.run.wait
```

## Usage

```crystal
require "run"
```

And see [Features](#features) and [Wiki](https://github.com/mosop/run/wiki)!

## Contributing

1. Fork it ( https://github.com/mosop/run/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
