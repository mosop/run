require "../spec_helper"

module RunWikiCallbacksAndEventsFeature
  class WhatsWrong < Run::CommandGroup
    on_abort do |cg, pg|
      puts "what's wrong?"
    end

    on_abort_process do |cg, p|
      puts "what's wrong, #{p.context.command}?"
    end
  end

  it name do
    Stdio.capture do |io|
      cg = WhatsWrong.new
      cg.command "/bin/bash", ["-c", "exit 2"], abort_on_error: true
      cg.command "sleep", %w(100)
      cg.run.wait
      io.out.gets_to_end.should eq <<-EOS
      what's wrong?
      what's wrong, sleep?\n
      EOS
    end
  end
end
