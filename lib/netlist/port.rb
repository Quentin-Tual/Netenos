require_relative "wire.rb"
module Netlist
    class Port < Wire
        attr_accessor :name, :partof, :fanin, :fanout, :direction, :slack, :decisions, :forbidden_transitions, :tag

        def initialize name, direction, partof = nil
            super name
            @partof = partof
            @direction = direction
            @slack = nil
            @cumulated_propag_time = 0.0
            @capacitance = 0.0

            @transitions = []
            @forbidden_transitions = []
            @tag = nil
        end

        def is_free?
            if self.is_global?
                if @direction == :in 
                    return fanout.empty?
                else
                    return fanin.nil?
                end
            else
                if @direction == :in
                    return fanin.nil? 
                else
                    return fanout.empty?
                end
            end
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

        def is_wire?
            return false
        end

        def get_full_name
            if self.is_global?
                return @name
            else
                return "#{@partof.name}_#{@name}"     
            end
        end

        def get_dot_name
            if self.is_global?
                return @name
            else
                return "#{@partof.name}:#{@name}"
            end
        end

        def get_sink_gates
            self.get_sinks.collect do |sink| 
                if (sink.instance_of? Netlist::Port and sink.is_global?) 
                    sink
                elsif sink.instance_of? Netlist::Wire
                    sink.fanout.collect{|in_p| in_p.partof}
                else
                    sink.partof
                end
            end
        end

        # def get_source_comp
        #     return get_source.class.name == "Netlist::Wire" ? source : source.partof
        # end

        # def get_sinks_comp
        #     return get_sinks.collect{|sink| 
        #         if sink.class.name == "Netlist::Wire" 
        #             sink
        #         else
        #             sink.partof
        #         end
        #     }
        # end

        # def get_source_cum_propag_time
        #     return get_source.class.name == "Netlist::Wire" ? source.@cumulated_propag_time : source.partof.cumulated_propag_time
        # end

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