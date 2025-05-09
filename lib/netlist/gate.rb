require_relative 'port.rb'

module Netlist

    class Gate < Circuit
        attr_accessor :name, :ports, :partof, :propag_time, :cumulated_propag_time, :tag, :decisions, :forbidden_transitions
        attr_reader :slack

        def initialize name = "#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil, nb_inputs = self.class.name.split("::")[1].chars[-1].to_i, nb_outputs = 1
            @name = name
            inputs = []
            nb_inputs.times do |i|
                inputs << Netlist::Port.new("i#{i}",:in)
            end
            outputs=[]
            if nb_outputs > 0
                outputs << Netlist::Port.new("o0",:out)
            end
            @ports = {:in => inputs, :out => outputs}
            @ports.each_value{|io| io.each{|p| p.partof = self}}
            @partof = partof
            @components = [] 
            @name2obj = {}
            @propag_time = {    :one => 1, 
                                :int => (((nb_inputs+1.0)/2.0)).round(3), 
                                :int_rand => (((nb_inputs+1.0)/2.0)*rand(0.9..1.1)).round(3),
                                :fract => (0.3 + ((((nb_inputs+1.0)/2.0)*rand(0.9..1.1))/2.2)).round(3)
                            } # Supposedly in nanoseconds, 2.2 is the max value , 0.3 is the offset to center the distribution at 1.(normalization to fit in the other model)

            klass = self.class.name.split("::")[1]
            if klass == "Xor2"
                @propag_time[:int_multi] = 5
            elsif klass == "Nand2" or klass == "Nor2" 
                @propag_time[:int_multi] = 4
            else
                @propag_time[:int_multi] = 3
            end

            @cumulated_propag_time = 0
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

            if !@source_gates.nil?
                @source_gates = nil
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

        # ! cumulated_propag_time diff between the two sources for the lowest cumulated_propag_time source and same slack as current gate for the other source
        def update_path_slack slack

            # * Get the most critical nodes (latest node to see it's value updated in worst case) in the form of a hash associating the timing to the inputs.
            crit_node = [get_inputs.group_by{|in_p| in_p.get_source_cumul_propag_time}.sort.last].to_h

            # * For each input excluding the critical nodes 
            get_inputs.difference(crit_node.values.flatten).each do |in_p|
                source = in_p.get_source
                input_slack = crit_node.keys[0] - in_p.get_source_cumul_propag_time + slack 
                if in_p.slack.nil? or in_p.slack > input_slack 
                    in_p.slack = input_slack
                    if source.instance_of? Netlist::Wire
                        # * Recursively calls update_path_slack method of the source wire
                        source.update_path_slack(input_slack) # ! Update wire class method update_path_slack
                    elsif source.is_global?
                        # * Set the primary input slack (stops the recursivity)
                        source.slack = input_slack
                    elsif !source.is_global?
                        # * Recursively calls update_path_slack method of the source gate
                        in_p.get_source_comp.update_path_slack(input_slack)
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
                        in_p.get_source_comp.update_path_slack(slack)
                    end
                end
            end
        end

        def update_path_delay elapsed, delay_model
            curr_delay = elapsed + @propag_time[delay_model]

            if curr_delay > @cumulated_propag_time
                @cumulated_propag_time = curr_delay

                get_output.get_sinks.each do |sink|
                    if sink.instance_of? Netlist::Wire
                        sink.update_path_delay(@cumulated_propag_time, delay_model)
                    elsif sink.is_global?
                        sink.cumulated_propag_time = @cumulated_propag_time
                    elsif !sink.is_global?
                        sink.partof.update_path_delay(@cumulated_propag_time, delay_model)
                    end
                end
            end # ends the propagation if this delay is not greater than the old one
        end
        
        def get_sink_gates
            get_output.get_sinks.collect do |sink| 
                if sink.is_a? Netlist::Port and sink.is_global?
                    sink
                else
                    sink.partof
                end
            end
        end

        def get_source_gates force = false
            if @source_gates.nil? or force
                @source_gates = get_inputs.collect do |ip|
                    source = ip.get_source
                    if source.is_a? Netlist::Port and source.is_global?
                        source
                    else
                        source.partof
                    end
                end
            else
                @source_gates
            end
        end

        def clear_name2obj
            @name2obj = {}
        end

        def clear_source_gates
            @source_gates = nil
        end
    end

    class And3 < Gate; end
    class Or3 < Gate; end
    class Xor3 < Gate; end
    class Nand3 < Gate; end
    class Nor3 < Gate; end

    class And2 < Gate
        attr_reader :same_transition_detectable, :opposite_transition_detectable, :controlling_value, :side_input_value

        def initialize *args
            super *args
            @same_transition_detectable = :R
            @opposite_transition_detectable = :F
            @side_input_value = :S1
            @controlling_value = :S0
        end

        def get_input_transition output_transition
            case output_transition
            when :S0 
                return [[:S0,:S0],[:S0,:S1],[:S1,:S0],[:S0,:R],[:R,:S0],[:S0,:F],[:F,:S0],[:R,:F],[:F,:R]]
            when :S1 
                return [[:S1,:S1]]
            when :R
                return [[:S1,:R],[:R,:S1],[:R,:R]]
            when :F
                return [[:S1,:F],[:F,:S1],[:F,:F]]
            else
                raise "Error: Unexpected transition value encountered."
            end
        end

        def get_output_transition input_transitions
            case input_transitions
            when [:S0,:S0], [:S0,:S1], [:S1,:S0], [:R,:F], [:F,:R],[:R,:S0], [:S0,:R], [:F,:S0], [:S0,:F]
                return :S0
            when [:S1,:S1]
                return :S1
            when [:R,:R], [:S1,:R], [:R,:S1]
                return :R
            when [:F,:F], [:S1, :F], [:F, :S1]
                return :F
            else
                raise "Error: Unexpected output transitions values encountered."
            end
        end

        def who_controls input_transitions
            case input_transitions
            when [:S0, :S1], [:S0, :R], [:S0, :F]
                return 0 # i0
            when [:S1, :S0], [:R, :S0],  [:F, :S0]
                return 1 # i1
            when [:S0, :S0], [:F, :F]
                return 2 # both
            else 
                nil # none
            end
        end

        def compute_transit_proba proba_i0, proba_i1, rounding = 5
            ((1.0 - proba_i0 * proba_i1) * (proba_i0 * proba_i1)).round(rounding)
        end
    end

    class Or2 < Gate
        attr_reader :same_transition_detectable, :opposite_transition_detectable, :controlling_value, :side_input_value

        def initialize *args
            super *args
            @same_transition_detectable = :F
            @opposite_transition_detectable = :R
            @side_input_value = :S0
            @controlling_value = :S1
        end

        def get_input_transition output_transition
            case output_transition
            when :S0 
                return [[:S0,:S0]]
            when :S1 
                return [[:S0,:S1],[:S1,:S0],[:S1,:S1],[:S1,:F],[:F,:S1],[:S1,:R],[:R,:S1],[:R,:F],[:F,:R]]
            when :R
                return [[:S0,:R],[:R,:S0],[:R,:R]]
            when :F
                return [[:S0,:F],[:F,:S0],[:F,:F]]
            else
                raise "Error: Unexpected output transition value encountered."
            end
        end

        def get_output_transition input_transitions
            case input_transitions
            when [:S0,:S0]
                return :S0
            when [:S1,:S1], [:S0,:S1], [:S1,:S0], [:R,:F], [:F,:R], [:S1,:R], [:R,:S1], [:S1, :F], [:F, :S1]
                return :S1
            when [:R,:R], [:R,:S0], [:S0,:R]
                return :R
            when [:F,:F], [:F,:S0], [:S0,:F]
                return :F
            else
                raise "Error: Unexpected output transitions values encountered."
            end
        end

        def compute_transit_proba proba_i0, proba_i1, rounding = 5
            ((1.0 - proba_i0) * (1.0 - proba_i1) * (1.0 -((1.0 - proba_i0) * (1.0 - proba_i1)))).round(rounding)
        end
    end
    
    class Xor2 < Gate

        def initialize *args
            super *args
        end

        def get_input_transition output_transition
            case output_transition
            when :S0 
                return [[:S0,:S0],[:S1,:S1],[:R,:R],[:F,:F]]
            when :S1 
                return [[:S0,:S1],[:S1,:S0],[:R,:F],[:F,:R]]
            when :R
                return [[:S0,:R],[:R,:S0],[:S1,:F],[:F,:S1]]
            when :F
                return [[:S0,:F],[:F,:S0],[:S1,:R],[:R,:S1]]
            else
                raise "Error: Unexpected transition value encountered."
            end
        end
        
        def get_output_transition input_transitions
            case input_transitions
            when [:S0,:S0], [:S1,:S1], [:F,:F], [:R,:R]
                return :S0
            when [:S0,:S1], [:S1,:S0], [:R,:F], [:F,:R]
                return :S1
            when [:R,:S0], [:S0,:R], [:S1, :F], [:F, :S1]
                return :R
                return :F
            else
                raise "Error: Unexpected output transitions values encountered."
            end
        end

        def compute_transit_proba proba_i0, proba_i1, rounding = 5
            ((1.0 - (proba_i0 + proba_i1 - 2.0 * proba_i0 * proba_i1)) * (proba_i0 + proba_i1 - 2.0 * proba_i0 * proba_i1)).round(rounding)
        end
    end

    class Nor2 < Gate
        attr_reader :same_transition_detectable, :opposite_transition_detectable, :controlling_value, :side_input_value

        def initialize *args
            super *args
            @same_transition_detectable = :F
            @opposite_transition_detectable = :R
            @side_input_value = :S0
            @controlling_value = :S1
        end

        def get_input_transition output_transition
            case output_transition
            when :S0 
                return [[:S0,:S1],[:S1,:S0],[:S1,:S1],[:S1,:R],[:R,:S1],[:S1,:F],[:F,:S1]]
            when :S1 
                return [[:S0,:S0]]
            when :R
                return [[:S0,:F],[:F,:S0],[:F,:F]]
            when :F
                return [[:S0,:R],[:R,:S0],[:R,:R]]
            else
                raise "Error: Unexpected transition value encountered."
            end
        end

        def get_output_transition input_transitions
            case input_transitions
            when [:S1,:S1], [:S0,:S1], [:S1,:S0], [:R,:F], [:F,:R], [:S1,:R], [:R,:S1], [:S1, :F], [:F, :S1]
                return :S0
            when [:S0,:S0]
                return :S1
            when [:F,:F], [:F,:S0], [:S0,:F]
                return :R
            when [:R,:R], [:R,:S0], [:S0,:R]
                return :F
            else
                raise "Error: Unexpected output transitions values encountered."
            end
        end

        def compute_transit_proba proba_i0, proba_i1, rounding = 5
            ((1.0 - (1.0 - proba_i0) * (1.0 - proba_i1)) * (1.0 - proba_i0) * (1.0 - proba_i1)).round(rounding)
        end
    end

    class Nand2 < Gate
        attr_reader :same_transition_detectable, :opposite_transition_detectable, :controlling_value, :side_input_value

        def initialize *args
            super *args
            @same_transition_detectable = :R
            @opposite_transition_detectable = :F
            @side_input_values = :S1
            @controlling_value = :S0
        end

        def get_input_transition output_transition
            case output_transition
            when :S0 
                return [[:S1,:S1]]
            when :S1 
                return [[:S0,:S0],[:S1,:S0],[:S0,:S1],[:S0,:R],[:R,:S0],[:S0,:F],[:F,:S0]]
            when :R
                return [[:S1,:F],[:F,:S1],[:F,:F]]
            when :F
                return [[:S1,:R],[:R,:S1],[:R,:R]]
            else
                raise "Error: Unexpected transition value encountered."
            end
        end

        def get_output_transition input_transitions
            case input_transitions
            when [:S1,:S1]
                return :S0
            when [:S0,:S0], [:S0,:S1], [:S1,:S0], [:R,:F], [:F,:R],[:R,:S0], [:S0,:R], [:F,:S0], [:S0,:F]
                return :S1
            when [:F,:F], [:S1, :F], [:F, :S1]
                return :R
            when [:R,:R], [:S1,:R], [:R,:S1]
                return :F
            else
                raise "Error: Unexpected output transitions values encountered."
            end
        end

        def compute_transit_proba proba_i0, proba_i1, rounding = 5
            ((proba_i0 * proba_i1) * (1.0 - (proba_i0 * proba_i1))).round(rounding)
        end
    end

    class Not < Gate

        def initialize name="#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil, nb_inputs=1, nb_outputs=1
            @name = name
            inputs = []
            outputs = []
            # if nb_inputs > 0
            nb_inputs.times{|i|
                inputs << Netlist::Port.new("i#{i}",:in)
            }
            # end
            if nb_outputs > 0
                outputs << Netlist::Port.new("o0",:out)
            end
            @ports = {:in => inputs, :out => outputs}
            @ports.each_value{|p| 
                unless p.empty? 
                    p[0].partof = self
                end
            }
            @partof = partof
            @components = []
            @propag_time = {:one => 1, :int => 1.0, :int_multi => 2, :int_rand => 1.0*rand(0.9..1.1).round(3), :fract => (1.0*rand(0.9..1.1) + 0.3).round(3)}
            @cumulated_propag_time = 0
            @slack = 0
            @name2obj = {}

            @decisions = []
            @forbidden_transitions = []
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

        def get_input_transition output_transition
            case output_transition
            when :S0 
                return [[:S1]]
            when :S1 
                return [[:S0]]
            when :R
                return [[:F]]
            when :F
                return [[:R]]
            else
                raise "Error: Unexpected transition value encountered."
            end
        end

        def get_output_transition input_transitions
            case input_transitions
            when :S1
                return :S0
            when :S0
                return :S1
            when :F
                return :R
            when :R
                return :F
            else
                raise "Error: Unexpected output transitions values encountered."
            end
        end

        def compute_transit_proba proba_i0, rounding = 5
            ((1.0 - proba_i0) * proba_i0).round(rounding)
        end
    end

    class Buffer < Gate
        def initialize propag_time=1, name="#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil, nb_inputs=1, nb_outputs=1
            @name = name
            inputs = []
            outputs = []
            # if nb_inputs > 0
            nb_inputs.times{|i|
                inputs << Netlist::Port.new("i#{i}",:in)
            }
            # end
            if nb_outputs > 0
                outputs << Netlist::Port.new("o0",:out)
            end
            @ports = {:in => inputs, :out => outputs}
            @ports.each_value{|p| 
                unless p.empty? 
                    p[0].partof = self
                end
            }
            @partof = partof
            @components = []
            @propag_time = {
                :one => propag_time, 
                :int => propag_time.to_f, 
                :int_multi => propag_time, 
                :int_rand => propag_time*rand(0.9..1.1).round(3), 
                :fract => (propag_time*rand(0.9..1.1) + 0.3).round(3)
            }
            @cumulated_propag_time = 0
            @slack = 0
            @name2obj = {}
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

        def get_input_transition output_transition
            case output_transition
            when :S0 
                return [[:S0]]
            when :S1 
                return [[:S1]]
            when :R
                return [[:R]]
            when :F
                return [[:F]]
            else
                raise "Error: Unexpected transition value encountered."
            end
        end

        def get_output_transition *input_transitions
            case input_transitions
            when :S0
                return :S0
            when :S1
                return :S1
            when :R
                return :R
            when :F
                return :F
            else
                raise "Error: Unexpected output transitions values encountered."
            end
        end

        def compute_transit_proba proba_i0, rounding = 5
            ((1.0 - proba_i0) * proba_i0).round(rounding)
        end
    end

    class Constant < Port
        def initialize name="#{self.class.name.split("::")[1]}#{self.object_id}", partof=nil
            super name, :out, partof
        end

        def get_output 
            return self
        end

        def is_global?
            return true
        end
    end 

    class Zero < Constant; end
    class One < Constant; end

    $DEF_GATE_TYPES = [And2, Or2, Xor2, Not, Nand2, Nor2, Buffer] # TODO : Legacy, verify where it is needed and rename to GTECH only
    $GTECH = $DEF_GATE_TYPES
end