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

### Additional Arguments

```crystal
cmd = Run.command("echo", [":)"])
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
cmd = Run.command("echo", [":)"])
100.times do
  cmd.run.wait
end
```

This prints 100 of :).

### Multiple at Once

```crystal
cg = Run.group
100.times do
  cg.command "echo", [":)"]
end
cg.run.wait
```

This prints 100 of :) too.

### Nested Contexts

```crystal
cg = Run.group(chdir: "path")
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
cg = Run.group
cg.command "wget", %w(http://mosop.rocks)
cg.command "wget", %w(http://mosop.yoga)
cg.command "wget", %w(http://mosop.ninja)
process_group = cg.run(parallel: true)

# do other things

process_group.wait
```

## Usage

```crystal
require "run"
```

And see [Code Samples](#code_samples), [Wiki](https://github.com/mosop/run/wiki) and [API Document](http://mosop.me/run/Run.html)!

## Versioning Policy

See [Wiki](https://github.com/mosop/mosop.github.io/wiki/Versioning-Policy).

## Release Notes

See [Releases](https://github.com/mosop/run/releases).
