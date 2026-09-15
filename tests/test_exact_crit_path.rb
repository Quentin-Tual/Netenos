require_relative '../lib/vhdl'
require_relative '../lib/netlist'

include Netlist
include VHDL

generator = Netlist::RandomGenComb.new 8, 4, 20
rand_circ = generator.getRandomNetlist 'test'
puts "Gates amount : #{rand_circ.components.length}"

viewer = Converter::DotGen.new
viewer.dot rand_circ

# pp rand_circ.get_exact_crit_path_length :one
pp rand_circ.getNetlistInformations :int
