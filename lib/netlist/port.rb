require_relative "wire.rb"
module Netlist
    class Port < Wire
        attr_accessor :name, :partof, :fanin, :fanout, :direction

        def initialize name, direction, partof = nil
            super name
            @partof = partof
            @direction = direction
        end

        # def <= source
            
        # end

        def is_partof?
            return partof.nil? 
        end

        def is_input?
            return @direction == :in
        end

        def is_global?
            self.partof.partof.nil?
        end

        def is_output?
            return @direction == :out
        end

        def get_full_name
            if self.is_global?
                return @name
            else
                return "#{@partof.name}:#{@name}"     
            end
        end

        def to_hash
            {
                :class => self.class.name,
                :data =>    {   
                                :name => @name, 
                                :partof => (@partof == nil ? nil : @partof.name), 
                                :direction => @direction, 
                                :fanin => @fanin == nil ? nil : (
                                    @fanin.class == Wire ? @fanin.to_hash : @fanin.name
                                ),
                                :fanout => @fanout == [] ? nil : (
                                    @fanout.class == Wire ? @fanout.to_hash : @fanout.name
                                )

                            }
            }
        end

        # def <=(e) 
        #     case e 
        #     when Wire 
        #         plugWire e
        #         e.plug self
        #     when Port
        #         if (e.direction == self.direction and (e.partof != nil and self.partof != nil)) 
        #             puts "Warning : Global IO wiring detected. Possible unwanted wiring detected between #{e.partof.name}:#{e.name} and #{self.partof.name}:#{self.name}, same direction ports wired."
        #             global_wiring = true
        #         end

        #         case e.direction
        #         when :in
        #             plugPort e
        #         when :out 
        #             if global_wiring
        #                 plugPort e
        #             else
        #                 raise "Error : Wiring can only be applied from output to an input except for global IOs. Please verify."
        #             end
        #         end
        #     else 
        #         raise "Error : Unknown type encountered, cannot wire #{e} to the port #{self}."
        #     end
        # end

        # def plugWire e
        #     if @direction == :in and !self.is_global?
        #         if !@fanin.nil?
        #             puts "Warning : Input port #{self.name} already wired, input source will be replaced" 
        #         end
        #         @fanin = e
        #     else 
        #         @fanout = e
        #     end
        # end

        # def plugPort e
        #     # ! : ici modif d'un ` << e ` vers un ` = [e] ` pour faire fonctionner Netson
        #     @fanout = e        # Many input might be connected to one output 
        #     if (e.fanin != nil and e.fanin.class != String)
        #         puts "Warning : Input port #{e.name} already wired, input source will be replaced" 
        #     end
        #     e.fanin = self     # Only one ouput connected to an input
        # end

    end
end