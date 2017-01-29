require "./spec_helper"

module RunReadmeFeature
  module Smiley
    it name do
      Stdio.capture do |io|
        cmd = Run.command("echo", [":)"])
        cmd.run.wait
        io.out.gets_to_end.should eq ":)\n"
      end
    end
  end

  module AdditionalArguments
    it name do
      Stdio.capture do |io|
        cmd = Run.command("echo", [":)"])
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
        cmd = Run.command("echo", [":)"])
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
        cg = Run.group
        100.times do
          cg.command "echo", [":)"]
        end
        cg.run.wait
        io.out.gets_to_end.should eq ":)\n" * 100
      end
    end
  end

  module RelativePaths
    it name do
      Dir.tmp do |dir|
        dir = File.real_path(dir)
        Stdio.capture do |io|
          cg = Run.group(chdir: "#{dir}/path")
          cg.command "pwd"
          cg.command "pwd", chdir: "to"
          cg.command "pwd", chdir: ".."
          cg.run.wait
          io.out.gets_to_end.should eq <<-EOS
          #{dir}/path
          #{dir}/path/to
          #{dir}\n
          EOS
        end
      end
    end
  end

  module RunningCodeBlocks
    module InAFiber
      it name do
        Stdio.capture do |io|
          cg = Run.group
          100.times do
            cg.future do
              puts ":)"
              1
            end
          end
          cg.run.wait
          io.out.gets_to_end.should eq ":)\n" * 100
        end
      end
    end

    module InAFiber
      it name do
        Stdio.capture do |io|
          cg = Run.group
          100.times do
            cg.fork do
              puts ":)"
              1
            end
          end
          cg.run.wait
          io.out.gets_to_end.should eq ":)\n" * 100
        end
      end
    end
  end
end
