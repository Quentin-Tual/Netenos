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

            return @stages.keys.max
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

        def select_ht type, nb_trigger_sig
            case type 
            when "xor_and"
                @ht = Netlist::Xor_And.new(nb_trigger_sig)
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
                puts "HT inserted : \n\t- Payload : #{@ht.get_payload_in.partof.name}\n\t- Trigger type : #{@ht.get_payload_in.partof.get_inputs[1].get_source.partof.name} \n\t- Number of trigger signals : #{@ht.get_triggers_nb}"
                return @netlist
            else 
                raise "Error : internal fault. Ht not correctly inserted."
            end
        end

    end

end