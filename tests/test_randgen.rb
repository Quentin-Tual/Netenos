require_relative "../lib/vhdl.rb"
require_relative "../lib/netlist.rb"

include Netlist
include VHDL

Dir.chdir("tests/tmp") do
    generator = Netlist::RandomGenComb.new(8, 4, 6, [:custom, 0.75])
    # generator = Netlist::RandomGenComb.new 200, 10, 10
    rand_circ = generator.getRandomNetlist "test"
    # puts "Gates amount : #{rand_circ.components.length}"
    pp rand_circ.getNetlistInformations :one

    # rand_circ.save_as "."

    Converter::DotGen.new.dot generator.netlist, "./test.dot"
    # `xdot ./test.dot`

    # paths = rand_circ.get_output_path(rand_circ.get_outputs[0])
    # pp paths

    # pp rand_circ.get_transition_probability_h
end

# puts "Terminated."