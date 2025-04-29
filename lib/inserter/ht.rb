module Inserter
        
    class HT 
        attr_reader :netlist, :triggers, :propag_time, :payload_in

        # * : An HT netlist is considered as the reference pointing on its payload instance 
        def initialize netlist = nil #, triggers, payload_out, payload_in=nil
            @netlist = nil
            @triggers = []
            @payload_out = nil
            @payload_in = nil
            @components = []
            @propag_time = {}
        end

        def is_inserted? 
            # TODO : For each trigger port and payload port, check if links are valid (in both direction, so check if source has the port itself in fanout)

            # * : Returns a boolean value, being true if all ports of the HT are correctly connected
            @triggers.each do |trig| 
                if !trig.check_link?
                    return false
                end
            end

            if !@payload_in.check_link? or !@payload_out.check_link?
                return false
            end

            return true
        end

        def get_exact_crit_path delay_model
            @components.each{|comp| comp.cumulated_propag_time = 0.0}
            trig_comps = @triggers.collect{|in_p| in_p.partof}.uniq
            trig_comps.each{|comp| comp.update_path_delay 0, delay_model} 

            @payload_out.partof.cumulated_propag_time
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

        def get_trigger_transition_proba proba_input_sig = Array.new(@triggers.length, 0.5)
            @trigger_sigs_proba = @triggers.each_with_object(Hash.new).with_index{|(trig,h),i| h[trig] = proba_input_sig[i]}

            get_transition_probability(@payload_in.partof.get_inputs[1].get_source.partof)
        end

        def get_transition_probability curr_gate = @payload_in.partof.get_inputs[1].get_source.partof  

            if @components.include? curr_gate
                if !curr_gate.is_a? Netlist::Not
                    source0=curr_gate.get_inputs[0].get_source
                    source1=curr_gate.get_inputs[1].get_source

                    if source0.nil? # ! Utiliser @trigger_sigs_proba, retrouver l'objet qui représente le signal source en question dans le Hash 
                        transi_proba0 = @trigger_sigs_proba[curr_gate.get_inputs[0]]
                    else 
                        transi_proba0 = get_transition_probability(source0.partof)
                    end

                    if source1.nil?
                        transi_proba1 = @trigger_sigs_proba[curr_gate.get_inputs[1]]
                    else
                        transi_proba1 = get_transition_probability(source1.partof)
                    end

                    return compute_transit_proba(
                        transi_proba0,
                        transi_proba1,
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