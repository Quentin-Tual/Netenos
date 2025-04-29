module Converter
    Token = Struct.new(:line_type, :data)

    class ConvBlif2Netlist # ! Legacy / associated to Hyle parser, not used and not maintained 

        def initialize
            @netlist = nil
            @nb_inputs = 0
            @nb_outputs = 0
            @token_list = []
            @sym_tab = {:p_in => {}, :p_out => {}, :g_out => {}}

            # TODO : check if yosys-abc is installed, raise exception if its not 
        end

        def get_nb_inputs path
            count = 0

            # multiline_declaration = false
            File.foreach(path) do |line|
                line = line.split
                if line[0] != ".model" and line[0] != "#" and !line.empty?
                    if line[0] == ".inputs" 
                        count += line.length - 1
                    elsif line[0] == ".outputs"
                        return count
                    else
                        count += line.length 
                    end

                    if line[-1] == "\\"
                        count -= 1
                    # else
                    #     return count + line.length
                    end
                end
            end
        end

        def get_nb_inputs2 path
            @netlist = []
            File.foreach(path) do |line|
                splitted_line = line.split
                if splitted_line[0] != ".model" and splitted_line[0] != "#" and !splitted_line.empty?
                    if splitted_line[0] == ".inputs" 
                        parse_inputs_line(line)
                    elsif @continued_line == :inputs
                        parse_inputs_line(line)
                    elsif splitted_line[0] == ".outputs"
                        return @nb_inputs
                    else
                        raise "Error: unknown state during parsing, verify format of the file #{path}.\nLine : #{line}"
                    end
                end
            end
            
        end

        def convert path, truth_table_format: true
            if truth_table_format
                file_path = truth_table_2_gates(path)
            else
                file_path = path
            end
            parse(file_path)
            # delete_unlinked_outputs
            # retrieve_wires
            return @netlist
        end

        def truth_table_2_gates path
            if !File.exist? "/tmp/netenos"
                Dir.mkdir("/tmp/netenos")
            end
            std_o = `yosys-abc -c "read_blif #{path}; read_library #{File.dirname(__FILE__)}/gtech.genlib; strash; map; write_blif /tmp/netenos/~#{File.basename(path)}"`
            # strash; &get -n; &nf; &put
            # if File.exist?("/tmp/netenos/~#{File.basename(path)}")
            #     raise "Error: File #{path} not converted correctly. "
            # end
            puts std_o if $VERBOSE
            return "/tmp/netenos/~#{File.basename(path)}"
        end

        def parse_inputs_line line
            if @continued_line == :inputs 
                input_names = line.split
                @continued_line = nil
            else
                input_names = line.split[1..] # Ignore ".inputs"
            end
            
            if input_names.last == "\\" # Inputs declaration continues on the next line
                @continued_line = :inputs
                input_names.pop
            end

            input_names.each_with_index do |name, n| 
                next if name == "\\" # ! Should never be true cause it is popped just before
                new_port = Netlist::Port.new("i#{n + @nb_inputs}", :in)
                @netlist << new_port
                @sym_tab[:p_in][name] = new_port
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
                @sym_tab[:p_out][name] = new_port

                if @sym_tab[:p_in].key?(name)
                    @sym_tab[:p_out][name] <= @sym_tab[:p_in][name]
                end
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
            File.foreach(path).with_index do |line, i|
                case line
                when /\A#/, /\A\n/
                    next
                when /\A.model/
                    # begin
                        # circ_name = line.split[-1].split(".")[0]
                        # circ_name.tr!("/", "")
                        # if circ_name.empty? or circ_name == "source"
                            circ_name = File.basename(path).split('.').first
                            circ_name.tr!("~", "")
                        # end
                        @netlist = Netlist::Circuit.new("circ_#{circ_name}")
                    # rescue => e
                    #     raise "Error : circuit name not found in line #{i} in file #{path}.\n-> \"#{line}\""
                    # end
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
                        puts "Warning : line #{i} in file #{path} not parsed and ignored."
                        # raise "Error : Unexpected keyword encountered #{line.split[0]} on line #{i} in file #{path}."
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
                if @sym_tab[:p_in].key?(source_sig)
                    gate.get_free_input <= @sym_tab[:p_in][source_sig]
                elsif @sym_tab[:g_out].key?(source_sig)
                    # * Create a wire, add it to @sym_tab
                    # @sym_tab[source_sig] = Netlist::Wire.new(source_sig)
                    # @netlist.wires << @sym_tab[:source][source_sig]

                    gate.get_free_input <= @sym_tab[:g_out][source_sig] 
                elsif @sym_tab[:p_out].key?(source_sig)
                    gate.get_free_input <= @sym_tab[:p_out][source_sig].get_source
                else
                    raise "Error: Unknown signal #{source_sig} encountered during blif to netlist conversion."
                end
                # Relier au signal source
            end
        end

        def process_sink_sig sink_list, gate
            sink_list.each do |sink_sig|

                if @sym_tab[:p_out].key?(sink_sig)
                    # TODO : relier la sortie de gate à la sortie primaire
                    @sym_tab[:p_out][sink_sig] <= gate.get_output
                else
                    # TODO : Ajouter la sortie de la porte g_out
                    @sym_tab[:g_out][sink_sig] = gate.get_output
                end

                # if !@sym_tab[:sink].key?(sink_sig) # si ce n'est pas une sortie primaire
                #     if @sym_tab[:source].key?(sink_sig) # si c'est la sortie d'une porte 
                #         @sym_tab[:sink][sink_sig] = gate.get_output
                #     else
                #     end
                # else
                #     @sym_tab[:sink][sink_sig] <= gate.get_output
                # end
            end
        end

    end
end