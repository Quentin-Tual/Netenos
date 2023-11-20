require_relative '../lib/converter/genStim.rb'
require_relative '../lib/netenos.rb'
require 'ruby-prof'


# pp "Started"

generator = Netlist::RandomGenComb.new 12, 4, 10 # Mini ---> 36 gates
rand_circ = generator.getRandomNetlist "test"

Converter::DotGen.new.dot generator.netlist, "./rand_circ2.dot"

foo = Converter::GenStim.new(rand_circ)
# pp foo.gen_random_stim(20)

# profiler = RubyProf::Profile.new
# profiler.start

# stim_seq = foo.gen_exhaustive_incr_stim
# pp stim_seq
# pp foo.save_as_txt("test.txt")

# puts "Test sequence length : #{stim_seq.values[0].length}"

# result = profiler.stop
# print a flat profile to text
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)

# pp "Terminated"