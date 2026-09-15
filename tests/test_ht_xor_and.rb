require '../lib/netenos'

include Netlist
include Inserter

nb_inputs = if ARGV.empty?
              8
            else
              ARGV[0].to_i
            end

ht = Xor_And.new nb_inputs

puts "HT inserted : \n\t- Payload : #{ht.get_payload_in.partof.name}\n\t- Trigger proba. : #{ht.get_transition_probability} \n\t- Number of trigger signals : #{ht.get_triggers_nb}"
wrapper = Circuit.new 'xor_and'
ht.components.map { |comp| wrapper << comp }

viewer = Converter::DotGen.new
viewer.dot wrapper

pp ht.propag_time
