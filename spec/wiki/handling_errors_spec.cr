require "../spec_helper"

module RunWikiHandlingErrorsFeature
  module Abort
    describe name do
      it "parallel" do
        s = Stdio.capture do |io|
          cg = Run::CommandGroup.new(abort_timeout: 5) do |g|
            g.command TRAP_SIGNAL
            g.command "fail", abort_on_error: true
          end
          pg = cg.run(parallel: true)
          pg.wait
          p = pg[0]
          io.out.gets_to_end
          # p.output.rewind
          # p.output.gets_to_end.should eq "15\n"
        end
        puts "!!!"
        puts s
      end
    end
  end
end
