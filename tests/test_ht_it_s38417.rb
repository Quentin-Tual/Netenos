require '../lib/netenos.rb'

include Netlist
include Inserter

if ARGV.empty?
    nb_inputs = 8
else
    nb_inputs = ARGV[0].to_i
end

ht = It_s38417.new nb_inputs

puts "HT inserted : \n\t- Payload : #{ht.get_payload_in.partof.name}\n\t- Trigger proba. : #{ht.get_transition_probability} \n\t- Number of trigger signals : #{ht.get_triggers_nb}"
wrapper = Circuit.new "it_s38417"
ht.components.map {|comp| wrapper << comp}

viewer = Converter::DotGen.new
viewer.dot wrapper
