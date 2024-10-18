require_relative 'port.rb'

module Netlist
    class Circuit
        attr_accessor :name, :ports, :components, :partof, :wires, :crit_path_length

        def initialize name, partof = nil
            @name = name
            @ports = {:in => [], :out => []}
            @partof = partof
            # ? : possible optimization using 2 different attributes containing gates and components ?
            @components = [] 
            @wires = []
            @constants = []
            @crit_path_length = nil
        end

        def <<(e)
            e.partof = self
            case e 
                when Port
                    case e.direction
                    when :in
                        @ports[:in] << e
                    when :out
                        @ports[:out] << e
                    end
                    
                when Wire
                    @wires << e
                    e.partof = self

                when Circuit, Gate, Reverse::InvertedGate
                    @components << e
                    e.partof = self
                
                else raise "Error : Unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
            end
        end

        def pretty_print(pp) 
            pp.text @name
        end

        def getNetlistInformations delay_model
            get_exact_crit_path_length delay_model
            
            return self.get_inputs.length, self.get_outputs.length, self.components.length, self.get_mean_fanout, self.crit_path_length    
        end

        def get_mean_fanout 
            fanout_list = []

            # get_inputs.each do |in_p|
            #     count = 0
            #     in_p.get_sinks.each do |sink|
            #         if sink.class == Netlist::Wire
            #             count += sink.get_sinks.length
            #         else
            #             count += 1
            #         end
            #     end
            #     fanout_list << count
            # end

            @components.each do |comp|
                count = 0
                comp.get_outputs.each do |out_p|
                    out_p.get_sinks.each do |sink|
                        if sink.class == Netlist::Wire
                            count += sink.get_sinks.length
                        else
                            count += 1
                        end
                    end
                end
                fanout_list << count
            end

            return (fanout_list.sum.to_f / fanout_list.size).round(2)
        end

        # def get_slack_hash delay_model = :int_multi
        #     if @crit_path_length.nil?
        #         get_exact_crit_path_length delay_model
        #     end

        #     # * For each primary output call the recursive method update_path_slack
        #     get_outputs.each do |out_p|
        #         # source = out_p.get_source 
        #         # if source.is_global?
        #             out_p.slack = @crit_path_length - out_p.cumulated_propag_time
        #             out_p.get_source_gates.update_path_slack(out_p.slack ,delay_model) # ! TEST
        #         # else
        #             # source.partof.update_path_slack(0.0, delay_model)
        #         # end
        #     end

        #     # * Associate each slack value existing to all the components containing the same value   
        #     tmp = @components.each_with_object(Hash.new([])) do |comp, h|
        #         comp.get_inputs.each do |in_p|
        #             h[in_p.slack] += [in_p]
        #         end
        #     end

        #     # * Same with primary inputs 
        #     get_inputs.each do |in_p|
        #         tmp[in_p.slack] += [in_p]
        #     end

        #     return tmp.sort.to_h
        # end

        def get_slack_hash delay_model = :int_multi
            if @crit_path_length.nil?
                get_exact_crit_path_length delay_model
            end
        
            # Initialize slack for all input ports
            (get_inputs + @components.flat_map(&:get_inputs)).each { |port| port.slack = @crit_path_length }
        
            # Calculate slack for each output
            get_outputs.each do |out_p|
                out_p.slack = @crit_path_length - out_p.cumulated_propag_time
                out_p.get_source_gates.update_path_slack(out_p.slack, delay_model)
            end
        
            # Create the slack hash
            tmp = @components.each_with_object(Hash.new([])) do |comp, h|
                comp.get_inputs.each do |in_p|
                    h[in_p.slack] += [in_p]
                end
            end
        
            # Add primary inputs to the slack hash
            get_inputs.each do |in_p|
                tmp[in_p.slack] += [in_p]
            end
        
            # Assign default slack to any missed ports
            (get_inputs + @components.flat_map(&:get_inputs)).each do |port|
                if port.slack.nil?
                    port.slack = @crit_path_length
                    tmp[port.slack] += [port]
                end
            end
        
            return tmp.sort.to_h
        end
        
        def topological_sort
        visited = Set.new
        stack = []
        
        @components.each do |comp|
            if !visited.include?(comp)
            topological_sort_util(comp, visited, stack)
            end
        end
        
        stack
        end
        
        def topological_sort_util(comp, visited, stack)
        visited.add(comp)
        
        comp.get_sinks.each do |sink|
            if !visited.include?(sink)
            topological_sort_util(sink, visited, stack)
            end
        end
        
        stack.unshift(comp)
        end

        def get_exact_crit_path_length delay_model 
            get_inputs.each do |p_in|

                p_in.get_sinks.each do |sink|
                    if sink.class.name == "Netlist::Wire"
                        sink.update_path_delay 0, delay_model
                    else
                        sink.partof.update_path_delay 0, delay_model
                    end
                end
            end

            if get_outputs.empty? 
                raise "Error: No outputs found in circuit #{@name}."
            end

            @crit_path_length = get_outputs.collect do |p_out|
                source = p_out.get_source
                if source.is_a? Netlist::Port and source.is_global?
                    source.cumulated_propag_time
                else
                    source.partof.cumulated_propag_time
                end
            end.max

            if @crit_path_length.nil?
                raise "Error: Nil critical path computed. Please verify circuit structure."
            end

            return @crit_path_length
        end

        def get_timings_hash delay_model = :int_multi
            # * Returns a hash associating delays with each signals of the circuit (comp output)
            
            # Update timings with given delay_model  
            crit_path = get_exact_crit_path_length delay_model

            timing_h = @components.each_with_object({}) do |comp,h|
                if h[comp.cumulated_propag_time]
                    h[comp.cumulated_propag_time] << comp.get_output
                else
                    h[comp.cumulated_propag_time] = [comp.get_output]
                end
            end
            
            return timing_h.sort.to_h
        end 

        def to_hash
            return {
                :circuit => {   
                    :name => @name, 
                    :partof => (@partof == nil ? nil : @partof.name), 
                    :ports =>   {
                                    :in => @ports[:in].collect{|e| e.to_hash},
                                    :out => @ports[:out].collect{|e| e.to_hash}
                                },
                    :components => @components.empty? ? nil : @components.collect{|e| e.to_hash}     
                }
            }
        end

        def get_inputs
            return @ports[:in]
        end
      
        def get_outputs
            return @ports[:out]
        end

        def get_ports
            return @ports.values.flatten # ? : is 'flatten' necessary ?
        end

        def get_port_named str
            return @ports.values.flatten.find{|port| port.name == str}
        end
      
        def get_component_named str
            @components.find{|comp| comp.name == str}
        end

        def get_wire_named str
            @wires.find{|w| w.get_full_name == str}
        end

        def get_free_port 
            self.get_ports.each do |p|
                if p.is_free?
                    return p
                end
            end

            return nil
        end

        def get_free_input
            self.get_inputs.each do |p|
                if p.is_free?
                    return p
                end
            end

            return nil
        end

        def get_free_output
            self.get_outputs.each do |p|
                if p.is_free?
                    return p
                end
            end

            return nil
        end

        def get_netlist_precedence_grid 
            grid = []

            grid << get_outputs.collect do |o| 
                o.get_source_gates
            end
            grid[0].select!{|g| g.is_a? Netlist::Gate}
            
            id = 0

            loop do 
                new_layer = grid[id].collect{|g| g.get_source_gates}.flatten.uniq
                new_layer.select!{|g| g.is_a? Netlist::Gate}

                if !new_layer.empty?
                    grid << new_layer
                    id += 1
                else 
                    break
                end
            end
        
            return grid.reverse
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
            global_exp = []

            if is_primary_input_name? sig_full_name
                return sig_full_name
            elsif is_primary_output_name? sig_full_name
                global_exp << get_global_expression(get_port_named(sig_full_name).get_source.get_full_name)
            else
                comp = get_component_named(sig_full_name.split('_')[0])
                in_ports = comp.get_inputs
                # global_exp = []
          
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

            # pp global_exp  #!DEBUG
            return global_exp
        end 

        def is_primary_output_name? port_name
            return ((port_name[0] == 'o') and !port_name.include?('_'))
        end

        def is_primary_input_name? port_name
            return ((port_name[0] == 'i') and !port_name.include?('_')) # fastest
            # return get_inputs.any?{|in_p| in_p.name == port_name}
        end

        def is_global_port_name? port_name
            return not(port_name.split('_').length > 1)
        end

        def save_as path
            if !path.nil?
                if path[-1] == "/"  
                    sep = ""
                else
                    sep = "/"
                end
            else 
                sep = ""
            end
            File.write("#{path}#{sep}#{@name}.enl", Marshal.dump(self))
        end

        def contains_registers?
            return components.collect{|comp| comp.is_a? Netlist::Register}.include?(true)
        end

        def dfs(node, visited, stack)
            visited.add(node)
            stack.add(node)

            node.get_sink_gates.each do |sink|
                if !visited.include?(sink)
                return true if dfs(sink, visited, stack)
                elsif stack.include?(sink)
                return true
                end
            end

            stack.delete(node)
            false
        end

        def has_combinational_loop?
            visited = Set.new
            stack = Set.new            

            @components.each do |component|
                return true if dfs(component, visited, stack)
            end

            false
        end

    end
end
