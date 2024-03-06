require_relative "../lib/vhdl.rb"
require_relative "../lib/netlist.rb"

include Netlist
include VHDL

generator = Netlist::RandomGenComb.new(8, 4, 15, [:even, 0.5 ])
# generator = Netlist::RandomGenComb.new 200, 10, 10
rand_circ = generator.getRandomNetlist "test"
# puts "Gates amount : #{rand_circ.components.length}"
pp rand_circ.getNetlistInformations :one

# Converter::DotGen.new.dot generator.netlist, "./rand_circ3.dot"

# `xdot ./rand_circ3.dot`

# puts "Terminated."