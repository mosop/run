require "../spec_helper"

module RunWikiHandlingErrorsFeature
  module Abort
    describe name do
      it "parallel" do
        cg = Run::CommandGroup.new(abort_timeout: 5) do |g|
          g.command "sleep", %w(60)
          g.command "fail", error: false, abort_on_error: true
        end
        pg = cg.run(parallel: true)
        pg.wait
        pg[0].aborted?.should be_true
        pg[1].aborted?.should be_falsey
      end
    end
  end
end
