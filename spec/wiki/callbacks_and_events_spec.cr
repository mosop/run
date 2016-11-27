require "../spec_helper"

module RunWikiCallbacksAndEventsFeature
  class WhatsWrong < Run::CommandGroup
    after_success do |cg, p|
      puts "good, #{p.context.self_name}."
    end

    after_group_success do |cg, pg|
      puts "good, #{pg.context.self_name}."
    end

    after_error do |cg, p|
      puts "what's wrong, #{p.context.self_name}!"
    end

    after_group_error do |cg, pg|
      puts "what's wrong, #{pg.context.self_name}!"
    end

    after_abort do |cg, p|
      puts "poor, #{p.context.self_name}..."
    end

    after_group_abort do |cg, pg|
      puts "poor, #{pg.context.self_name}..."
    end
  end

  # TODO: deadlocked on travis
  unless ENV["TRAVIS"]?
    it name do
      lines = Stdio.capture do |io|
        cg = WhatsWrong.new :"home", parallel: true, abort_timeout: 10 do |g|
          g.group(WhatsWrong.new(:kitchen)) do |g|
            g.command :sister, "echo", [":)"]
            g.command :mom, "/bin/bash", ["-c", "echo 'darling!!'; exit 1"], abort_on_error: true
          end
          g.group(WhatsWrong.new(:"living room")) do |g|
            g.command :dad, "/bin/bash", ["-c", "trap 'exit 1' TERM ; while : ; do : ; done"]
          end
        end
        cg.run.wait
        io.out.gets_to_end.should eq <<-EOS
        :)
        good, sister.
        darling!!
        what's wrong, mom!
        poor, kitchen...
        what's wrong, dad!
        what's wrong, living room!
        poor, dad...
        poor, living room...
        poor, home...
        what's wrong, kitchen!
        what's wrong, home!\n
        EOS
      end
    end
  end
end
