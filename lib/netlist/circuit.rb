require 'thread'  # For Queue
require 'bigdecimal'
require_relative 'port.rb'


module Netlist
    class Circuit
        attr_accessor :name, :ports, :components, :constants, :partof, :wires, :crit_path_length
        attr_reader :transition_probability_h

        def initialize name, partof = nil
            @name = name
            @ports = {:in => [], :out => []}
            @partof = partof
            # ? : possible optimization using 2 different attributes containing gates and components ?
            @components = [] 
            @wires = []
            @constants = []
            @crit_path_length = nil
            @name2obj = {}
        end

        def <<(e)
            e.partof = self
            case e 
                when Constant
                    @constants << e
                    
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
            
            return self.get_nb_inputs, self.get_outputs.length, self.components.length, self.get_mean_fanout, self.crit_path_length    
        end

        def get_nb_inputs
            if @nb_inputs.nil?
                @nb_inputs = get_inputs.length
            else
                @nb_inputs
            end
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

        # def get_insertion_points_names payload_delay
        #     slack_h = get_insertion_points payload_delay
        #     slack_h 
        # end

        def get_insertion_points payload_delay
            # * Returns a list of gate which outputs has a slack greater than the payload delay 
            slack_h = get_slack_hash
            return slack_h.select{|slack, nodes| slack >= payload_delay}.values.flatten.select{|node| !(node.instance_of? Netlist::Port and node.is_global?)}
        end

        def get_slack_hash
            if @crit_path_length.nil?
                raise "Error : Critical path length is not defined for #{self.class.name} #{self.name}. run get_exact_crit_path_length() before."
            end
        
            # Initialize slack for all input ports
            (get_inputs + @components.flat_map(&:get_inputs)).each { |port| port.slack = @crit_path_length }
        
            # Calculate slack for each signal from the output
            get_outputs.each do |primary_output|
                primary_output.slack = @crit_path_length - primary_output.cumulated_propag_time
                source_node = primary_output.get_source_gates
                if source_node.instance_of? Netlist::Wire # is the call is_global? required here ?
                    source_node.slack = primary_output.slack
                    source_node.update_path_slack(primary_output.slack)
                else
                    source_node.update_path_slack(primary_output.slack)
                end
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

            # Add primary outputs to the slack hash
            get_outputs.each do |out_p|
                tmp[out_p.slack] += [out_p]
            end
        
            # Assign default slack to any missed ports
            (get_inputs + @components.flat_map(&:get_inputs)).each do |port|
                if port.slack.nil?
                    port.slack = @crit_path_length
                    tmp[port.slack] += [port]
                end
            end
        
            return tmp.sort_by{|key, value| key}.to_h # ! ERROR : with some benchmark circuits (x2.blif from LGsynth91), 'sort' : comparison of Array with Array failed (ArgumentError)
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

        def clear_cumulated_propag_times
            @components.map do |comp| 
                comp.cumulated_propag_time = 0
            end
        end
        
        def get_exact_crit_path_length delay_model 
            clear_cumulated_propag_times

            get_inputs.each do |p_in|

                p_in.get_sinks.each do |sink|
                    if sink.instance_of?(Netlist::Wire)
                        sink.update_path_delay 0, delay_model
                    elsif sink.is_global?
                        next
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
            if @timings_h.nil?

                # Update timings with given delay_model  
                get_exact_crit_path_length delay_model

                timing_h = @components.each_with_object({}) do |comp,h|
                    if h[comp.cumulated_propag_time]
                        h[comp.cumulated_propag_time] << comp.get_output
                    else
                        h[comp.cumulated_propag_time] = [comp.get_output]
                    end
                end

                @timings_h = timing_h.sort.to_h
            else
                @timings_h
            end
        end 

        def get_transition_probability_h force = false, rounding = get_nb_inputs

            if @transition_probability_h.nil? or force
                h = {}
                computed_gates = Set.new

                next_gates = Queue.new
                
                get_inputs.each do |p_in|
                    h[p_in] = BigDecimal("0.5")
                    p_in.get_sink_gates.each{|sink_gate| next_gates << sink_gate}
                    computed_gates << p_in
                end

                while !next_gates.empty?
                    curr_gate = next_gates.pop

                    source_gates = curr_gate.get_source_gates
                    sources_proba = []
                    if source_gates.all?{|source_gate|computed_gates.include?(source_gate)}
                        source_gates.each do |source_gate|
                            sources_proba << h[source_gate]
                        end
                        h[curr_gate] = curr_gate.compute_transit_proba(sources_proba, rounding)
                        computed_gates << curr_gate
                    else
                        next_gates << curr_gate
                    end

                    sink_gates = curr_gate.get_sink_gates.select{|g| g.is_a? Netlist::Gate}
                    sink_gates.each{|sink_gate| next_gates << sink_gate}
                end

                @transition_probability_h = h
            else 
                @transition_probability_h
            end
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
            if @name2obj[str]
                @name2obj[str]
            else
                @name2obj[str] = @ports.values.flatten.find{|port| port.name == str}
            end
        end
      
        def get_component_named str
            if @name2obj[str]
                @name2obj[str]
            else
                @name2obj[str] = @components.find{|comp| comp.name == str}
            end
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
            return @precedence_grid if @precedence_grid
          
            current_level = 0
            grid = {}
            # Use a Set for current layer to avoid duplicates
            layer = Set.new(get_inputs.flat_map(&:get_sink_gates))
            
            # Process while we have gates in the layer
            until layer.empty?
              next_layer = Set.new
              
              layer.each do |gate|
                next if gate.instance_of?(Netlist::Port)
                grid[gate] = current_level
                next_layer.merge(gate.get_sink_gates)
              end
              
              current_level += 1
              layer = next_layer
            end
          
            # Build the reversed grid
            reversed_grid = {}
            grid.each do |gate, level|
              reversed_grid[level] ||= []
              reversed_grid[level] << gate
            end
          
            @precedence_grid = reversed_grid
        end

        # OLD VERSION, SEE THE PREVIOUS METHOD FOR THE NEW ONE
        # def get_netlist_precedence_grid
        #     if @precedence_grid.nil?
        #         id = 0
        #         grid = {}
        #         layer = get_inputs.collect{|i| i.get_sink_gates}.flatten
        #         layer.each{|g| grid[g] = id}
                
        #         loop do 
        #             id += 1
        #             new_layer = layer.collect{|g| g.get_sink_gates}.flatten
                    
        #             if new_layer.empty?
        #                 break 
        #             else
        #                 new_layer.each do |g| 
        #                     grid[g] = id unless g.instance_of? Netlist::Port
        #                 end
        #                 layer = new_layer
        #             end
        #         end

        #         reversed_grid = {}
        #         (0..grid.values.max).each do |stage|
        #             reversed_grid[stage] = grid.keys.select{|g| grid[g] == stage}
        #         end

        #         @precedence_grid = reversed_grid
        #     else
        #         @precedence_grid
        #     end
        # end

        def cache_inputs_in_name2obj
            @components.each do |comp|
                # @name2obj[comp.name] = comp
                comp.get_inputs.each do |i|
                    @name2obj[i.get_full_name] = i
                end
            end

            @ports.values.flatten.each do |p|
                @name2obj[p.name] = p 
            end
        end

        def clear_name2obj
            @components.each{|g| g.clear_name2obj}
            @name2obj = {}
        end

        def clear_all_cached_data
            @nb_inputs = nil
            @precedence_grid = nil
            @timings_h = nil
            clear_name2obj
            clear_cumulated_propag_times
            @components.each do |g| 
                if g.is_a? Netlist::Gate
                    g.clear_source_gates
                end
            end
        end
    
        def get_ruby_expr output
            get_ruby_expr_util(output.get_source_gates)
        end
        
        def get_ruby_expr_util node
            case node
            when Netlist::Port
                if node.is_global?
                    node.name
                else
                    raise "Error: node is a port but not a primary one."
                end 
            when Netlist::Gate
                # TODO : Si possible de génériciser la fonciton (associer un symbole à chaque porte en attribut constant) 
                case node
                when Netlist::Not
                    "(!(#{get_ruby_expr_util(node.get_source_gates[0])}))"
                when Netlist::Buffer
                    "(#{get_ruby_expr_util(node.get_source_gates[0])})"
                when Netlist::Nand
                    operands = node.get_source_gates.collect{|source_gate| get_ruby_expr_util(source_gate)}
                    str_ops = operands.join(" & ") 
                    "(!( #{str_ops} ))"
                when Netlist::Nor
                    operands = node.get_source_gates.collect{|source_gate| get_ruby_expr_util(source_gate)}
                    str_ops = operands.join(" | ") 
                    "(!( #{str_ops} ))"
                when Netlist::And
                    operands = node.get_source_gates.collect{|source_gate| get_ruby_expr_util(source_gate)}
                    str_ops = operands.join(" & ") 
                    "( #{str_ops} )"
                when Netlist::Or
                    operands = node.get_source_gates.collect{|source_gate| get_ruby_expr_util(source_gate)}
                    str_ops = operands.join(" | ") 
                    "( #{str_ops} )"
                when Netlist::Xor
                    operands = node.get_source_gates.collect{|source_gate| get_ruby_expr_util(source_gate)}
                    str_ops = operands.join(" ^ ") 
                    "( #{str_ops} )"
                else
                    raise "Error: unexpected node Class #{node.class}."
                end
            else
                raise "Error: unexpected node Class #{node.class}."
            end
        end

        def get_eval_proc expr_str, operand_list = expr_str.scan(/i[0-9]+/).uniq.join(",")
            # operand_list = expr_str.scan(/i[0-9]+/).uniq.join(",")
            # operand_list = get_inputs.collect{|i| i.name}.join(",")
            return eval("lambda {|#{operand_list}| #{expr_str}}")
        end

        def get_all_ruby_expr 
            clear_all_cached_data
            exp = {}
            get_outputs.each{|out_p| exp[out_p] = get_ruby_expr(out_p)}
            return exp
        end

        def get_all_eval_procs exp = {}
            eval_proc = {}
            
            exp = get_all_ruby_expr
            exp.each{|o, expr| eval_proc[o] = @circ.get_eval_proc(expr)}
            
            return eval_proc
        end

        def is_primary_output_name? port_name
            return ((port_name[0] == 'o') and !port_name.include?($FULL_PORT_NAME_SEP))
        end

        def is_primary_input_name? port_name
            return ((port_name[0] == 'i') and !port_name.include?($FULL_PORT_NAME_SEP)) # fastest
            # return get_inputs.any?{|in_p| in_p.name == port_name}
        end

        def is_global_port_name? port_name
            return not(port_name.split($FULL_PORT_NAME_SEP).length > 1)
        end

        def save_as path, type="marshal"
            if !path.nil?
                if path[-1] == "/"  
                    sep = ""
                else
                    sep = "/"
                end
            else 
                sep = "" 
            end

            case type
            when "sexp"
                serializer = Serializer.new
                serializer.serialize(self)
                serializer.save_as "#{@name}.sexp"
            else    
                File.write("#{path}#{sep}#{@name}.enl", Marshal.dump(self))
            end
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

        def get_dot_graph delay_model = :int_multi
            Converter::DotGen.new.dot(self, "#{@name}.dot", delay_model)
        end

        def get_output_path node, upstream_path = []
            upstream_path << node
            
            if node.instance_of?(Netlist::Port) and node.is_global? and node.is_output?
                return [upstream_path]
            else
                if node.instance_of?(Netlist::Port) and node.is_global? and node.is_input?
                    downstream_paths = node.get_sinks.collect{|sink_node| get_output_path(sink_node, upstream_path.dup)}
                else
                    downstream_paths = node.partof.get_outputs[0].get_sinks.collect{|sink_node| get_output_path(sink_node, upstream_path.dup)}
                end

                return downstream_paths.flat_map{|el| el.first.is_a?(Array) ? el : [el]}
            end
        end
    end
end
