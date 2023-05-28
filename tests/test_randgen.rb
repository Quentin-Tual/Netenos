require_relative "../lib/vhdl.rb"
require_relative "../lib/netlist.rb"

include Netlist
include VHDL

generator = Netlist::RandomGenComb.new 100, 20, 20, 25
rand_circ = generator.getRandomNetlist "test"


Netlist::DotGen.new.dot generator.netlist, "./rand_circ3.dot"

# if generator.verifyLoop
#     generator.fixLoops
# end

# Netlist::DotGen.new.dot generator.netlist, "./rand_circ3_fixed.dot"


pp "Terminated."