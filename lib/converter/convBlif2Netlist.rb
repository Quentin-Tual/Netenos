module Converter
    Token = Struct.new(:line_type, :data)

    class ConvBlif2Netlist # ! Legacy / associated to Hyle parser, not used and not maintained 

        def initialize
            @netlist = nil
            @token_list = []
            @sym_tab = {}
        end

        def convert path
            filename = truth_table_2_gates(path)
            parse(filename) 
            # retrieve_wires
            return @netlist
        end

        def truth_table_2_gates path
            `yosys-abc -c "read_blif #{path}; read_library #{File.dirname(__FILE__)}/gtech.genlib; map; write_blif /tmp/~#{File.basename(path)}"`
            return "/tmp/~#{File.basename(path)}"
        end

        def parse path # lexer
            File.foreach(path) do |line|
                case line
                when /\A#/
                    next
                when /\A.model/x
                    @netlist = Circuit.new(line.split[-1].split(".")[0])
                when /\A.inputs/
                    # @token_list << Token.new(:inputs, line.split[1..])
                    input_names = line.split[1..]
                    input_names.each_with_index do |name, n| 
                        new_port = Netlist::Port.new("i#{n}", :in)
                        @netlist << new_port
                        @sym_tab[name] = new_port
                    end
                when /\A.outputs/
                    # @token_list << Token.new(:ouputs, line.split[1..])
                    output_names = line.split[1..]
                    output_names.each_with_index do |name, n| 
                        new_port = Netlist::Port.new("o#{n}", :out)
                        @netlist << new_port
                        @sym_tab[name] = new_port
                    end
                when /\A.gate/
                    # @token_list << Token.new(:gate, line.split[1..])
                    splitted = line.split
                    gate_type = splitted[1]
                    new_gate = instantiateGate(gate_type)
                    @netlist << new_gate

                    nb_inputs = gate_type[-1].to_i

                    source_signals = splitted[2...nb_inputs+2]
                    source_signals = source_signals.collect{|w| w.split("=")[-1]}
                    process_source_sig(source_signals, new_gate)

                    sink_signals = splitted[2+nb_inputs..]
                    sink_signals = sink_signals.collect{|w| w.split("=")[-1]}
                    process_sink_sig(sink_signals, new_gate)
                when /\A.end/
                    return @netlist
                else
                    raise "Error : Unexpected keyword encountered #{line.split[0]}."
                end
            end
        end

        def instantiateGate gate_type
            case gate_type
            when "AND2"
                return Netlist::And2.new
            when "OR2"
                return Netlist::Or2.new
            when "NAND2"
                return Netlist::Nand2.new
            when "NOR2"
                return Netlist::Nor2.new
            when "XOR"
                return Netlist::Xor2.new
            when "NOT"
                return Netlist::Not.new
            else
                raise "Error : Unknown operator #{gate_type} encountered."
            end
        end

        def process_source_sig source_list, gate
            source_list.each do |source_sig|
                if !@sym_tab.key? source_sig
                    # * Create a wire, add it to @sym_tab
                    # @sym_tab[source_sig] = Netlist::Wire.new(source_sig)
                    @netlist.wires << @sym_tab[source_sig]
                end
                # Relier au signal source
                gate.get_free_input <= @sym_tab[source_sig]
            end
        end

        def process_sink_sig sink_list, gate
            sink_list.each do |sink_sig|
                if !@sym_tab.key? sink_sig
                    # @sym_tab[sink_sig] = Netlist::Wire.new(sink_sig)
                    # @netlist.wires << @sym_tab[sink_sig]
                    @sym_tab[sink_sig] = gate.get_output
                else
                    @sym_tab[sink_sig] <= gate.get_output
                end
            end
        end

        # def retrieve_wires
        #     @netlist.wires.each do |w|
        #         w.get_sinks.each do |sink|
        #             sink.unplug2 w.get_full_name
        #             sink <= w.get_source
        #         end
        #         w.unplug2 w.get_source.get_full_name
        #     end
        #     @netlist.wires = [] 
        # end

    end
end