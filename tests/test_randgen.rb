require_relative "../lib/vhdl.rb"
require_relative "../lib/netlist.rb"

include Netlist
include VHDL

Dir.chdir("tests/tmp") do
    Netlist.generate_gtech(5)
    generator = Netlist::RandomGenComb.new(8, 100, 8, [:custom, 0.25])
    # generator = Netlist::RandomGenComb.new 200, 10, 10
    rand_circ = generator.getValidRandomNetlist "test"
    # puts "Gates amount : #{rand_circ.components.length}"
    pp rand_circ.getNetlistInformations :one

    # rand_circ.save_as "."

    Converter::DotGen.new.dot generator.netlist, "./test.dot"
    # `xdot ./test.dot`

    # paths = rand_circ.get_output_path(rand_circ.get_outputs[0])
    # pp paths
    # pp rand_circ.get_insertion_points(Netlist::Buffer.new.propag_time[:int_multi])
    # pp rand_circ.get_transition_probability_h
end

# puts "Terminated."