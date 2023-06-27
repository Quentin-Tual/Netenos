require_relative "../netlist.rb"
require_relative "ht.rb"
require_relative "xor_and_ht.rb"

module Netlist

    class Tamperer

        def initialize netlist
            @netlist = netlist
            @stages = {}
            @ht = nil
            scan_netlist # * : Gives a hash dividing the netlist by stages, each being the max distance of each components from a global input 
            @inverted_stages = inside_out @stages # * : Reverse it to use the stage number as a key
        end

        def inside_out(h)
            g = h.flat_map { |s,a| [a].product([s]) }
                 .group_by(&:first)
            g.merge(g) { |_,a| a.map(&:last) }
        end

        # TODO : Add a method to get the trigger condition (boolean expression)
        def get_trigger_conditions
            # ! : Only works with a gate tree built with only one operator type
            # ! : Move some parts in the ht instantiation function -> Xor_And has to be able to give his triggering sequence. Easier than to write it with the ht than to find it later with a generic function
            local_exp = [] 
            # TODO : Récupérer le full_name des signaux contrôlant l'activation du trigger (signaux reliés aux premières portes AND du trigger, càd à son front-end)
                # TODO : pour chaque porte front-end du trigger récupérer le full_name de chaque source
                trig_list = @ht.get_triggers 
                trig_list.length.times do |i|
                    if i.even?
                        input_ports = trig_list[i].partof.get_inputs
                        local_exp << [input_ports[0].get_source.get_full_name, "and", input_ports[1].get_source.get_full_name]
                    else 
                        local_exp << "and"
                        next
                    end
                end
                local_exp.pop

            local_exp = to_global_exp(local_exp)

            return local_exp
                # TODO : Pour chaque full_name du front-end récupérés au préalable 
                    # TODO : Remonter jusqu'aux entrées globales liées et enregistrer les portes rencontrées sur le chemin dans l'ordre
                    # TODO : A partir de ces portes mémorisées, reconstituer l'expression globale de ces signaux
                # TODO : Remplacer les noms (full_name) dans l'expression locale par l'expression globale de chaque signaux
        end

        def to_global_exp local_exp
            local_exp.length.times do |i|
                case local_exp[i]
                when Array
                    to_global_exp local_exp[i]
                when "and"
                    next
                else # "and"
                    local_exp[i] = get_global_expression local_exp[i]
                end
            end

            return local_exp
        end

        def get_global_expression sig_full_name
            if is_global_port_name? sig_full_name
                return sig_full_name
            else
                comp = @netlist.get_component_named(sig_full_name.split('_')[0])
                in_ports = comp.get_inputs
                global_exp = []
          
                if comp.class == Netlist::Not
                    global_exp << "not"
                    next_full_name = in_ports[0].get_source.get_full_name
                    if next_full_name[0] == 'w' 
                        # Bypass the wire, transparent in a boolean expression
                        global_exp << get_global_expression(in_ports[0].get_source.get_source.get_full_name)
                    else
                        global_exp << get_global_expression(next_full_name)
                    end
                else
                    in_ports.each do |p|
                        next_full_name = p.get_source.get_full_name
                        if next_full_name[0] == 'w' 
                            # Bypass the wire, transparent in a boolean expression
                            global_exp << get_global_expression(p.get_source.get_source.get_full_name)
                        else
                            global_exp << get_global_expression(next_full_name)
                        end
                        global_exp << comp.class.to_s.split('::')[1].delete_suffix('2').downcase
                    end
                    global_exp.pop
                end
            end 

            pp global_exp
            return global_exp
        end 

        def is_global_port_name? port_name
            return not(port_name.split('_').length > 1)
        end

        def scan_netlist
            # * : Inputs scanned first 
            @netlist.get_inputs.each do |global_input|
                @stages[global_input] = 0
            end
            
            # * : Following each path
            @netlist.get_inputs.each do |global_input|
                global_input.get_sinks.each do |sink| 
                    visit_netlist sink.partof, 1
                end 
            end
            
            # * : Finish with output as the last_stage.
            last_stage = @stages.values.max + 1
            @netlist.get_outputs.each do |global_output|
                @stages[global_output] = last_stage
            end  

            return @stages.values.max
        end

        def propag_visit sink_comp, curr_stage
        # * : Allows to propagate the visit along the path, taking in account every object types possibly encountered.
            sink_comp.get_outputs.each do |sink_comp_outport|
                sink_comp_outport.get_sinks.each do |sink|
                    if sink.class == Netlist::Wire
                        sink.get_sinks.map{|wire_sink| visit_netlist wire_sink.partof, curr_stage+1}
                    else
                        visit_netlist sink.partof, curr_stage+1
                    end
                end
            end
        end 

        def visit_netlist sink_comp, curr_stage
        # * : Recursive function used to fill the @stages attribute, going through the paths from inputs to outputs.
            if sink_comp.partof.nil? 
                return nil
            elsif @stages.keys.include?(sink_comp)
                if @stages[sink_comp] < curr_stage
                    @stages[sink_comp] = curr_stage
                    propag_visit sink_comp, curr_stage
                end
                return nil
            else
                @stages[sink_comp] = curr_stage
                propag_visit sink_comp, curr_stage
            end
        end

        def select_ht type, nb_trigger_sig = 4
            # * Instantiate and load a HT, method insert allows to inject it into the loaded netlist
            case type 
            when "xor_and"
                if nb_trigger_sig.nil?
                    @ht = Netlist::Xor_And.new
                else
                    @ht = Netlist::Xor_And.new(nb_trigger_sig)
                end
            else 
                raise "Error : Unknown HT type #{type}. Please verify syntax."
            end

        end

        def select_location location
            case location
            when "random"
                stage = @inverted_stages.keys[2...-1].sample
                return @inverted_stages[stage].sample.get_outputs.sample, stage
            else
                raise "Error : Unknown location type #{location}. Please verify syntax."
            end
        end

        def select_triggers_sig n, max_stage
            
            # * : Constituting a pool of sources (Port instead of Circuit class objects) in which we can pick.  
            pool = {}
            @inverted_stages.keys.each do |stage|
                @inverted_stages[stage].each do |comp|
                    if comp.is_a? Netlist::Circuit
                        if pool[stage].nil?
                            pool[stage] = []
                            comp.get_outputs.each {|outport| pool[stage] << outport} 
                        else
                            # pool[stage] << comp.get_outputs
                            comp.get_outputs.each {|outport| pool[stage] << outport} 
                        end
                    else 
                        if pool[stage].nil? 
                            pool[stage] = [comp]
                        else
                            pool[stage] << comp
                        end
                    end
                end
            end

            # * : Then it is possible to pick in and modify the pool regarding evolving constraints. 
            selected_signals = []
            n.times do |nth|
                stage = pool.keys[0...max_stage].sample
                selected = pool[stage].delete(pool[stage].sample)
                selected_signals << selected
                if pool[stage].empty?
                    pool.delete stage
                    max_stage = max_stage - 1
                end
            end
           
            return selected_signals
        end

        def insert
            loc, max_stage = select_location "random"

            # * : Payload insertion (removing old links and creating new ones)
            loc.get_sinks.each{ |sink|
                sink.unplug sink.get_source.name
                sink <= @ht.get_payload_out
            }
            @ht.get_payload_in <= loc
            loc = nil # Free space

            trig = select_triggers_sig(@ht.get_triggers_nb, max_stage)

            # * : Linking triggers slot to selected triggers signals (already existing in the authentic circuit).
            trig.zip(@ht.get_triggers).each { |pair|
                pair[1] <= pair[0]
            }

            # * : Adding components added to the netlists components list (used for printing and format conversions).
            @ht.get_components.each do |comp|
                @netlist << comp
            end

            # * : Verification and printing informations 
            if @ht.is_inserted?
                puts "HT inserted : \n\t- Payload : #{@ht.get_payload_in.partof.name}\n\t- Trigger type : #{@ht.get_payload_in.partof.get_inputs[1].get_source.partof.name} \n\t- Number of trigger signals : #{@ht.get_triggers_nb}\n\t- Stage : #{@stages[@ht.get_payload_in.get_source.partof]}"
                return @netlist
            else 
                raise "Error : internal fault. Ht not correctly inserted."
            end
        end

        def get_ht_stage 
            return @stages[@ht.get_payload_in.get_source.partof]
        end

    end

end