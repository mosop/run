require "../spec_helper"

module RunWikiHandlingErrorsFeature
  module Abort
    describe name do
      it "parallel" do
        cg = Run::CommandGroup.new(abort_timeout: 5) do |g|
          g.command TRAP_SIGNAL
          g.command "fail", abort_on_error: true
        end
        pg = cg.run(parallel: true)
        pg.wait
        p = pg[0]
        p.output.rewind
        # p.output.gets_to_end.should eq "15\n"
      end
    end
  end
end
