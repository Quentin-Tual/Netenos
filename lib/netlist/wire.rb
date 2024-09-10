module Netlist
    class Wire
        attr_accessor :name, :fanin, :fanout, :partof, :cumulated_propag_time

        def initialize name
            @name = name
            @fanin = nil # Always only one source to the input 
            @fanout = []
            @partof = nil
            @propag_time = {:one => 0.0, :int => 0.0, :int_multi => 0.0, :int_rand => 0.0, :fract => 0.0} 
            @cumulated_propag_time = 0
            @slack = nil
        end

        def <= source 

            if source.nil? 
                raise "Error: nil source given."
            end

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

            if source.is_a? Port or source.is_a? Wire
                source.fanout << self
            else
                pp source.class
                source.get_free_input << self
            end

            if @fanin.nil?
                @fanin = source
            else
                raise "Error : Interface #{self.get_full_name} of #{self.partof.name} already has a source, please verify."
            end
        end

        def pretty_print(pp)
            pp.text self.get_full_name
        end

        def get_source
            return @fanin
        end

        def get_sinks
            return @fanout
        end

        def get_source_comp
            return get_source.class.name == "Netlist::Wire" ? @fanin : @fanin.partof
        end

        def get_sinks_comp
            return get_sinks.collect{|sink| 
                if sink.class.name == "Netlist::Wire" 
                    sink
                else
                    sink.partof
                end
            }
        end

        def get_source_cumul_propag_time
            if @fanin.class.name == "Netlist::Wire" or @fanin.is_global?
                return @fanin.cumulated_propag_time
            else
                return @fanin.partof.cumulated_propag_time
            end
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
            if @fanin.get_full_name == interface_name
                @fanin.fanout.delete(@fanin.get_sink_named(@name))
                @fanin = nil
            else
                get_sink_named(interface_name).fanin = nil
                fanout.select!{|sink| sink.get_full_name == interface_name}
            end
        end

        def unplug2 interface_full_name
            if self.has_source? # then self is a sink
                source = self.get_source
                if source.get_full_name != interface_full_name
                    raise "Error : Impossible to unplug source #{interface_full_name} from sink #{self.get_full_name} because they does not seem connected."
                end

                source.fanout.delete self
                self.fanin = nil
                # In case we still need it later, return a reference
                return source
            else # then self is a source
                sink = self.get_sink_named(interface_full_name.split('_')[1])
                if sink.nil?
                    raise "Error : Impossible to unplug sink #{interface_full_name} from source #{self.get_full_name} because they does not seem connected."
                end
                sink.fanin = nil
                self.fanout.delete sink
                # In case we still need it later, return a reference
                return sink
            end
        end

        def get_sink_named name
            return fanout.find{|i| i.get_full_name == name}
        end

        def has_source?
            return !fanin.nil?
        end

        def update_path_delay elapsed, delay_model
            @cumulated_propag_time = [elapsed + @propag_time[delay_model], @cumulated_propag_time].max
            get_sinks.each do |sink|
                if sink.class.name == "Netlist::Wire"
                    sink.update_path_delay @cumulated_propag_time, delay_model
                elsif !sink.is_global?
                    sink.partof.update_path_delay @cumulated_propag_time, delay_model
                end
            end
        end

        def update_path_slack slack, delay_model 

            # @slack = [slack, @slack].min

            # * Only one "input" for a Wire 
            # crit_node = [get_inputs.group_by{|in_p| in_p.get_source_cum_propag_time}.sort.last].to_h

            # get_inputs.difference(crit_node.values).each do |in_p|
            if slack < @slack
                @slack = slack
                source = get_source
                if source.class.name == "Netlist::Wire"
                    source.update_path_slack(@slack, delay_model)
                elsif source.is_global?
                    source.slack = @slack
                elsif !source.is_global?
                    get_source_comp.update_path_slack(@slack, delay_model)
                end
            end
            # end

            # * Thus if there is only one input there is no critical "node" regarding another
            # crit_node.values.each do |in_p|
            #     in_p.get_source_comp.update_path_slack(0.0 + @slack, delay_model)
            # end
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