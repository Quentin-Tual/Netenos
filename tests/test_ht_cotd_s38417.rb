require '../lib/netenos.rb'

include Netlist
include Inserter

ht = Cotd_s38417.new 

puts "HT inserted : \n\t- Payload : #{ht.get_payload_in.partof.name}\n\t- Trigger proba. : #{ht.get_transition_probability} \n\t- Number of trigger signals : #{ht.get_triggers_nb}"

wrapper = Circuit.new "test"
ht.components.each {|comp| wrapper << comp}

viewer = Converter::DotGen.new
viewer.dot wrapper



