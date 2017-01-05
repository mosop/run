require "../spec_helper"

module RunInternalSpecAbortOnError
  describe name do
    it "works" do
      cg = Run.group(parallel: true) do |g|
        g.command "/bin/bash", ["-c", "exit 1"], abort_on_error: true
        g.command "/bin/bash", ["-c", "trap 'exit 1' TERM ; while : ; do : ; done"]
      end
      pg = cg.run
      pg.wait
      pg.processes[1].aborted?.should be_true
    end
  end
end
