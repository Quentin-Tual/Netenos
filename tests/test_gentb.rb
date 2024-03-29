require_relative '../lib/converter/genTestbench.rb'
require_relative '../lib/netenos.rb'

generator = Netlist::RandomGenComb.new #100, 20, 20, 25
rand_circ = generator.getRandomNetlist "test"

Converter::DotGen.new.dot generator.netlist, "./rand_circ.dot"

foo = Converter::GenTestbench.new(rand_circ)
File.write("./tmp.vhd", foo.gen_testbench)

