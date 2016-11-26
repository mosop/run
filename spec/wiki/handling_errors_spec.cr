require "../spec_helper"

module RunWikiHandlingErrorsFeature
  module Abort
    # cg = Run::CommandGroup.new do |g|
    #   g.command "wget", %w(http://essential.com), abort_on_error: true
    #   g.command "wget", %w(http://optional.com)
    # end
    # cg.run
    describe name do
      it "serial" do
        Stdio.capture do |io|
          cg = Run::CommandGroup.new do |g|
            g.command "fail", error: false, abort_on_error: true
            g.command "echo", %w(test)
          end
          io.out.gets_to_end.should eq ""
        end
      end

      it "parallel" do
        cg = Run::CommandGroup.new(abort_timeout: Run::Timeout::INFINITE) do |g|
          g.command TRAP_SIGNAL, output: IO::Memory.new
          g.command "fail", error: false, abort_on_error: true
        end
        pg = cg.run(parallel: true)
        pg.wait
        p = pg[0]
        p.output.rewind
        p.output.gets_to_end.should eq "15\n"
      end
    end
  end
end
