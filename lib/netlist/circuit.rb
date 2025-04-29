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
        
            # Calculate slack for each output
            get_outputs.each do |primary_output|
                primary_output.slack = @crit_path_length - primary_output.cumulated_propag_time
                source_node = primary_output.get_source_gates
                if source_node.is_a? Netlist::Wire and source_node.is_global?
                    source_node.slack = primary_output.slack
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
                crit_path = get_exact_crit_path_length delay_model

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

                    if curr_gate.is_a? Netlist::Not
                        source_gate = curr_gate.get_source_gates[0]
                        
                        if computed_gates.include?(source_gate)
                            source0_proba = h[source_gate]
                            h[curr_gate] = curr_gate.compute_transit_proba(h[source_gate], rounding)
                            computed_gates << curr_gate
                        else
                            next_gates << curr_gate 
                        end
                    elsif curr_gate.is_a? Netlist::Gate
                        source_gate0, source_gate1 = curr_gate.get_source_gates
                        
                        if computed_gates.include?(source_gate0) and computed_gates.include?(source_gate1)
                            source0_proba = h[source_gate0]
                            source1_proba = h[source_gate1]
                            h[curr_gate] = curr_gate.compute_transit_proba(source0_proba, source1_proba, rounding)
                            computed_gates << curr_gate
                        else
                            next_gates << curr_gate 
                        end
                    end

                    sink_gates = curr_gate.get_sink_gates.select{|g| g.is_a? Netlist::Gate}
                    sink_gates.each{|sink_gate| next_gates << sink_gate}
                    # prioritized, delayed = sink_gates.partition{|g| g.get_source_gates.any?{|source| h[source].nil?}}
                    
                    # prioritized.each{|g| next_gates.unshift(g)}
                    # delayed.each{|g| next_gates.push(g)} 
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

        # TODO : Voir si possible d'optimiser la mémoire utilisée par cette fonction (voire pour toutes les autres fonctions du même style récursivité et tout), peut-être une Queue pour limiter la taille de "layer" ? peut aussi devenir complexe avec des threads.
        def get_netlist_precedence_grid
            if @precedence_grid.nil?
                id = 0
                grid = {}
                layer = get_inputs.collect{|i| i.get_sink_gates}.flatten
                layer.each{|g| grid[g] = id}
                
                loop do 
                    id += 1
                    new_layer = layer.collect{|g| g.get_sink_gates}.flatten
                    
                    if new_layer.empty?
                        break 
                    else
                        new_layer.each do |g| 
                            grid[g] = id unless g.instance_of? Netlist::Port
                        end
                        layer = new_layer
                    end
                end

                reversed_grid = {}
                (0..grid.values.max).each do |stage|
                    reversed_grid[stage] = grid.keys.select{|g| grid[g] == stage}
                end

                @precedence_grid = reversed_grid
            else
                @precedence_grid
            end
        end

        def get_netlist_precedence_grid_old 
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

        # def get_global_expression sig_full_name # ! Optimizable by memorizing an reusing logical cone expressions (for a minimum of more than N gates of depths in the cone possibily) 
        #     global_exp = []

        #     if is_primary_input_name? sig_full_name
        #         return sig_full_name
        #     elsif is_primary_output_name? sig_full_name
        #         global_exp << get_global_expression(get_port_named(sig_full_name).get_source.get_full_name)
        #     else
        #         comp = get_component_named(sig_full_name.split('_')[0])
        #         in_ports = comp.get_inputs
        #         # global_exp = []
          
        #         if comp.class == Netlist::Not
        #             global_exp << "not"
        #             next_full_name = in_ports[0].get_source.get_full_name
        #             if next_full_name[0] == 'w' 
        #                 # Bypass the wire, transparent in a boolean expression
        #                 global_exp << get_global_expression(in_ports[0].get_source.get_source.get_full_name)
        #             else
        #                 global_exp << get_global_expression(next_full_name)
        #             end
        #         elsif comp.class == Netlist::Buffer
        #             global_exp << "buf"
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
        #     if global_exp.length == 1
        #         global_exp.flatten!(1)
        #     end
        #     return global_exp
        # end 

        # def expr_to_h expr # returns an AST like object
        #     if expr.instance_of? Array
        #         if expr[0] == "not" or expr[0] == "buf" # length is 2
        #             return {expr[0] => expr_to_h(expr[1])}
        #         else # length is 3
        #             return {expr[1] => expr_to_h(expr[0]).merge(expr_to_h(expr[2]))}
        #         end
        #     else
        #         return {expr => nil}
        #     end
        # end

        # def get_str_exp exp_h, previous_op = nil 
        #     str = ""
        
        #     # if exp_h.values == [nil]
        #     #     return exp_h.keys[0]
        #     # end
        #     op = exp_h.keys[0]
        #     # if exp_h.keys.length == 1
        #     if op[0] == "i"
        #         str << op
        #     # elsif op == false
        #     #     str << op
        #     elsif op == "not"
        #         str << "(! "
        #         str << get_str_exp(exp_h[op])
        #         str << ")"
        #     else # donc== 2 
        #         str << "("
        #         str << get_str_exp({exp_h[op].keys[0]=> exp_h[op].values[0]})
        #         str << " "
        #         suffix = ""
        #         case op
        #         when "and"
        #             str << "&"
        #         when "or"
        #             str << "|"
        #         when "xor"
        #             str << "^"
        #         when "nand"
        #             str.insert(1,"!(")
        #             str << "&"
        #             suffix = ")"
        #         when "nor"
        #             str.insert(1,"!(")
        #             str << "|"
        #             suffix = ")"
        #         else
        #             raise "Error : Unexpected situation encountered (contained #{op})"
        #         end
        #         str << " "
        #         str << get_str_exp({exp_h[op].keys[1]=> exp_h[op].values[1]})
        #         str << suffix
        #         str << ")"
        #     end
        
        #     return str
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
                case node
                when Netlist::Not
                    "(!(#{get_ruby_expr_util(node.get_source_gates[0])}))"
                when Netlist::Buffer
                    "(#{get_ruby_expr_util(node.get_source_gates[0])})"
                when Netlist::Nand2
                    "(!( #{get_ruby_expr_util(node.get_source_gates[0])} & #{get_ruby_expr_util(node.get_source_gates[1])} ))"
                when Netlist::Nor2
                    "(!( #{get_ruby_expr_util(node.get_source_gates[0])} | #{get_ruby_expr_util(node.get_source_gates[1])} ))"
                when Netlist::And2
                    "(#{get_ruby_expr_util(node.get_source_gates[0])} & #{get_ruby_expr_util(node.get_source_gates[1])})"
                when Netlist::Or2
                    "(#{get_ruby_expr_util(node.get_source_gates[0])} | #{get_ruby_expr_util(node.get_source_gates[1])})"
                when Netlist::Xor2
                    "(#{get_ruby_expr_util(node.get_source_gates[0])} ^ #{get_ruby_expr_util(node.get_source_gates[1])})"
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
            return ((port_name[0] == 'o') and !port_name.include?('_'))
        end

        def is_primary_input_name? port_name
            return ((port_name[0] == 'i') and !port_name.include?('_')) # fastest
            # return get_inputs.any?{|in_p| in_p.name == port_name}
        end

        def is_global_port_name? port_name
            return not(port_name.split('_').length > 1)
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
