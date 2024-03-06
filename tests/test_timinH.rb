require_relative "../lib/netenos.rb"

include Netlist

generator = Netlist::RandomGenComb.new(8, 4, 15, [:custom, 0.5])
# generator = Netlist::RandomGenComb.new 200, 10, 10
rand_circ = generator.getRandomNetlist "test"
# puts "Gates amount : #{rand_circ.components.length}"
pp rand_circ.getNetlistInformations :int_multi

pp rand_circ.get_timings_hash

viewer = Converter::DotGen.new
viewer.dot rand_circ, "./rand_circ.dot"

# `xdot ./rand_circ.dot`

pp rand_circ.get_slack_hash(:int_multi)

# rand_circ.components.each do |comp|
#     puts comp.name, comp.slack
# end

# puts "Terminated."