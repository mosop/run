require "../spec_helper"

module RunWikiInternalNameIsNotInheritedFeature
  it name do
    Stdio.capture do |io|
      c = Run::Context.new(name: "name")
      Run::Context.new.parent(c).name.should be_nil
      cg = Run::CommandGroup.new(name: "group") do |g|
        g.group
        g.command name: "command", command: "echo"
      end
      process = cg.run
      process.wait
      process.context.name.should eq "group"
      process.process_groups.first.context.name.should be_nil
      process.processes.first.context.name.should eq "command"
    end
  end
end
