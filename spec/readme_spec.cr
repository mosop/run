require "./spec_helper"

module RunReadmeFeature
  module Smiley
    it name do
      Stdio.capture do |io|
        cmd = Run::Command.new("echo", [":)"])
        cmd.run.wait
        io.out.gets_to_end.should eq ":)\n"
      end
    end
  end

  module Addition
    it name do
      Stdio.capture do |io|
        cmd = Run::Command.new("echo", [":)"])
        %w(hello goodbye).each do |i|
          cmd.run(args: [i]).wait
        end
        io.out.gets_to_end.should eq <<-EOS
        :) hello
        :) goodbye\n
        EOS
      end
    end
  end

  module OverAndOver
    it name do
      Stdio.capture do |io|
        cmd = Run::Command.new("echo", [":)"])
        100.times do
          cmd.run.wait
        end
        io.out.gets_to_end.should eq ":)\n" * 100
      end
    end
  end

  module MultipleAtOnce
    it name do
      Stdio.capture do |io|
        cg = Run::CommandGroup.new
        100.times do
          cg.command "echo", [":)"]
        end
        cg.run
        io.out.gets_to_end.should eq ":)\n" * 100
      end
    end
  end

  module NestedContexts
    it name do
      Dir.tmp do |dir|
        dir = File.real_path(dir)
        Stdio.capture do |io|
          cg = Run::CommandGroup.new(chdir: "#{dir}/path")
          cg.command "pwd"
          cg.command "pwd", chdir: "to"
          cg.command "pwd", chdir: ".."
          cg.run
          io.out.gets_to_end.should eq <<-EOS
          #{dir}/path
          #{dir}/path/to
          #{dir}\n
          EOS
        end
      end
    end
  end

  module Async
    #   ### Async
    #
    #   ```crystal
    #   cg = Run::CommandGroup.new
    #   cg.command "wget", %w(http://mosop.rocks)
    #   cg.command "wget", %w(http://mosop.yoga)
    #   cg.command "wget", %w(http://mosop.ninja)
    #   process_group = cg.run(async: true)
    #
    #   # do another thing
    #
    #   process_group.wait
    #   ```
    #
    #   Note: Running a single command is always asynchronous and you need to manually wait.
    #
    #   ```crystal
    #   process = Run::Command.new("sleep", %w(100)).run
    #   process.wait
    #   ```
  end

  module GroupOfGroup
    #   ### Group of Group
    #
    #   ```crystal
    #   dirs = %w(foo bar baz)
    #   cg = Run::CommandGroup.new do |g|
    #     g.group(async: true) do |g|
    #       dirs.each do |dir|
    #         g.command "npm", %w(run build), chdir: dir
    #       end
    #     end
    #     g.group(async: true) do |g|
    #       dirs.each do |dir|
    #         g.command "npm", %w(run watch), chdir: dir
    #       end
    #     end
    #   end
    #   cg.run.wait
    #   ```
  end
end
