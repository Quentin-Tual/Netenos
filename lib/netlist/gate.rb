require_relative 'port.rb'

module Netlist

    def self.generate_gtech(max_nb_inputs = 5, excluded_gate_types = ["Buffer","Not","STDCell"])
        types_list = Netlist::DEF_GATE_TYPES.collect{|klass| klass.name.split("::")[1]}
        types_list -= excluded_gate_types 
        (3..max_nb_inputs).each do |nb_inputs|
            types_list.each do |gate_type|
                class_name = gate_type + nb_inputs.to_s
                if !class_exists?("Netlist::" + class_name)
                    create_class(class_name, gate_type)
                end
            end
        end
    end

    def self.get_gtech
        gtech = Netlist::Gate.subclasses.select{|klass| klass.subclasses.empty? and klass != STDCell}
        Netlist::Gate.subclasses.each do |subklass|
            subklass.subclasses.each do |subsubklass|
                gtech << subsubklass if subsubklass.subclasses.empty?
            end
        end
        gtech
    end

    def self.class_exists?(class_name)
        begin
            klass = Module.const_get(class_name)
            return klass.is_a?(Class)
        rescue NameError
            return false
        end
    end

    def self.create_class(class_name, inherit_name)
        klass = Class.new(Object.const_get("Netlist::" + inherit_name)) do
            def initialize(*args)
                super(*args)
            end
        end
        Netlist.const_set(class_name, klass)
        
        klass
    end

    def self.get_SMT_exp_from_pdk class_name, pdk_fun, pdk_ios
        if pdk_ios[class_name].nil?
          raise "Error: #{class_name} not found in #{$PDK_IOS_JSON}"
        end

        if pdk_fun[class_name].nil?
          raise "Error: #{class_name} not found in #{$PDK_FUN_JSON}"
        end

        if pdk_ios[class_name]['outputs'].length != 1
          raise "Error: Standard cells with more or less than 1 output are not handled."
        end

        lib_fun = pdk_fun[class_name].values.first.dup
        lib_fun_ast = Liberty::FunParser.new.parse(lib_fun)
        smt_fun = lib_fun_ast.accept(Bexp::SMTConverter.new)
        # Replace all input names by there netenos equivalent
        smt_fun.map! do |word| 
            if $SMT_KEYWORDS.include? word
                word
            else # Port name
                if pdk_ios[class_name]['inputs'].include? word
                    "i#{pdk_ios[class_name]['inputs'].index(word)}"
                elsif pdk_ios[class_name]['outputs'].include? word
                    "o#{pdk_ios[class_name]['outputs'].index(word)}"
                else 
                    raise "Error: Port name not found for this std cell."
                end
            end
        end
    end

    def self.get_ios_eq_tab ios_h
        ios_h.each_with_object(Hash.new) do |(direction, sub_h), ios_eq_tab|
            sub_h.each do |pname|
                io = "#{direction[0]}#{sub_h.index(pname)}"
                ios_eq_tab[io] = pname
            end
        end
    end

    def self.create_pdk_class(class_name, pdk_fun, pdk_ios)
        unless Netlist.class_exists?(class_name)
            std_cell_name = class_name.downcase
            Object.class_eval <<-RUBY, __FILE__, __LINE__ + 1
                class #{class_name} < #{Netlist::STDCell}
                    attr_reader :scl_ios
                    SMT_EXPR=#{get_SMT_exp_from_pdk(std_cell_name, pdk_fun,pdk_ios)}
                    def initialize( name,
                                    partof = nil,
                                    nb_inputs=#{pdk_ios[std_cell_name]['inputs'].length},
                                    nb_outputs=#{pdk_ios[std_cell_name]['outputs'].length})
                    super
                    @scl_ios = #{get_ios_eq_tab(pdk_ios[std_cell_name])}
                    end
                end
            RUBY
        end
        Netlist.const_get(class_name)
    end

    def self.create_gate(type, nb_inputs, partof = nil)
        if [:and,:or,:not,:nand,:nor,:xor,:buf].include? type
            type_classname = type.to_s.capitalize
            specific_classname = type_classname + nb_inputs.to_s

            # Si la classe n'existe pas encore, la déclarer  
            if !class_exists?("Netlist::" + specific_classname)
                create_class(specific_classname, type_classname)
            end
            Netlist.const_get(specific_classname).new
        else 
            raise "Error: Unknown gate type #{type} encountered."
        end
    end 

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
            @propag_time = {    
                :one => 1, 
                :int => (((nb_inputs+1.0)/2.0)).round(3),
                :int_multi => 1,
                :int_rand => (((nb_inputs+1.0)/2.0)*rand(0.9..1.1)).round(3),                
                :fract => (0.3 + ((((nb_inputs+1.0)/2.0)*rand(0.9..1.1))/2.2)).round(3)
            } # Supposedly in nanoseconds, 2.2 is the max value , 0.3 is the offset to center the distribution at 1.(normalization to fit in the other model)
            
            @cumulated_propag_time = 0
            @slack = nil
            @name2obj = {}
            @tag = nil
        end

        def <<(e)
            e.partof = self
            case e 
            when Port
                case e.direction
                when :in
                    if @ports[:in].length < get_max_input_port
                        @ports[:in] << e
                    else
                        raise "Error : Trying to add a second port to a #{self.class} gate inputs (only 1 input port available)."        
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

        def get_max_input_port
            self.class.name[-1].to_i
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

                if input_slack < 0
                  raise "Error: negative slack not expected, #{in_p} has #{input_slack} slack"
                end

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
                    if source.instance_of? Netlist::Wire
                        source.update_path_slack(input_slack)
                    elsif source.is_global?
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
                elsif sink.instance_of? Netlist::Wire
                    sink.get_sink_gates
                else
                    sink.partof
                end
            end.flatten
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
    class STDCell < Gate; end;

    class And < Gate 
        SMT_EXPR  = ["(and",")"]
        VHDL_OP = "and"
        VHDL_PREFIX = ""
        
        def initialize *args
            super(*args)
            # TODO : set propag_time in function of the number of inputs
            @propag_time[:int_multi] = 1 + get_nb_inputs
        end
    end

    class Or < Gate
        SMT_EXPR  = ["(or",")"]
        VHDL_OP = "or"
        VHDL_PREFIX = ""
        def initialize *args 
          super(*args)
          @propag_time[:int_multi] = 1 + get_nb_inputs
        end
    end
    
    class Nand < Gate 
        SMT_EXPR  = ["(not (and","))"]
        VHDL_OP = "and"
        VHDL_PREFIX = "not"
        def initialize *args
          super(*args) 
          @propag_time[:int_multi] = 2 + get_nb_inputs
        end
    end    
    
    class Nor < Gate 
        SMT_EXPR  = ["(not (or","))"]
        VHDL_OP = "or"
        VHDL_PREFIX = "not"
        def initialize *args
            super(*args)
            @propag_time[:int_multi] = 2 + get_nb_inputs
        end 
    end

    class Xor < Gate
        SMT_EXPR  = ["(xor",")"]
        VHDL_OP = "xor"
        VHDL_PREFIX = ""
        def initialize *args
            super(*args)
            @propag_time[:int_multi] = 3 + get_nb_inputs
        end
    end

    class And2 < And
        def initialize *args
            super(*args)
        end

        def compute_transit_proba transi_proba, rounding = 5
            proba_i0, proba_i1 = transi_proba
            ((1.0 - proba_i0 * proba_i1) * (proba_i0 * proba_i1)).round(rounding)
        end
    end

    class Or2 < Or
        def initialize *args
            super(*args)
        end

        def compute_transit_proba transi_proba, rounding = 5
            proba_i0, proba_i1 = transi_proba
            ((1.0 - proba_i0) * (1.0 - proba_i1) * (1.0 - ((1.0 - proba_i0) * (1.0 - proba_i1)))).round(rounding)
        end
    end
    
    class Xor2 < Xor
        def initialize *args
            super(*args)
        end

        def compute_transit_proba transi_proba, rounding = 5
            proba_i0, proba_i1 = transi_proba
            ((1.0 - (proba_i0 + proba_i1 - 2.0 * proba_i0 * proba_i1)) * (proba_i0 + proba_i1 - 2.0 * proba_i0 * proba_i1)).round(rounding)
        end
    end

    class Nor2 < Nor
        def initialize *args
            super(*args)
        end

        def compute_transit_proba transi_proba, rounding = 5
            proba_i0, proba_i1 = transi_proba
            ((1.0 - (1.0 - proba_i0) * (1.0 - proba_i1)) * (1.0 - proba_i0) * (1.0 - proba_i1)).round(rounding)
        end
    end

    class Nand2 < Nand
        def initialize *args
            super(*args)
        end

        def compute_transit_proba transi_proba, rounding = 5
            proba_i0, proba_i1 = transi_proba
            ((proba_i0 * proba_i1) * (1.0 - (proba_i0 * proba_i1))).round(rounding)
        end
    end

    # class And3 < Gate; end
    # class Or3 < Gate; end
    # class Xor3 < Gate; end
    # class Nand3 < Gate; end
    # class Nor3 < Gate; end

    class Not < Gate
        SMT_EXPR  = ["(not",")"]
        VHDL_OP = "not"
        VHDL_PREFIX = ""

        def initialize name="#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil, nb_inputs=1, nb_outputs=1
            super
            @propag_time = {:one => 1, :int => 1.0, :int_multi => 2, :int_rand => 1.0*rand(0.9..1.1).round(3), :fract => (1.0*rand(0.9..1.1) + 0.3).round(3)}
        end

        def get_max_input_port
          1
        end

        def compute_transit_proba transi_proba, rounding = 5
            proba_i0 = transi_proba.first
            ((1.0 - proba_i0) * proba_i0).round(rounding)
        end
    end

    class Buffer < Gate
        SMT_EXPR  = ["",""]
        
        def initialize name="#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil, nb_inputs=1, nb_outputs=1, propag_time: 1
            args = [name, partof, nb_inputs, nb_outputs]
            super(*args)

            @propag_time = {
                :one => propag_time, 
                :int => propag_time.to_f, 
                :int_multi => propag_time, 
                :int_rand => propag_time*rand(0.9..1.1).round(3), 
                :fract => (propag_time*rand(0.9..1.1) + 0.3).round(3)
            }
        end

        def get_max_input_port
          1
        end

        def compute_transit_proba transi_proba, rounding = 5
            proba_i0 = transi_proba.first
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

    DEF_GATE_TYPES = Netlist::Gate.subclasses # TODO : Legacy, verify where it is needed and rename to GTECH only
    GTECH = [And2, Or2, Xor2, Not, Nand2, Nor2, Buffer]
end