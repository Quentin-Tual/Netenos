require_relative 'port.rb'
module Netlist
    class Circuit
        attr_accessor :name, :ports, :components, :partof

        def initialize name, partof = nil
            @name = name
            @ports = {:in => [], :out => []}
            @partof = partof
            @components = []
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

                else raise "Error : Unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
            end
        end

        def to_hash
            return {
                :class => self.class.name,
                :data =>    {   
                                :name => @name, 
                                :partof => (@partof == nil ? nil : @partof.name), 
                                :ports =>   {
                                                :in => @ports[:in].collect{|e| e.to_hash},
                                                :out => @ports[:out].collect{|e| e.to_hash}
                                            },
                                :components => (@components == nil ? nil : @components.collect!{|e| e.to_hash})
                            }
            }
        end

        def get_inputs
            @ports[:in]
        end
      
        def get_outputs
            @ports[:out]
        end

        def get_ports
            @ports.values.flattens # ! : flatten nécessaire ? à vérifier
        end

        def get_port_named str
            @ports.values.flatten.find{|port| port.name==str}
        end
      
        def get_component_named str
            @components.find{|comp| comp.name==str}
        end
    end
end