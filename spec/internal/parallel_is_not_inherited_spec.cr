require "../spec_helper"

module RunWikiInternalParallelIsNotInheritedFeature
  it name do
    Stdio.capture do |io|
      c = Run::Context.new(parallel: true)
      Run::Context.new.parent(c).parallel?.should be_false
      cg = Run::CommandGroup.new(parallel: true) do |g|
        g.group
      end
      process = cg.run
      process.context.parallel?.should be_true
      process.process_groups.first.context.parallel?.should be_false
    end
  end
end
