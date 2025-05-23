require_relative "../lib/vhdl.rb"
require_relative "../lib/netlist.rb"

include Netlist
include VHDL

Dir.chdir("tests/tmp") do
    generator = Netlist::RandomGenComb.new(8, 4, 15, [:custom, 0.7])
    # generator = Netlist::RandomGenComb.new 200, 10, 10
    rand_circ = generator.getValidRandomNetlist("test")
    # puts "Gates amount : #{rand_circ.components.length}"
    puts

    rand_circ.save_as "."

    Converter::DotGen.new.dot generator.netlist, "./test.dot"
    # `xdot ./test.dot`
end

# puts "Terminated."