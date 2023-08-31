require_relative 'port.rb'
module Netlist
    class Circuit
        attr_accessor :name, :ports, :components, :partof, :wires, :crit_path_length

        def initialize name, partof = nil
            @name = name
            @ports = {:in => [], :out => []}
            @partof = partof
            # ! : Optimisation possible en ayant un champ séparé pour les components de classe Circuit et de classe Gate
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
                    
                when Circuit
                    @components << e
                    e.partof = self

                else raise "Error : Unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
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
            return @ports.values.flatten.find{|port| port.name==str}
        end
      
        def get_component_named str
            @components.find{|comp| comp.name==str}
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

        def contains_registers?
            return components.collect{|comp| comp.is_a? Netlist::Register}.include?(true)
        end
    end
end