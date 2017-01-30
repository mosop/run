require "../spec_helper"

module RunInternalSpecAttempt
  describe name do
    it "works" do
      count = 0
      cg = Run.group(parallel: true) do |g|
        g.future(attempt: Attempt.times(2)) do
          count += 1
          count == 2 ? 0 : 1
        end
      end
      pg = cg.run
      pg.wait
      count.should eq 2
      pg.processes[0].success?.should be_true
    end
  end
end
