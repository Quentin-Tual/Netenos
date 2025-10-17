require_relative "../netlist.rb"
require_relative "ht.rb"
require_relative "xor_and_ht.rb"
require_relative "cotd_s38417.rb"
require_relative "og_s38417_T100.rb"
require_relative "inverted_trigger_s38417.rb"
require_relative "buffer.rb"
require_relative "or_and_ht.rb"

module Inserter

    # def self.instantiateHT htName, nbTrigger = 4
    #     ht = nil
        
    #     case htName
    #     when "og_s38417"
    #         ht = Og_s38417.new(nbTrigger)
    #     when
    #         ht = Xor_And.new(nbTrigger)
    #     when
    #         ht = It_s38417.new(nbTrigger)
    #     when 
    #         ht = Cotd_s38417.new(nbTrigger)
    #     else
    #         raise "Error : Unknown HT name encountered."
    #     end
        
    #     return ht
    # end

    def self.getSimpleInsertTrigVector htName, nb_inputs
        case htName
        when "og_s38417"
            return 0
        when "xor_and"
            return (2**nb_inputs)-1 # full one
        when "or_and" 
            return (2**nb_inputs)-1 # full one
        when "and_not_and"
            return (2**nb_inputs)-1 # full one
        when "it_s38417"
            raise "Error : #{htName} is not stealthy and should not be used."
        when "cotd_s38417"
            raise "Error : #{htName} is not handled by this function."
        else
            raise "Error : Unknown HT name #{htName}."
        end
    end

    def self.getPayloadDelay htName, delayModel

        if delayModel == :one
            return 1
        else
            case htName
            when "og_s38417"
                ht = Og_s38417.new
            when "xor_and"
                ht = Xor_And.new
            when "or_and" 
                ht = Or_And.new
            when "and_not_and"
                ht = And_Not_And.new
            when "it_s38417"
                ht = It_s38417.new
            when "cotd_s38417"
                ht = Cotd_s38417.new
            else
                raise "Error : Unknown HT name #{htName}."
            end
        end
        
        d = ht.payload_in.partof.propag_time[delayModel]
        
        if d.nil? 
            raise "Error: Unknown delay model #{delayModel}."
        end
        
        return d
    end

    class NoTriggerFound < StandardError
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
        attr_accessor :stages, :forbidden_locs, :forbidden_triggers, :trig, :insertPoint, :trigger_pool

        def initialize netlist, stages = {}, timings_h = {}, delay_model: :int_multi, trigger_pool: []
            @netlist = netlist
            # @stages = stages
            @timings_h = timings_h
            @ht = nil
            @location = nil
            @delay_model = delay_model

            # if stages.empty? # ! : Legacy cause not used anymore, scan_netlist is not functional as this.
            #     scan_netlist # * : Gives a hash dividing the netlist by stages, each being the max distance of each components from a global input 
            #     @stages = inside_out @stages # * : Reverse it to use the stage number as a key
            # else
            @stages = stages.is_a?(Array) ? a_to_h(stages) : stages
            @forbidden_locs = Set.new
            @forbidden_triggers = Set.new # ! Should be useless now
            @trigger_pool = trigger_pool_2_obj(trigger_pool)
            # end


            @netlist.get_exact_crit_path_length(@delay_model)
            @netlist.get_slack_hash # Necessary for later (location selection)
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

        def trigger_pool_2_obj trigger_pool
            trigger_pool.map! do |name_list|
                name_list.collect do |name|
                    if name[0] == "i"
                        @netlist.get_port_named(name)
                    else
                        @netlist.get_component_named(name)
                    end
                end
            end 
        end

        def trigger_pool_2_name

            @trigger_pool.map do |trig_vec|
                trig_vec.map do |sig|
                    sig.name
                end
            end 
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
            when "or_and"
                @ht = Inserter::Or_And.new nb_trigger_sig
            when "and_not_and"
                @ht = Inserter::And_Not_And.new nb_trigger_sig
            else 
                raise "Error : Unknown HT type #{type}. Please verify syntax."
            end

            @ht.components.each do |comp|
                comp.tag = :ht
            end

            @ht.get_exact_crit_path(@delay_model)

        end

        def select_location2 zone, nb_trigger_sig
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

            sig_pool = @stages.keys[min_stage...max_stage].each_with_object({}) do |stage, h|
                # * Selects only signals which has a sufficient slack for insertion (payload propagation delay)
                @stages[stage].each do |comp|
                    comp.get_inputs.each do |in_p|
                        if in_p.slack >= @ht.payload_in.partof.propag_time[@delay_model]
                            h[in_p] = stage
                        end
                    end
                end
            end

            @netlist.get_outputs.each do |out_p|
                if out_p.slack >= @ht.payload_in.partof.propag_time[@delay_model]
                    sig_pool[out_p] = @stages.keys.max
                end
            end
          
            # sig_pool.select!{|in_p, stage| !@forbidden_locs.include? in_p.get_full_name}
            @forbidden_locs.each do |loc|
                sig_pool.delete(loc)
            end

            if sig_pool.empty?
                raise ImpossibleInsertion.new("Error: No insertion location found for ht '#{@ht.class.name}' in zone '#{zone}' of circuit '#{@netlist.name}'.")
            end

            attacked_sig, stage = sig_pool.to_a.sample

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

            if attacked_sig.get_sinks.empty? # ! DEBUG
                if !@netlist.components.include? attacked_sig.partof
                    puts "Error: Unknown component, not found in the netlist"
                end
                raise "Error: selected insertion location has no sink.\n -> #{attacked_sig.get_full_name}"
            end

            return attacked_sig, stage
        end

        def get_transi_poba trig_list
            trig_list.collect do |sig|
                get_transi_proba_sig(sig)
            end.sum
        end

        def get_transi_proba_sig sig
            if sig.partof.is_a? Netlist::Gate
                @netlist.get_transition_probability_h[sig.partof]
            else 
                0.5
            end
        end

        def gen_sig_pool max_stage, max_delay
            pool = @netlist.get_inputs.clone

            0.upto(max_stage) do |stage|
                @stages[stage].each do |comp|
                    pool << comp
                end
            end

            # * Filtering the comp pool with the wanted maximal cumulated_propag_time 
            pool.select! do |comp|
                comp.cumulated_propag_time + @ht.propag_time[@delay_model] <= max_delay
            end

            return pool
        end

        def combination_length nb_elem, nb_values
            res = 1

            nb_elem.times do |i|
                res * nb_values
                nb_values -= 1
            end
            
            res
        end

        def get_possible_values_for_limited_combination nb_elem, max_combination
            values = (1..nb_elem).to_a
            # res = nil

            if values.inject(:*) > max_combination
                raise "Error: too much elements, max_combination always exceeded."
            end

            loop do 
                tmp = values.map{|e| e+1}
                combination = tmp.inject(:*)
                break if combination > max_combination
                values = tmp
            end

            return values[-1]
        end

        def gen_limited_sig_pool n, max_stage, max_delay, max_combination
            pool = gen_sig_pool(max_stage, max_delay)

            nb_sig = get_possible_values_for_limited_combination(n, max_combination)

            pool = pool.min_by(nb_sig){|sig| get_transi_proba_sig(sig)}

            return pool
        end

        def gen_limited_trigger_pool n, max_stage, max_delay, max_combination
            pool = @trigger_pool

            if pool.empty?
                pool = gen_limited_sig_pool(n, max_stage, max_delay, max_combination)
                
                pool = pool.combination(n).to_a
                
                pool.sort_by! do |trig_list| 
                    get_transi_poba(trig_list)
                end
            end

            if pool.length < n
                raise NoTriggerFound.new("Error: Not enough signal to insert the trojan, try again. If it happens frequently try with different parameters.")
            end

            pool
        end

        def select_triggers_limited n, max_stage, max_delay, max_combination = 1000000
            pool = gen_limited_trigger_pool(n, max_stage, max_delay, max_combination)

            possibility = pool.shift

            if possibility.nil?
                raise NoTriggerFound.new("Error: Not enough signal to insert the trojan, try again. If it happens frequently try with different parameters.")
            else
                possibility.collect!{|node| if node.is_a?(Netlist::Wire) then node else node.get_output end}
                @trigger_pool = pool
                
                return possibility
            end

            return pool
        end

        def select_triggers_sig2 n, max_stage, max_delay
            # * : Constituting a pool of components sources in which we can pick.  

            # if @forbidden_triggers.length > 10
            #     raise NoTriggerFound.new("Error: Too much forbidden triggers, try another location for the payload.")
            # end 
            pool = @trigger_pool

            if pool.empty?

                pool = @netlist.get_inputs.clone

                0.upto(max_stage) do |stage|
                    @stages[stage].each do |comp|
                        pool << comp
                    end
                end

                # * Filtering the comp pool with the wanted maximal cumulated_propag_time 
                pool.select! do |comp|
                    comp.cumulated_propag_time + @ht.propag_time[@delay_model] <= max_delay
                end
                
                # pool.select! do |sig| 
                #     if sig.partof.is_a? Netlist::Gate
                #         @netlist.get_transition_probability_h[sig.partof] < 0.1
                #     else 
                #         true
                #     end
                #     # @netlist.get_transition_probability_h[sig.partof] 
                # end

                pool = pool.combination(n).to_a

                # pool.sort_by! do |trig_list| 
                #     get_transi_poba(trig_list)
                # end
            # else
            #     pool = @trigger_pool
            end

            if pool.length < n
                raise NoTriggerFound.new("Error: Not enough signal to insert the trojan, try again. If it happens frequently try with different parameters.")
            end

            possibility = pool.shift
            
            if possibility.nil?
                raise NoTriggerFound.new("Error: Not enough signal to insert the trojan, try again. If it happens frequently try with different parameters.")
            else

                possibility.collect!{|node| if node.is_a?(Netlist::Wire) then node else node.get_output end}

                # if !@forbidden_triggers.include?(possibility.collect{|sig| sig.name})
                #     @forbidden_triggers << possibility.collect{|sig| sig.get_full_name}
                @trigger_pool = pool
                
                return possibility
            end
            # end

            # # * : Then it is possible to pick in and modify the pool regarding evolving constraints. 
            # selected_signals = []
            # n.times do |nth|
            #     selected = pool.delete_at(rand(pool.length))

            #     if selected.is_a? Netlist::Port
            #         selected_signals << selected
            #     else
            #         selected_signals << selected.get_output
            #     end
            # end

            
        end

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
                comp.cumulated_propag_time + @ht.propag_time[@delay_model] <= max_delay
            end

            # * : Then it is possible to pick in and modify the pool regarding evolving constraints. 
            selected_signals = []
            n.times do |nth|

                if pool.empty? 
                    raise NoTriggerFound.new("Error: Not enough signal to insert the trojan, try again. If it happens frequently try with different parameters.")
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

        def insert_buffer_at loc, delay = 1
            @ht = Inserter::Buf.new(delay)
            # @ht.propag_time[@delay_model] = delay
            

            # source_node = loc.get_source  #!DEBUG
            # if source_node.instance_of? Netlist::Port and source_node.is_global?
            #     pp 'here'
            # end

            source = loc.get_source
            loc.unplug2 source.get_full_name
            loc <= @ht.get_payload_out
            @ht.get_payload_in <= source

            @ht.components.each do |c|
                c.tag = :ht
                @netlist << c
            end

            return @netlist
        end

        def simple_insert
            slack_h = @netlist.get_slack_hash
            ht_type = @ht.class.name.split("::")[1].downcase
            ht_delay = Inserter::getPayloadDelay(ht_type, @delay_model)
            
            insert_points = slack_h.collect{|slack, insPointList| slack >= ht_delay ? insPointList : []}.flatten
            insert_points.reject!{|insPoint| insPoint.is_global? and insPoint.is_input?}

            # Uncomment to avoid critical path modification
            ht_cumulated_delay = @ht.get_exact_crit_path(@delay_model)
            insert_points.reject!{|insPoint| insPoint.cumulated_propag_time < ht_cumulated_delay}

            if insert_points.empty?                 
                raise ImpossibleInsertion.new("Error: No insertion location found for ht '#{@ht.class.name}' in circuit '#{@netlist.name}'.")
            else
                attacked_sig = insert_points.sample
                # @insertPoint = attacked_sig
            end

            @ht.triggers.each_with_index do |trig, i|
                trig <= @netlist.get_inputs[i % @netlist.get_nb_inputs]
            end

            @ht.components.each do |g|
                g.tag = :ht
                @netlist << g
            end

            source = attacked_sig.get_source
            attacked_sig.unplug2(source.get_full_name) 
            attacked_sig <= @ht.get_payload_out
            @ht.get_payload_in <= source 

            max_delay = source.cumulated_propag_time + attacked_sig.slack
            @location = (max_delay.to_f / @timings_h.keys.last).round(3)

            @netlist.clear_cumulated_propag_times
            @netlist.get_exact_crit_path_length(@delay_model)

            return @netlist
        end

        def insert2 zone="random"

            # @forbidden_locs = []
            # rescue_data = {:loc_sinks => []}
            begin 
                attempts ||= 0
                
                loc, max_stage = select_location2(zone, @ht.get_triggers_nb)
                puts "Inserted on #{loc.get_full_name}" if $VERBOSE
                
                # * : Payload insertion (removing old links and creating new ones)
                source = loc.get_source
                loc.unplug2 source.get_full_name
                loc <= @ht.get_payload_out
                @ht.get_payload_in <= source

                if source.is_global?
                    max_delay = source.cumulated_propag_time + loc.slack
                else
                    max_delay = source.partof.cumulated_propag_time + loc.slack
                end
                @trig = select_triggers_limited(@ht.get_triggers_nb, max_stage, max_delay)
                @insertPoint = loc
            rescue NoTriggerFound => e
                if $VERBOSE
                    puts "Insertion location research number #{attempts} !"
                end

                @forbidden_locs << loc.get_full_name
                # @forbidden_triggers.clear
                @trigger_pool.clear
                @ht.get_payload_in.unplug2 source.get_full_name 
                loc.unplug2 loc.get_source.get_full_name
                loc <= source

                attempts += 1
                retry
            end 

            # * : Linking triggers slot to selected triggers signals (already existing in the authentic circuit).
            @trig.zip(@ht.get_triggers).each { |output, input|
                input <= output
            }

            # * : Adding components added to the netlists components list (used for printing and format conversions).
            @ht.get_components.each do |comp|
                @netlist << comp
            end

            # * : Verification and printing informations 
            @location = (max_delay.to_f / @timings_h.keys.last).round(3)

            if @ht.is_inserted?
                return @netlist
            else 
                raise "Error : internal fault. Ht not correctly inserted."
            end
        end

        def ht_is_inserted?
            @ht.is_inserted?
        end

        def insert zone="random"
            loc, max_stage = select_location(zone, @ht.get_triggers_nb)

            # * : Payload insertion (removing old links and creating new ones)
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
            if @ht.triggers.empty?
                return @ht.get_payload_in.partof.propag_time[@delay_model]
            else
                payload_cumulated_delay = @ht.netlist.cumulated_propag_time 
                trigger_cumulated_delay = @ht.triggers.collect{|trig| trig.partof.cumulated_propag_time}.min
                
                return payload_cumulated_delay - trigger_cumulated_delay
            end
        end 

        def get_payload_delay 
            @ht.get_payload_in.partof.propag_time[@delay_model]
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