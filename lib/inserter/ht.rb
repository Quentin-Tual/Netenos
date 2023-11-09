module Inserter
        
    class HT 

        # * : An HT netlist is considered as the referense pointing on its payload instance 
        def initialize netlist = nil #, triggers, payload_out, payload_in=nil
            @netlist = nil
            @triggers = []
            @payload_out = nil
            @payload_in = nil
            @components = []
        end

        def is_inserted? 
            # * : Returns a boolean value, being true if all ports of the HT are connected
            @triggers.each do |trig| 
                if trig.is_free?
                    return false
                end
            end

            if @payload_in.is_free? or @payload_out.is_free?
                return false
            end

            return true
        end

        def get_triggers_nb
            return @triggers.length
        end

        def get_payload_out
            return @payload_out
        end

        def get_payload_in
            return @payload_in
        end

        def get_triggers
            return @triggers
        end

        def get_transition_probability curr_gate = @payload_in.partof.get_inputs[1].get_source.partof  

            if @components.include? curr_gate
                if !curr_gate.is_a? Netlist::Not
                    return compute_transit_proba(
                        get_transition_probability(curr_gate.get_inputs[0].get_source.partof),
                        get_transition_probability(curr_gate.get_inputs[1].get_source.partof),
                        curr_gate
                    )
                else
                    return compute_transit_proba(
                        get_transition_probability(curr_gate.get_inputs[0].get_source.partof),
                        nil,
                        curr_gate
                    )
                end
            else
                return 0.5
            end
            
        end

        def compute_transit_proba proba_ix, proba_iy, gate
            output_transit_proba = 0.0

            case gate
            when Netlist::And2
                output_transit_proba = (1.0 - proba_ix * proba_iy) * (proba_ix * proba_iy)
            when Netlist::Or2
                output_transit_proba = (1.0 - proba_ix) * (1.0 - proba_iy) * (1.0 -((1.0 - proba_ix) * (1.0 - proba_iy)))
            when Netlist::Not
                output_transit_proba = (1.0 - proba_ix) * proba_ix
            when Netlist::Nand2
                output_transit_proba = (proba_ix * proba_iy) * (1.0 - (proba_ix * proba_iy))
            when Netlist::Nor2
                output_transit_proba = (1.0 - (1.0 - proba_ix) * (1.0 - proba_iy)) * (1.0 - proba_ix) * (1.0 - proba_iy)
            when Netlist::Xor2
                output_transit_proba = (1.0 - (proba_ix + proba_iy - 2.0 * proba_ix * proba_iy)) * (proba_ix + proba_iy - 2.0 * proba_ix * proba_iy)
            else
                puts "Error : Unknown gate #{gate.name} encountered. Please verify."
            end

            return output_transit_proba
        end
        
        def get_components
            return @components
        end
    end

end