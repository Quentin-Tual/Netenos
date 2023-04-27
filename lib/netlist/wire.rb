module Netlist
    class Wire
        attr_accessor :name, :fanin, :fanout

        def initialize name
            @name = name
            @fanin = nil # Always only one source to the input 
            @fanout = []
        end

        def <= source 
            if source.is_a? Port 
                if !source.is_global? and source.is_input?
                    raise "Error : This port #{source.get_full_name} is a non global input and can't be used as a source."
                end
            end
            
            if self.is_a? Port 
                if !self.is_global? and self.is_output?
                    raise "Error : This port #{self.get_full_name} is a non global output and can't be used as a sink."
                end
            end

            source.fanout << self
            
            if @fanin.nil?
                @fanin = source
            else
                raise "Error : Interface #{self.get_full_name} already has a source, please verify."
            end
        end

        def get_source
            return @fanin
        end

        def get_sinks
            return @fanout
        end

        def get_full_name
            return @name
        end

        def get_dot_name
            return @name
        end

        def is_global?
            return true
        end

        def is_wire?
            return true
        end

        def unplug interface_name # * : Apply only to sinks, won't work well on sources
            if @fanin.name == interface_name
                @fanin.fanout.delete(@fanin.get_sink_named(@name))
                @fanin = nil
            else
                get_sink_named(interface_name).fanin = nil
                fanout.delete(get_sink_named(interface_name))
            end
        end

        def get_sink_named name
            return fanout.find{|i| i.name == name}
        end

        def has_source?
            return fanin.nil?
        end

        def to_hash
            return {
                :wire =>    {   
                                :name => @name,
                                :fanin => @fanin == nil ? nil : @fanin.name,
                                :fanout => @fanout == [] ? nil : @fanout.collect{|sink| sink.name}
                            }
            }
        end
        
    end
end