require_relative '../lib/netenos.rb'
# require 'lib/netenos.rb'

include Netlist
include Inserter

DELAY_MODEL = :int_multi

if ARGV.empty?
    nb_inputs = 8
else
    nb_inputs = ARGV[0].to_i
end

ht = Og_s38417.new nb_inputs

puts "HT inserted : \n\t- Payload : #{ht.get_payload_in.partof.name}\n\t- Trigger proba. : #{ht.get_transition_probability} \n\t- Number of trigger signals : #{ht.get_triggers_nb}"
wrapper = Circuit.new "og_s38417"
ht.components.map {|comp| wrapper << comp}

# wrapper.getNetlistInformations :int_multi
# ht.triggers.each{|comp| comp.partof.update_path_delay 0, DELAY_MODEL}

# pp ht.get_payload_in.partof.cumulated_propag_time - (ht.triggers.collect{|trig| trig.partof.cumulated_propag_time}.min)

viewer = Converter::DotGen.new
viewer.dot wrapper, nil, DELAY_MODEL

pp ht.propag_time
