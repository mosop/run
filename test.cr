require "./src/run"

# cg = Run::CommandGroup.new(abort_on_error: true)
# cg.command "sleep", %w(30)
# pg = cg.run(async: true)
# pg.wait


# process = Run::Command.new("sleep", %w(300)).run
# process.wait

# cg = Run::CommandGroup.new do |g|
#   g.group do |g|
#     g.command "echo", %w(yeah!)
#   end
# end
# cg.run.wait


# dirs = %w(foo bar baz)
# cg = Run::CommandGroup.new do |g|
#   g.group(async: true) do |g|
#     dirs.each do |dir|
#       g.command "npm", %w(run build), chdir: dir
#     end
#   end
#   g.group(async: true) do |g|
#     dirs.each do |dir|
#       g.command "npm", %w(run watch), chdir: dir
#     end
#   end
# end
# cg.run.wait

cg = Run::CommandGroup.new
cg.command "curl", %w(http://mosop.rocks)
cg.command "curl", %w(http://mosop.yoga)
cg.command "curl", %w(http://mosop.ninja)
process_group = cg.run(async: true)

# do another thing

process_group.wait
