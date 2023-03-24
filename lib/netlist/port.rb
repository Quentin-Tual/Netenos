require_relative "wire.rb"
module Netlist
    class Port < Wire
        attr_accessor :name, :partof, :fanin, :fanout, :direction

        def initialize name, direction, partof = nil
            super name
            @partof = partof
            @direction = direction
        end

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
                :port =>    {   
                                :name => @name, 
                                :partof => (@partof == nil ? nil : @partof.name), 
                                :direction => @direction, 
                                :fanin => @fanin == nil ? nil : (
                                    @fanin.class == Wire ? @fanin.to_hash : @fanin.name
                                ),
                                :fanout => @fanout == [] ? nil : (
                                    @fanout.collect{ |interface|
                                        interface.class == Wire ? interface.to_hash : interface.name
                                    }
                                    
                                )
                            }
            }
        end

    end
end