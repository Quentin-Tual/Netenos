require_relative 'port.rb'

module Netlist

    class Gate < Circuit
        attr_accessor :name, :ports, :partof, :propag_time, :cumulated_propag_time, :tag
        attr_reader :slack

        def initialize name = "#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil, nb_inputs = self.class.name.split("::")[1].chars[-1].to_i
            @name = name
            inputs = []
            nb_inputs.times do |i|
                inputs << Netlist::Port.new("i#{i}",:in)
            end
            @ports = {:in => inputs, :out => [Netlist::Port.new("o0",:out)]}
            @ports.each_value{|io| io.each{|p| p.partof = self}}
            @partof = partof
            @components = [] 
            @propag_time = {    :one => 1.0, 
                                :int => (((nb_inputs+1.0)/2.0)).round(3), 
                                :int_rand => (((nb_inputs+1.0)/2.0)*rand(0.9..1.1)).round(3),
                                :fract => (0.3 + ((((nb_inputs+1.0)/2.0)*rand(0.9..1.1))/2.2)).round(3)
                            } # Supposedly in nanoseconds, 2.2 is the max value , 0.3 is the offset to center the distribution at 1.(normalization to fit in the other model)

            klass = self.class.name.split("::")[1]
            if klass == "Xor2"
                @propag_time[:int_multi] = 2.5
            elsif klass == "Nand2" or klass == "Nor2" 
                @propag_time[:int_multi] = 2.0
            else
                @propag_time[:int_multi] = 1.5
            end

            @cumulated_propag_time = 0.0
            # @slack = nil
            @tag = nil
        end

        def <<(e)
            e.partof = self
            case e 
            when Port
                case e.direction
                when :in
                    if @ports[:in].length < 2
                        @ports[:in] << e
                    else
                        raise "Error : Trying to add a second port to a NOT gate inputs (only 1 input port available)."        
                    end
                when :out
                    if @ports[:out].length < 1 
                    @ports[:out] << e
                    else
                        raise "Error : Trying to add a second output port to a logical gate (2 ports available)." 
                    end
                end
            else 
                raise "Error : Unexpected or unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
            end
        end

        def get_inputs 
            @ports[:in]
        end

        def get_outputs
            @ports[:out]
        end

        def get_output
            @ports[:out][0]
        end

        # ! There is still all the methods using the slack to be fixed (Netlist::get_slash_hash and Inserter::insert is the most of it) 
        def update_path_slack slack, delay_model

            # * Get the most critical nodes (latest node to see it's value updated in worst case) in the form of a hash associating the timing to the inputs.
            crit_node = [get_inputs.group_by{|in_p| in_p.get_source_cum_propag_time}.sort.last].to_h

            # * For each input excluding the critical nodes 
            get_inputs.difference(crit_node.values).each do |in_p|
                source = in_p.get_source
                input_slack = crit_node.keys[0] - in_p.get_source_cum_propag_time + slack 
                if in_p.slack.nil? or in_p.slack > input_slack 
                    in_p.slack = input_slack
                    if source.class.name == "Netlist::Wire"
                        # * Recursively calls update_path_slack method of the source wire
                        source.update_path_slack(input_slack, delay_model) # ! Update wwire class method update_path_slack
                    elsif source.is_global?
                        # * Set the primary input slack (stops the recursivity)
                        source.slack = input_slack
                    elsif !source.is_global?
                        # * Recursively calls update_path_slack method of the source gate
                        in_p.get_source_comp.update_path_slack(input_slack, delay_model)
                    end
                end
            end

            # * For each critical node
            crit_node.values.flatten.each do |in_p|
                source = in_p.get_source
                input_slack = slack # * Because it is the critical node, there is no additionnal time to the slack
                if in_p.slack.nil? or in_p.slack > input_slack
                    in_p.slack = input_slack
                    if source.is_global?
                        # * Set the primary input slack
                        source.slack = slack
                    else
                        # * Recursively calls update_path_slack method of the source gate
                        in_p.get_source_comp.update_path_slack(slack, delay_model)
                    end
                end
            end
        end

        def update_path_delay elapsed, delay_model
            @cumulated_propag_time = [elapsed + @propag_time[delay_model], @cumulated_propag_time].max

            get_output.get_sinks.each do |sink|
                if sink.class.name == "Netlist::Wire"
                    sink.update_path_delay @cumulated_propag_time, delay_model
                elsif !sink.is_global?
                    sink.partof.update_path_delay @cumulated_propag_time, delay_model
                end
            end
        end
        
    end

    class And3 < Gate; end
    class Or3 < Gate; end
    class Xor3 < Gate; end
    class Nand3 < Gate; end
    class Nor3 < Gate; end

    class And2 < Gate; end
    class Or2 < Gate; end
    class Xor2 < Gate; end
    class Nor2 < Gate; end
    class Nand2 < Gate; end

    class Not < Gate

        def initialize name="#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil
            @name = name
            @ports = {:in => [Netlist::Port.new("i0", :in)], :out => [Netlist::Port.new("o0", :out)]}
            @ports.each_value{|p| p[0].partof = self}
            @partof = partof
            @components = []
            @propag_time = {:one => 1.0, :int => 1.0, :int_multi => 1.0, :int_rand => 1.0*rand(0.9..1.1).round(3), :fract => (1.0*rand(0.9..1.1) + 0.3).round(3)}
            @cumulated_propag_time = 0.0
            @slack = 0.0
        end

        def <<(e)
            e.partof = self
            case e 
            when Port
                case e.direction
                when :in
                    if @ports[:in].length < 1
                        @ports[:in] << e
                    else
                        raise "Error : Trying to add a second port to a NOT gate inputs (only 1 input port available)."        
                    end
                when :out
                    if @ports[:out < 1] 
                    @ports[:out] << e
                    else
                        raise "Error : Trying to add a second output port to a logical gate (2 ports available)." 
                    end
                end
            else 
                raise "Error : Unexpected or unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
            end
        end

    end

    class Buffer < Gate
        def initialize propag_time=1.0, name="#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil
            @name = name
            @ports = {:in => [Netlist::Port.new("i0", :in)], :out => [Netlist::Port.new("o0", :out)]}
            @ports.each_value{|p| p[0].partof = self}
            @partof = partof
            @components = []
            @propag_time = {:one => propag_time, :int => propag_time, :int_multi => propag_time, :int_rand => propag_time*rand(0.9..1.1).round(3), :fract => (propag_time*rand(0.9..1.1) + 0.3).round(3)}
            @cumulated_propag_time = 0.0
            @slack = 0.0
        end

        def <<(e)
            e.partof = self
            case e 
            when Port
                case e.direction
                when :in
                    if @ports[:in].length < 1
                        @ports[:in] << e
                    else
                        raise "Error : Trying to add a second port to a NOT gate inputs (only 1 input port available)."        
                    end
                when :out
                    if @ports[:out < 1] 
                    @ports[:out] << e
                    else
                        raise "Error : Trying to add a second output port to a logical gate (2 ports available)." 
                    end
                end
            else 
                raise "Error : Unexpected or unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
            end
        end
    end

    $DEF_GATE_TYPES = [And2, Or2, Xor2, Not, Nand2, Nor2, Buffer] # TODO : Legacy, verify where it is needed and rename to GTECH only
    $GTECH = $DEF_GATE_TYPES
end