module Netlist 
        
    class HT 

        # * : An HT netlist is considered as the referense pointing on its payload instance 
        def initialize netlist = nil #, triggers, payload_out, payload_in=nil
            @netlist = nil
            @triggers = []
            @payload_out = nil
            @payload_in = nil
            @components = []
        end

        def is_inserted? 
            # * : Returns a boolean value, being true if all ports of the HT are connected
            @triggers.each do |trig| 
                if trig.is_free?
                    return false
                end
            end

            if @payload_in.is_free? or @payload_out.is_free?
                return false
            end

            return true
        end

        def get_triggers_nb
            return @triggers.length
        end

        def get_payload_out
            return @payload_out
        end

        def get_payload_in
            return @payload_in
        end

        def get_triggers
            return @triggers
        end
        
        def get_components
            return @components
        end
    end

end