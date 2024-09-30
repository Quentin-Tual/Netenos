module Converter
    Token = Struct.new(:line_type, :data)

    class ConvBlif2Netlist # ! Legacy / associated to Hyle parser, not used and not maintained 

        def initialize
            @netlist = nil
            @nb_inputs = 0
            @nb_outputs = 0
            @token_list = []
            @sym_tab = {}
        end

        def get_nb_inputs path
            File.foreach(path) do |line|
                if line.split[0] == ".inputs"
                    return line.split.length - 1
                end
            end
        end

        def convert path
            file_path = truth_table_2_gates(path)
            parse(file_path)
            delete_unlinked_outputs
            # retrieve_wires
            return @netlist
        end

        def truth_table_2_gates path
            if !File.exist? "/tmp/netenos"
                Dir.mkdir("/tmp/netenos")
            end
            std_o = `yosys-abc -c "read_blif #{path}; read_library #{File.dirname(__FILE__)}/gtech.genlib; map -s; write_blif /tmp/netenos/~#{File.basename(path)}"`
            puts std_o if $VERBOSE
            return "/tmp/netenos/~#{File.basename(path)}"
        end

        def parse_inputs_line line
            if @continued_line == :inputs 
                input_names = line.split
                @continued_line = nil
            else
                input_names = line.split[1..]
            end
            
            if input_names.last == "\\"
                @continued_line = :inputs
                input_names.pop
            end

            input_names.each_with_index do |name, n| 
                next if name == "\\"
                new_port = Netlist::Port.new("i#{n + @nb_inputs}", :in)
                @netlist << new_port
                @sym_tab[name] = new_port
            end

            @nb_inputs += input_names.length
        end

        def parse_outputs_line line 
            if @continued_line == :outputs 
                output_names = line.split
                @continued_line = nil
            else
                output_names = line.split[1..]
            end

            if output_names.last == "\\"
                @continued_line = :outputs
                output_names.pop
            end

            output_names.each_with_index do |name, n| 
                next if name == "\\"
                new_port = Netlist::Port.new("o#{n + @nb_outputs}", :out)
                @netlist << new_port
                @sym_tab[name] = new_port
            end

            @nb_outputs += output_names.length
        end

        def parse_gate_line line
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
        end

        def parse path # lexer
            @continued_line = nil
            File.foreach(path).with_index do |line,i|
                case line
                when /\A#/, /\A\n/
                    next
                when /\A.model/
                    @netlist = Netlist::Circuit.new("circ_#{line.split[-1].split(".")[0]}")
                when /\A.inputs/
                    parse_inputs_line(line)
                when /\A.outputs/
                    parse_outputs_line(line)
                when /\A.gate/
                    parse_gate_line(line)
                when /\A.end/, /\A.exdc/
                    return @netlist
                else
                    case @continued_line
                    when :inputs
                        parse_inputs_line(line)
                    when :outputs
                        parse_outputs_line(line)
                    else
                        raise "Error : Unexpected keyword encountered #{line.split[0]} on line #{i} in file #{path}."
                    end
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
            when "XOR2"
                return Netlist::Xor2.new
            when "INV1"
                return Netlist::Not.new
            when "BUF1"
                return Netlist::Buffer.new 0.0
            when "ZERO0"
                return Netlist::Zero.new # ! Prendre en charge les constantes dans le circuit
            when "ONE0"
                return Netlist::One.new # ! Idem
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

        def delete_unlinked_outputs 
            unlinked_outputs = @netlist.get_outputs.select{|o| o.fanin.nil?}
            unlinked_outputs.each do |o|
                @netlist.ports[:out].delete(o)
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