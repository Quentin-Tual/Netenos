require_relative "../lib/netenos.rb"

serializer=Serializer.new
netlist2=Netlist::RandomGenComb.new(8,6,10).getRandomNetlist
netlist2.name="ser"
netlist2.get_dot_graph
serializer.serialize(netlist2)
serializer.save_as sexp_filename="netlist2.sexp"

deserializer=Deserializer.new
netlist1 = deserializer.deserialize(sexp_filename)
netlist1.name="deser"
netlist1.get_dot_graph