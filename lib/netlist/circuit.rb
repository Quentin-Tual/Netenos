module Netlist

    class Port
        attr_accessor :name, :partof, :fanin, :fanout, :direction

        def initialize name, direction
            @name = name
            @partof = nil
            @direction = direction
            @fanin = nil # Always only one source to the input 
            @fanout = []
        end

        def <=(e) 
            if (e.direction == self.direction and (e.partof != nil and self.partof != nil)) 
                puts "Warning : Global IO wiring detected. Possible unwanted wiring detected between #{e.name} and #{self.name}, same direction ports wired."
                global_wiring = true
            end

            case e.direction
            when :in
                wire e
            when :out 
                if global_wiring
                    wire e
                else
                    raise "Error : Wiring can only be applied from output to an input except for global IOs. Please verify."
                end
            end
        end

        def wire e
            @fanout << e        # Many input might be connected to one output 
            if (e.fanin != nil and e.fanin.class != String)
                puts "Warning : Input port #{e.name} already wired, input source will be replaced" 
            end
            e.fanin = self     # Only one ouput connected to an input
        end

        def to_hash uid_table
            uid_table << self.object_id
            {
                :class => self.class.name,
                :data =>    {   
                                :name => @name, 
                                :partof => (@partof == nil ? nil : @partof.name), 
                                :direction => @direction, 
                                :fanin => (@fanin == nil ? nil : @fanin.name),
                                :fanout => @fanout == [] ? nil : @fanout.collect!{|e| e.name}
                            }
            }
        end
    end

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