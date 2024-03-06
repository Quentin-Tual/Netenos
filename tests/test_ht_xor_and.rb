require '../lib/netenos.rb'

include Netlist
include Inserter

if ARGV.empty?
    nb_inputs = 8
else
    nb_inputs = ARGV[0].to_i
end

ht = Xor_And.new nb_inputs

puts "HT inserted : \n\t- Payload : #{ht.get_payload_in.partof.name}\n\t- Trigger proba. : #{ht.get_transition_probability} \n\t- Number of trigger signals : #{ht.get_triggers_nb}"
wrapper = Circuit.new "xor_and"
ht.components.map {|comp| wrapper << comp}

viewer = Converter::DotGen.new
viewer.dot wrapper

pp ht.propag_time

