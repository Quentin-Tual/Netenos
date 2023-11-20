require_relative "../lib/netenos.rb"

generator = Netlist::RandomGenComb.new 6,2,3
circ = generator.getRandomNetlist "test_netson_circ"

Converter::DotGen.new.dot circ, "./test_netson_circ.dot"
Converter::ConvNetlist2Vhdl.new.generate circ

foo = Converter::Netson.new
foo.save_as_json(circ, "./test_netson_circ.json")

