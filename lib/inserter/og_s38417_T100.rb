require_relative "ht.rb"
require_relative "../netlist.rb"

module Netlist

    class Og_s38417 < HT
        # attr_accessor :components # DEBUG

        def initialize nb_trigger
            # * : For the moment the only parameters allowed are power of 2 numbers. This is faster to develop and easier for a start. It may evolve later to allow more possibilities.
            super
            @netlist = gen_netlist nb_trigger
        end

        def gen_netlist nb_trigger
            gen_payload
            @payload_in <= gen_triggers(nb_trigger)
            @payload_in = @payload_in.partof.get_free_input
            return @payload_out.partof
        end

        def gen_triggers nb_trigger

            input_gates = []
            nb_gates = nb_trigger/2
            nb_gates.times do |i|
                tmp = Netlist::Nor2.new
                input_gates << tmp
                @components << tmp
                tmp.get_inputs.each{|in_p| @triggers << in_p} 
            end
            trig_tree = [input_gates]

            layer = 1 
            until nb_gates == 1 do
                nb_gates = nb_gates / 2 # Ou bien : nb_trigger / (2 * layer)
                trig_tree << []
                nb_gates.times do |i| 
                    # Instantiate the gate
                    trig_tree[layer] << Netlist::And2.new
                    @components << trig_tree[layer].last
                    # Link the new gate to one previous layer gate
                    [0,1].each do |selector|
                        trig_tree[layer].last.get_inputs[selector] <= trig_tree[layer-1][i*2 + selector].get_output
                    end
                end

                layer += 1
            end 

            return trig_tree.last[0].get_output
        end

        def gen_payload 
            generated_payload = Netlist::Or2.new
            @components << generated_payload
            @payload_out = generated_payload.get_output
            @payload_in = generated_payload.get_inputs[1]
            return generated_payload
        end

    end

end