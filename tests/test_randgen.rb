require_relative "../lib/vhdl.rb"
require_relative "../lib/netlist.rb"

include Netlist
include VHDL

generator = Netlist::RandomGenComb.new 100, 20, 20
# generator = Netlist::RandomGenComb.new 20, 5, 10
rand_circ = generator.getRandomNetlist "test"


Converter::DotGen.new.dot generator.netlist, "./rand_circ3.dot"

`xdot ./rand_circ3.dot`

# puts "Terminated."