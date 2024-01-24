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
            self.get_exact_crit_path_length delay_model
            
            return self.get_inputs.length, self.get_outputs.length, self.components.length, self.get_mean_fanout, self.crit_path_length    
        end

        def get_mean_fanout 
            fanout_list = []

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

            return fanout_list.sum / fanout_list.size
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

            @crit_path_length = get_outputs.collect{|p_out| p_out.get_source.partof.cumulated_propag_time}.max
            return @crit_path_length
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