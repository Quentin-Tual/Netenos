require_relative 'port.rb'
module Netlist
    class Circuit
        attr_accessor :name, :ports, :components, :partof

        def initialize name
            @name = name
            @ports = {:in => [], :out => []}
            @partof = nil
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

        def to_hash(*uid_table)
            uid_table << self.object_id
            return {
                :class => self.class.name,
                :data =>    {   
                                :name => @name, 
                                :partof => (@partof == nil ? nil : @partof.name), 
                                :ports =>   {
                                                :in => @ports[:in].collect{|e| e.to_hash uid_table},
                                                :out => @ports[:out].collect{|e| e.to_hash uid_table}
                                            },
                                :components => (@components == nil ? nil : @components.collect!{|e| e.to_hash uid_table})
                            }
            }
        end

        def inputs
            @ports[:in]
        end
      
        def outputs
            @ports[:out]
        end

        def get_port_named str
            @ports.values.flatten.find{|port| port.name==str}
        end
      
        def get_component_named str
            @components.find{|comp| comp.name==str}
        end
    end
end