require "../spec_helper"

module RunWikiCallbacksAndEventsFeature
  class WhatsWrong < Run::CommandGroup
    on_abort do |cg, pg|
      puts "what's wrong, #{pg[0].context.command}!!"
    end

    on_abort_process do |cg, p|
      puts "what's wrong, #{p.context.command}!"
    end
  end

  it name do
    Stdio.capture do |io|
      cg = WhatsWrong.new
      cg.command ":P", abort_on_error: true
      cg.run.wait
      io.out.gets_to_end.should eq <<-EOS
      what's wrong, :P!
      what's wrong, :P!!\n
      EOS
    end
  end
end
