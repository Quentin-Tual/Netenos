require_relative "../netlist.rb"
require_relative "ht.rb"
require_relative "xor_and_ht.rb"
require_relative "cotd_s38417.rb"
require_relative "og_s38417_T100.rb"
require_relative "inverted_trigger_s38417.rb"

module Inserter

    class ImpossibleResolution < StandardError
        def initialize msg, location = nil
            super msg
            @location = location
        end
    end

    class ImpossibleInsertion < StandardError
        def initialize msg, location = nil
            super msg
            @location = location
        end
    end

    class Tamperer
        attr_accessor :stages

        def initialize netlist, stages = {}, timings_h = {}
            @netlist = netlist
            @stages = stages
            @timings_h = timings_h
            @ht = nil
            @location = nil

            # if stages.empty? # ! : Legacy cause not used anymore, scan_netlist is not functional as this.
            #     scan_netlist # * : Gives a hash dividing the netlist by stages, each being the max distance of each components from a global input 
            #     @stages = inside_out @stages # * : Reverse it to use the stage number as a key
            # else
            @stages = a_to_h @stages
            # end
        end

        def a_to_h a
            # * : Converts an array into a hash object
            h = {}

            a.length.times do |layer|
                h[layer] = a[layer]
            end

            return h
        end

        def inside_out(h)
            # * : Inverts a hash, using the values as keys and the keys as values
            g = h.flat_map { |s,a| [a].product([s]) }
                 .group_by(&:first)
            g.merge(g) { |_,a| a.map(&:last) }
        end

        # * : A method to get the trigger condition (boolean expression)
        def get_trigger_conditions
            local_exp = [] 
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

            local_exp = @netlist.to_global_exp(local_exp)

            return local_exp[0]
        end

        # ! Transfered in Netlist::Circuit
        # def to_global_exp local_exp
        #     local_exp.length.times do |i|
        #         case local_exp[i]
        #         when Array
        #             to_global_exp local_exp[i]
        #         when "and"
        #             next
        #         else # "and"
        #             local_exp[i] = get_global_expression local_exp[i]
        #         end
        #     end

        #     return local_exp
        # end

        # ! Transfered in Netlist::Circuit
        # def get_global_expression sig_full_name
        #     if is_global_port_name? sig_full_name
        #         return sig_full_name
        #     else
        #         comp = @netlist.get_component_named(sig_full_name.split('_')[0])
        #         in_ports = comp.get_inputs
        #         global_exp = []
          
        #         if comp.class == Netlist::Not
        #             global_exp << "not"
        #             next_full_name = in_ports[0].get_source.get_full_name
        #             if next_full_name[0] == 'w' 
        #                 # Bypass the wire, transparent in a boolean expression
        #                 global_exp << get_global_expression(in_ports[0].get_source.get_source.get_full_name)
        #             else
        #                 global_exp << get_global_expression(next_full_name)
        #             end
        #         else
        #             in_ports.each do |p|
        #                 next_full_name = p.get_source.get_full_name
        #                 if next_full_name[0] == 'w' 
        #                     # Bypass the wire, transparent in a boolean expression
        #                     global_exp << get_global_expression(p.get_source.get_source.get_full_name)
        #                 else
        #                     global_exp << get_global_expression(next_full_name)
        #                 end
        #                 global_exp << comp.class.to_s.split('::')[1].delete_suffix('2').downcase
        #             end
        #             global_exp.pop
        #         end
        #     end 

        #     # pp global_exp  #!DEBUG
        #     return global_exp
        # end 

        # ! Transfered in Netlist::Circuit
        # def is_global_port_name? port_name
        #     return not(port_name.split('_').length > 1)
        # end

        # ! : Legacy / Not working
        # def scan_netlist
        #     # * : Inputs scanned first 
        #     @netlist.get_inputs.each do |global_input|
        #         @stages[global_input] = 0
        #     end
            
        #     # * : Following each path
        #     @netlist.get_inputs.shuffle.each do |global_input|
        #         global_input.get_sinks.each do |sink| 
        #             visit_netlist sink.partof, 1
        #         end 
        #     end
            
        #     # * : Finish with output as the last_stage.
        #     last_stage = @stages.values.max + 1
        #     @netlist.get_outputs.each do |global_output|
        #         @stages[global_output] = last_stage
        #     end  

        #     return @stages.values.max
        # end

        # ! : Legacy / Not working
        # def propag_visit sink_comp, curr_stage
        # # * : Allows to propagate the visit along the path, taking in account every object types possibly encountered.
        #     sink_comp.get_outputs.each do |sink_comp_outport|
        #         sink_comp_outport.get_sinks.each do |sink|
        #             if sink.class == Netlist::Wire
        #                 sink.get_sinks.map{|wire_sink| visit_netlist wire_sink.partof, curr_stage+1}
        #             else
        #                 visit_netlist sink.partof, curr_stage+1
        #             end
        #         end
        #     end
        # end 

        # ! : Legacy / Not working
        # def visit_netlist sink_comp, curr_stage
        # # * : Recursive function used to fill the @stages attribute, going through the paths from inputs to outputs.
        #     if sink_comp.partof.nil? 
        #         return nil
        #     elsif @stages.keys.include?(sink_comp)
        #         if @stages[sink_comp] < curr_stage
        #             @stages[sink_comp] = curr_stage
        #             propag_visit sink_comp, curr_stage
        #         end
        #         return nil
        #     else
        #         @stages[sink_comp] = curr_stage
        #         propag_visit sink_comp, curr_stage
        #     end
        # end

        def select_ht type, nb_trigger_sig = 4
            # * Instantiate and load a HT, method insert allows to inject it into the loaded netlist
            case type 
            when "xor_and"
                if nb_trigger_sig.nil?
                    @ht = Inserter::Xor_And.new
                else
                    @ht = Inserter::Xor_And.new(nb_trigger_sig)
                end
            when "cotd_s38417"
                @ht = Inserter::Cotd_s38417.new
            when "og_s38417"
                @ht = Inserter::Og_s38417.new nb_trigger_sig
            when "it_s38417"
                @ht = Inserter::It_s38417.new nb_trigger_sig
            else 
                raise "Error : Unknown HT type #{type}. Please verify syntax."
            end

            @ht.components.each do |comp|
                comp.tag = :ht
                # comp.partof = @netlist
            end

        end

        def select_location2 zone, nb_trigger_sig, forbidden_locs
            case zone
            when "near_input"
                # Fix a minimum stage with enough internal signals to insert the ht
                nb_available_sig = @netlist.get_inputs.length
                min_stage = get_min_stage 0, nb_trigger_sig, nb_available_sig
                max_stage = (0.3 * @stages.keys.length).to_i
            when "near_output"
                initial_min_stage = (0.7 * @stages.keys.length).to_i
                # Fix a minimum stage with enough internal signals to insert the ht
                min_stage = get_min_stage initial_min_stage, nb_trigger_sig
                max_stage = (@stages.keys.length) -1
            when "middle"
                initial_min_stage = (0.3 * @stages.keys.length).to_i
                # Fix a minimum stage with enough internal signals to insert the ht
                min_stage = get_min_stage initial_min_stage, nb_trigger_sig
                max_stage = (0.7 * @stages.keys.length).to_i
            when "random"
                nb_available_sig = @netlist.get_inputs.length
                initial_min_stage = 0
                # Fix a minimum stage with enough internal signals to insert the ht
                min_stage = get_min_stage initial_min_stage, nb_trigger_sig, nb_available_sig
                max_stage = (@stages.keys.length)-1
            else
                raise "Error : Unknown zone type #{zone}. Please verify syntax."
            end

            if !max_stage.nil? and max_stage <= min_stage 
                raise "Error:  Not enough space to insert this trojan, too close to the inputs. Try another trojan or increase the circuit size."
            end

            sig_pool = @stages.keys[min_stage...max_stage].each_with_object([]) do |stage, list|
                # * Selects only signals which has a sufficiant slack for insertion (payload propagation delay)
                @stages[stage].each do |comp|
                    comp.get_inputs.each do |in_p|
                        if in_p.slack >= @ht.payload_in.partof.propag_time[:int_multi]
                            list << [in_p, stage]
                        end
                    end
                end

                @netlist.get_outputs.each do |out_p|
                    if out_p.slack >= @ht.payload_in.partof.propag_time[:int_multi]
                        list << [out_p, stage]
                    end
                end
            end

            sig_pool.select!{|in_p, stage| !forbidden_locs.include? in_p}

            if sig_pool.empty?
                raise ImpossibleInsertion.new("Error: No insertion location found.")
            end

            attacked_sig, stage = sig_pool.sample

            # if @stages[stage].nil? 
            #     raise "Error: Attribute valued nil\n -> @stages : #{@stages.nil?} @stages[stage] : #{@stages[stage]} stage : #{stage} min_stage : #{min_stage} stage_max : #{@stages.keys.max}"
            # end

            # if attacked_sig.get_source.empty? # ! DEBUG
            #     if !@netlist.components.include? attacked_sig.partof
            #         puts "Error: Unknown component, not found in the netlist"
            #     end
            #     raise "Error: selected insertion location has no sink.\n -> #{attacked_sig.get_full_name}"
            # end

            return attacked_sig, stage-1 # * Since the stage is the component one, we need to substract 1 to get the stage number of the signals usable by the trigger.
        end

        def get_min_stage min_stage, nb_trigger_sig, nb_available_sig = 0
            @stages.keys[min_stage..-1].sort.each do |stage|
                nb_available_sig += @stages[stage].length
                if nb_available_sig > nb_trigger_sig
                    return stage
                end
            end

            raise "Error: no minimum stage found for HT location selection. -> #{min_stage} : #{nb_trigger_sig} / #{nb_available_sig}"
            # return min_stage
        end

        def select_location zone, nb_trigger_sig
            case zone
            when "near_input"
                # Fix a minimum stage with enough internal signals to insert the ht
                nb_available_sig = @netlist.get_inputs.length
                min_stage = get_min_stage 0, nb_trigger_sig, nb_available_sig
                max_stage = (0.3 * @stages.keys.length).to_i
            when "near_output"
                initial_min_stage = (0.7 * @stages.keys.length).to_i
                # Fix a minimum stage with enough internal signals to insert the ht
                min_stage = get_min_stage initial_min_stage, nb_trigger_sig
                max_stage = (@stages.keys.length) -1
            when "middle"
                initial_min_stage = (0.3 * @stages.keys.length).to_i
                # Fix a minimum stage with enough internal signals to insert the ht
                min_stage = get_min_stage initial_min_stage, nb_trigger_sig
                max_stage = (0.7 * @stages.keys.length).to_i
            when "random"
                nb_available_sig = @netlist.get_inputs.length
                initial_min_stage = 0
                # Fix a minimum stage with enough internal signals to insert the ht
                min_stage = get_min_stage initial_min_stage, nb_trigger_sig, nb_available_sig
                max_stage = (@stages.keys.length)-1
            else
                raise "Error : Unknown zone type #{zone}. Please verify syntax."
            end

            if !max_stage.nil? and max_stage <= min_stage 
                raise "Error:  Not enough space to insert this trojan, too close to the inputs. Try another trojan or increase the circuit size."
            end

            stage = @stages.keys[min_stage...max_stage].sample
                 
            if @stages[stage].nil? 
                raise "Error: Attribute valued nil\n -> @stages : #{@stages.nil?} @stages[stage] : #{@stages[stage]} stage : #{stage} min_stage : #{min_stage} stage_max : #{@stages.keys.max}"
            end
            attacked_sig = @stages[stage].sample.get_output
            # if comp.class == Port
            #     if comp.is_global? and comp.is_input?
            #         raise "Error: HT won't be inserted on a primary input."
            #     end
            # end

            if attacked_sig.get_sinks.empty? # ! DEBUG
                if !@netlist.components.include? attacked_sig.partof
                    puts "Error: Unknown component, not found in the netlist"
                end
                raise "Error: selected insertion location has no sink.\n -> #{attacked_sig.get_full_name}"
            end

            return attacked_sig, stage
        end

        # def select_triggers_sig2 n, max_delay
        #     # * : Constituting a pool of sources (Port instead of Circuit class objects) in which we can pick.  
        #     pool = {0.0 => @netlist.get_inputs}
        #     @timings_h.keys.each do |delay|
        #         @timings_h[delay].each do |comp|
        #             if comp.is_a? Netlist::Circuit
        #                 if pool[delay].nil?
        #                     pool[delay] = []
        #                     comp.get_outputs.each {|outport| pool[delay] << outport} 
        #                 else
        #                     # pool[delay] << comp.get_outputs
        #                     comp.get_outputs.each {|outport| pool[delay] << outport} 
        #                 end
        #             else 
        #                 if pool[delay].nil? 
        #                     pool[delay] = [comp]
        #                 else
        #                     pool[delay] << comp
        #                 end
        #             end
        #         end
        #     end

        #     # * : Then it is possible to pick in and modify the pool regarding evolving constraints. 
        #     selected_signals = []
        #     n.times do |nth|
        #         available_delays = pool.keys.select{|d| (d >= 0) and (d < max_delay)}
        #         delay = available_delays.sort.sample

        #         selected = pool[delay].sample
        #         pool[delay] -= [selected]
        #         selected_signals << selected
        #         if pool[delay].empty?
        #             pool.delete delay
        #             max_delay = max_delay - 1
        #         end
        #         # if pool.empty?
        #         #     break
        #         # end
        #     end

        #     return selected_signals
        # end


        def select_triggers_sig n, max_stage, max_delay
            # * : Constituting a pool of components sources in which we can pick.  
            pool = @netlist.get_inputs.clone

            0.upto(max_stage) do |stage|
                @stages[stage].each do |comp|
                    pool << comp
                end
            end

            # * Filtering the comp pool with the wanted maximal cumulated_propag_time 
            pool.select! do |comp|
                comp.cumulated_propag_time + @ht.propag_time[:int_multi] <= max_delay
            end

            # * : Then it is possible to pick in and modify the pool regarding evolving constraints. 
            selected_signals = []
            n.times do |nth|

                if pool.empty? 
                    raise ImpossibleResolution.new("Error: Not enough signal to insert the trojan, try again. If it happens frequently try with different parameters.")
                end

                selected = pool.delete_at(rand(pool.length))

                if selected.is_a? Netlist::Port
                    selected_signals << selected
                else
                    selected_signals << selected.get_output
                end
            end

            return selected_signals
        end

        def insert2 zone="random"
            @netlist.get_slack_hash # Necessary for later (location selection)

            forbidden_locs = []
            rescue_data = {:loc_sinks => []}
            begin 
                attempts ||= 0
                
                loc, max_stage = select_location2(zone, @ht.get_triggers_nb, forbidden_locs)
                puts "Inserted on #{loc.get_full_name}" if $VERBOSE
                
                # * : Payload insertion (removing old links and creating new ones)
                # ! loc is not a Circuit class object anymore, with slack update it is now a Port class object
                # loc.get_sinks.each{ |sink|
                #     rescue_data[:loc_sinks] << sink
                #     sink.unplug2 sink.get_source.get_full_name
                #     sink <= @ht.get_payload_out
                # }
                # @ht.get_payload_in <= loc

                # ! Now it would look like this :
                source = loc.get_source
                loc.unplug2 source.get_full_name
                loc <= @ht.get_payload_out
                @ht.get_payload_in <= source

                if source.is_global?
                    max_delay = source.cumulated_propag_time + loc.slack
                else
                    max_delay = source.partof.cumulated_propag_time + loc.slack
                end
                trig = select_triggers_sig(@ht.get_triggers_nb, max_stage, max_delay)
            rescue ImpossibleResolution => e
                if $VERBOSE
                    puts "Insertion location research number #{attempts} !"
                end
                forbidden_locs << loc

                @ht.get_payload_in.unplug2 source.get_full_name 
                # rescue_data[:loc_sinks].each do |sink|
                    loc.unplug2 loc.get_source.get_full_name
                    loc <= source
                # end
                # rescue_data[:loc_sinks] = []
                # loc.get_sinks.each{ |sink|
                #     rescue_data[:loc_sinks] << sink
                #     sink.unplug @ht.get_payload_out.get_full_name
                #     sink <= rescue_data[:loc_sinks].shift
                # }
                # if (attempts += 1) < 5
                retry
                # else
                #    raise ImpossibleResolution.new("Error : No resolution found for this case. Try again.") 
                # end
            end 

            # * : Linking triggers slot to selected triggers signals (already existing in the authentic circuit).
            trig.zip(@ht.get_triggers).each { |output, input|
                input <= output
            }

            # * : Adding components added to the netlists components list (used for printing and format conversions).
            @ht.get_components.each do |comp|
                @netlist << comp
            end

            # @ht.get_triggers.each{|e| puts e.get_source.nil?}
            # raise "stop"
            # * : Verification and printing informations 
            @location = (max_delay / @timings_h.keys.last).round(3)

            if @ht.is_inserted?
                # puts "HT inserted : \n\t- Payload : #{@ht.get_payload_in.partof.name}\n\t- Trigger proba. : #{@ht.get_transition_probability} \n\t- Number of trigger signals : #{@ht.get_triggers_nb}\n\t- Stage : #{max_stage}"
                return @netlist
            else 
                raise "Error : internal fault. Ht not correctly inserted."
            end

            @ht.components.each{|comp| comp.cumulated_propag_time = 0.0}
        end

        def insert zone="random"
            loc, max_stage = select_location(zone, @ht.get_triggers_nb)

            # * : Payload insertion (removing old links and creating new ones)
            # puts "location no sinks ? : #{loc.get_sinks.empty?}"
            # puts loc.get_full_name
            # puts @netlist.components.include? loc.partof
            # puts loc.partof.get_inputs[0].get_source.get_full_name

            loc.get_sinks.each{ |sink|
                sink.unplug sink.get_source.get_full_name
                sink <= @ht.get_payload_out
            }
            @ht.get_payload_in <= loc

            trig = select_triggers_sig(@ht.get_triggers_nb, max_stage)

            # * : Linking triggers slot to selected triggers signals (already existing in the authentic circuit).
            trig.zip(@ht.get_triggers).each { |output, input|
                input <= output
            }

            # * : Adding components added to the netlists components list (used for printing and format conversions).
            @ht.get_components.each do |comp|
                @netlist << comp
            end

            # @ht.get_triggers.each{|e| puts e.get_source.nil?}
            # raise "stop"
            # * : Verification and printing informations 
            @location = (max_stage.to_f / @stages.keys.last).round(3)

            if @ht.is_inserted?
                # puts "HT inserted : \n\t- Payload : #{@ht.get_payload_in.partof.name}\n\t- Trigger proba. : #{@ht.get_transition_probability} \n\t- Number of trigger signals : #{@ht.get_triggers_nb}\n\t- Stage : #{max_stage}"
                return @netlist
            else 
                raise "Error : internal fault. Ht not correctly inserted."
            end
        end

        def get_ht_delay
            payload_cumulated_delay = @ht.netlist.cumulated_propag_time 
            trigger_cumulated_delay = @ht.triggers.collect{|trig| trig.partof.cumulated_propag_time}.min

            return payload_cumulated_delay - trigger_cumulated_delay
        end 

        def get_payload_cumulated_delay
            return @ht.netlist.cumulated_propag_time
        end

        def get_ht_stage 
            return @location 
        end

        def get_ht_size 
            return @ht.get_components.length
        end

    end

end