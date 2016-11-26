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

<a name="code_samples"></a>

## Code Samples

### Smiley

```crystal
cmd = Run::Command.new("echo", [":)"])
cmd.run.wait # => prints ":)"
```

### Addition

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
cg.run.wait
```

This prints 100 of :) too.

### Nested Contexts

```crystal
cg = Run::CommandGroup.new(chdir: "path")
cg.command "pwd"
cg.command "pwd", chdir: "to"
cg.command "pwd", chdir: ".."
cg.run.wait
```

If the current directory is */Users/mosop*, this code prints:

```
/Users/mosop/path
/Users/mosop/path/to
/Users/mosop
```

### Parallel

```crystal
cg = Run::CommandGroup.new
cg.command "wget", %w(http://mosop.rocks)
cg.command "wget", %w(http://mosop.yoga)
cg.command "wget", %w(http://mosop.ninja)
process_group = cg.run(parallel: true)

# do another thing

process_group.wait
```

```crystal
cmd = Run::Command.new("sleep", %w(100))
process = cmd.run
process.wait
```

## Usage

```crystal
require "run"
```

And see [Code Samples](#code_samples), [Wiki](https://github.com/mosop/run/wiki) and [API Document](http://mosop.me/run/Run.html)!

## Release Notes

See [Releases](https://github.com/mosop/run/releases)

## Contributing

1. Fork it ( https://github.com/mosop/run/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
