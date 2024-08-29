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

                when Circuit
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

            get_inputs.each do |in_p|
                count = 0
                in_p.get_sinks.each do |sink|
                    if sink.class == Netlist::Wire
                        count += sink.get_sinks.length
                    else
                        count += 1
                    end
                end
                fanout_list << count
            end

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

        def get_slack_hash delay_model = :int_multi
            if @crit_path_length.nil?
                get_exact_crit_path_length delay_model
            end

            # * For each primary output call the recursive method update_path_slack
            get_outputs.each do |out_p|
                out_p.get_source.partof.update_path_slack(0.0, delay_model)
            end

            # * Associate each slack value existing to all the components containing the same value   
            tmp = @components.each_with_object(Hash.new([])) do |comp, h|
                h[comp.slack] += [comp]
            end

            # * Same with primary inputs 
            get_inputs.each do |in_p|
                tmp[in_p.slack] += [in_p]
            end

            return tmp.sort.to_h
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

            @crit_path_length = get_outputs.collect{|p_out| p_out.get_source.partof.cumulated_propag_time}.max

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

    end
end