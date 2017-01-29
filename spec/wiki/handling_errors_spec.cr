require "../spec_helper"

module RunWikiHandlingErrorsFeature
  module Abort
    describe name do
      it "serial" do
        Stdio.capture do |io|
          cg = Run.group do |g|
            g.command "fail", error: false, abort_on_error: true
            g.command "echo", %w(goodbye)
          end
          cg.run.wait
          io.out.gets_to_end.should eq ""
        end
      end

      it "parallel" do
        cg = Run.group do |g|
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
