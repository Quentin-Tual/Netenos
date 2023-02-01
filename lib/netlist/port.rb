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
end