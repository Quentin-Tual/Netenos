# require_relative '../vhdl.rb'
require_relative '../netlist.rb'

module Converter

    class ConvNetlist2Vhdl
        # * : Convert a Netlist to a Vhdl format

        def initialize netlist = nil
            @netlist = netlist
            @sig_tab = {}
            @timed = false
            @tb = false
        end

        def gen_gtech gtech_type = "classic"
            gen_gtech_method = "gen_gtech_#{gtech_type}".to_sym 
            self.send(gen_gtech_method)
        end

        def generate circ, delay_model = :one, gtech_type = "classic",
            generate_method = "generate_#{gtech_type}".to_sym
            self.send(generate_method, circ, delay_model)
        end

        def gen_gtech_classic
            if $VERBOSE
                puts "[+] generating VHDL gtech"
            end

            # if !rejection
            #     rejection = ""
            # else 
            #     rejection = "reject delay inertial"
            # end

            $GTECH.each do |circuit_klass|
                circuit_name= circuit_klass.to_s.split('::').last.downcase.concat("_d")
                case circuit_name
                when "not_d"
                    circuit_instance=circuit_klass.new
                    # func_code="o0 <= #{rejection} not i0 after delay;"
                    func_code = "o0 <= not i0 after delay;"
                when "buffer_d"
                    circuit_instance=circuit_klass.new
                    # func_code="o0 <= #{rejection} i0 after delay;"
                    func_code = "o0 <= i0 after delay;"
                else
                    mdata=circuit_name.match(/\A(\D+)(\d*)/)
                    op=mdata[1]
                    card=(mdata[2] || "0").to_i
                    circuit_instance=circuit_klass.new
                    assign_lhs=circuit_instance.get_outputs.first.name
                    assign_rhs=circuit_instance.get_inputs.map{|input| input.name}.join(" #{op} ")
                    assign_rhs="not #{assign_rhs}" if op=="not"
                    # assign="#{assign_lhs} <= #{rejection} #{assign_rhs} after delay;"
                    assign="#{assign_lhs} <= #{assign_rhs} after delay;"
                    func_code=assign
                end
        
                code=Code.new
                code << "--generated automatically"
                code << ieee_header
                code.newline
                code << "entity #{circuit_name} is"
                code.indent=2
                code << "generic(delay : time := 1 ps);"
                code << "port("
                code.indent=4
                # if circuit_instance.is_a?(Dff)
                #     code << "clk : in std_logic;"
                # end
                circuit_instance.get_inputs.each do |input|
                    code << "#{input.name} : in  std_logic;"
                end
                circuit_instance.get_outputs.each do |output|
                    code << "#{output.name} : out std_logic;"
                end
                code.lines[-1].delete_suffix!(";")
                code.indent=2
                code << ");"
                code.indent=0
                code << "end #{circuit_name};"
                code.newline
                code << "architecture rtl of #{circuit_name} is"
                code << "begin"
                code.indent=2
                code << func_code
                code.indent=0
                code << "end rtl;"
        
                filename=code.save_as("#{circuit_name}.vhd")
                if $VERBOSE
                    puts " |--[+] generated '#{filename}'"
                end
            end
        end


        def gen_gtech_risefall
            if $VERBOSE
                puts "[+] generating VHDL \"rise/fall\" gtech"
            end

            $GTECH.each do |circuit_klass|
                circuit_name= circuit_klass.to_s.split('::').last.downcase.concat("_d")
                func_code = ""
                case circuit_name
                when "not_d"
                    circuit_instance=circuit_klass.new
                    true_condition = "i0='0'"
                    false_condition = "i0='1'"
                    # func_code << "o0 <= reject delay inertial not i0 after delay;"
                    func_code << "\to0 <= curr_output;\n"
                    func_code << "\tprocess(i0)\n"
                    func_code << "\tbegin\n"
                    func_code << "\t\tif #{true_condition} then\n"
                    func_code << "\t\t\tcurr_output <= not i0 after rising;\n"
                    func_code << "\t\telsif #{false_condition} then\n"
                    func_code << "\t\t\tcurr_output <= not i0 after falling;\n"
                    func_code << "\t\telse\n"
                    func_code << "\t\t\tcurr_output <= 'U';\n"
                    func_code << "\t\tend if;\n"
                    func_code << "\tend process;\n"
                when "buffer_d"
                    circuit_instance=circuit_klass.new
                    true_condition = "i0='1'"
                    false_condition = "i0='0'"
                    # func_code << "o0 <= reject delay inertial not i0 after delay;"
                    func_code << "\to0 <= curr_output;\n"
                    func_code << "\tprocess(i0)\n"
                    func_code << "\tbegin\n"
                    func_code << "\t\tif #{true_condition} then\n"
                    func_code << "\t\t\tcurr_output <= i0 after rising;\n"
                    func_code << "\t\telsif #{false_condition} then\n"
                    func_code << "\t\t\tcurr_output <= i0 after falling;\n"
                    func_code << "\t\telse\n"
                    func_code << "\t\t\tcurr_output <= 'U';\n"
                    func_code << "\t\tend if;\n"
                    func_code << "\tend process;\n"
                    # func_code="o0 <= reject delay inertial i0 after delay;"
                else
                    mdata=circuit_name.match(/\A(\D+)(\d*)/)
                    op=mdata[1]
                    # card=(mdata[2] || "0").to_i
                    circuit_instance=circuit_klass.new
                    assign_lhs=circuit_instance.get_outputs.first.name
                    assign_rhs=circuit_instance.get_inputs.map{|input| input.name}.join(" #{op} ")
                    true_condition=circuit_instance.get_inputs.map{|input| "#{input.name}='1'"}.join(" #{op} ")
                    false_condition = "not(#{true_condition})"
                    # true_condition="not #{assign_rhs}" if op=="not"
                    func_code << "\to0 <= curr_output;\n"
                    func_code << "\tprocess(i0, i1)\n"
                    func_code << "\tbegin\n"
                    func_code << "\t\tif (#{true_condition}) then\n"
                    func_code << "\t\t\tcurr_output <= #{assign_rhs} after rising;\n"
                    func_code << "\t\telsif (#{false_condition}) then\n"
                    func_code << "\t\t\tcurr_output <= #{assign_rhs} after falling;\n"
                    func_code << "\t\telse\n"
                    func_code << "\t\t\tcurr_output <= 'U';\n"
                    func_code << "\t\tend if;\n"
                    func_code << "\tend process;"
                end

                code=Code.new
                code << "--generated automatically"
                code << ieee_header
                code.newline
                code << "entity #{circuit_name} is"
                code.indent=1
                code << "generic("
                code.indent=2
                code << "rising : time := 1 ps;"
                code << "falling : time := 1 ps"
                code.indent=1
                code << ");"
                code << "port("
                code.indent=2
                # if circuit_instance.is_a?(Dff)
                #     code << "clk : in std_logic;"
                # end
                circuit_instance.get_inputs.each do |input|
                    code << "#{input.name} : in  std_logic;"
                end
                circuit_instance.get_outputs.each do |output|
                    code << "#{output.name} : out std_logic;"
                end
                code.lines[-1].delete_suffix!(";")
                code.indent=1
                code << ");"
                code.indent=0
                code << "end #{circuit_name};"
                code.newline
                code << "architecture rtl of #{circuit_name} is"
                code << "\tsignal curr_output : std_logic := 'U';"
                code << "begin"
                code.indent=0
                code << func_code
                code << "end rtl;"
        
                filename=code.save_as("#{circuit_name}.vhd")
                if $VERBOSE
                    puts " |--[+] generated '#{filename}'"
                end
            end
        end

        def gen_gtech_realistic
            if $VERBOSE
                puts "[+] generating VHDL gtech"
            end

            $GTECH.each do |circuit_klass|
                circuit_name= circuit_klass.to_s.split('::').last.downcase.concat("_d")
                func_code = ""
                case circuit_name
                when "not_d"
                    circuit_instance=circuit_klass.new
                    true_condition = "i0='0'"
                    false_condition = "i0='1'"
                    # func_code << "o0 <= reject delay inertial not i0 after delay;"
                    func_code << "\to0 <= curr_output;\n"
                    func_code << "\tprocess(i0)\n"
                    func_code << "\tbegin\n"
                    func_code << "\t\tif #{true_condition} then\n"
                    func_code << "\t\t\tcurr_output <= reject rising_hold inertial not i0 after rising_setup;\n"
                    func_code << "\t\telsif #{false_condition} then\n"
                    func_code << "\t\t\tcurr_output <= reject falling_hold inertial not i0 after falling_setup;\n"
                    func_code << "\t\telse\n"
                    func_code << "\t\t\tcurr_output <= 'U';\n"
                    func_code << "\t\tend if;\n"
                    func_code << "\tend process;\n"
                when "buffer_d"
                    circuit_instance=circuit_klass.new
                    true_condition = "i0='1'"
                    false_condition = "i0='0'"
                    # func_code << "o0 <= reject delay inertial not i0 after delay;"
                    func_code << "\to0 <= curr_output;\n"
                    func_code << "\tprocess(i0)\n"
                    func_code << "\tbegin\n"
                    func_code << "\t\tif #{true_condition} then\n"
                    func_code << "\t\t\tcurr_output <= reject rising_hold inertial i0 after rising_setup;\n"
                    func_code << "\t\telsif #{false_condition} then\n"
                    func_code << "\t\t\tcurr_output <= reject falling_hold inertial i0 after falling_setup;\n"
                    func_code << "\t\telse\n"
                    func_code << "\t\t\tcurr_output <= 'U';\n"
                    func_code << "\t\tend if;\n"
                    func_code << "\tend process;\n"
                    # func_code="o0 <= reject delay inertial i0 after delay;"
                else
                    mdata=circuit_name.match(/\A(\D+)(\d*)/)
                    op=mdata[1]
                    # card=(mdata[2] || "0").to_i
                    circuit_instance=circuit_klass.new
                    assign_lhs=circuit_instance.get_outputs.first.name
                    assign_rhs=circuit_instance.get_inputs.map{|input| input.name}.join(" #{op} ")
                    true_condition=circuit_instance.get_inputs.map{|input| "#{input.name}='1'"}.join(" #{op} ")
                    false_condition="not(#{true_condition})"
                    # true_condition="not #{assign_rhs}" if op=="not"
                    func_code << "\to0 <= curr_output;\n"
                    func_code << "\tprocess(i0, i1)\n"
                    func_code << "\tbegin\n"
                    func_code << "\t\tif (#{true_condition}) then\n"
                    func_code << "\t\t\tcurr_output <= reject rising_hold inertial #{assign_rhs} after rising_setup;\n"
                    func_code << "\t\telsif (#{false_condition}) then\n"
                    func_code << "\t\t\tcurr_output <= reject falling_hold inertial #{assign_rhs} after falling_setup;\n"
                    func_code << "\t\telse\n"
                    func_code << "\t\t\tcurr_output <= 'U';\n"
                    func_code << "\t\tend if;\n"
                    func_code << "\tend process;"
                end

                code=Code.new
                code << "--generated automatically"
                code << ieee_header
                code.newline
                code << "entity #{circuit_name} is"
                code.indent=1
                code << "generic("
                code.indent=2
                code << "rising_hold : time := 1 ps;"
                code << "rising_setup : time := 1 ps;"
                code << "falling_hold : time := 1 ps;"
                code << "falling_setup : time := 1 ps\n\t);"
                code.indent=1
                code << "port("
                code.indent=2
                # if circuit_instance.is_a?(Dff)
                #     code << "clk : in std_logic;"
                # end
                circuit_instance.get_inputs.each do |input|
                    code << "#{input.name} : in  std_logic;"
                end
                circuit_instance.get_outputs.each do |output|
                    code << "#{output.name} : out std_logic;"
                end
                code.lines[-1].delete_suffix!(";")
                code.indent=1
                code << ");"
                code.indent=0
                code << "end #{circuit_name};"
                code.newline
                code << "architecture rtl of #{circuit_name} is"
                code << "\tsignal curr_output : std_logic := 'U';"
                code << "begin"
                code.indent=0
                code << func_code
                code << "end rtl;"
        
                filename=code.save_as("#{circuit_name}.vhd")
                if $VERBOSE
                    puts " |--[+] generated '#{filename}'"
                end
            end
        end

        # def gen_gtech_nldm
            
        # end
    
        def ieee_header
            code=Code.new
            code << "library ieee;"
            code << "use ieee.std_logic_1164.all;"
            code << "use ieee.numeric_std.all;"
            return code
        end

        def generate_risefall circuit, delay_model = :int_multi

            if delay_model != :int_multi
                raise "Error: \"rise/fall\" gtech only accepts multiform integer delay model."
            end

            code=Code.new
            code << ieee_header
            code.newline
            code << "library gtech_lib;"
            code.newline
            code << "entity #{circuit.name} is"
            code.indent=1
            code << "port("
            code.indent=2
            # code << "clk : in  std_logic;"
            circuit.get_inputs.each{|i|  code << "#{i.name} : in  std_logic;"}
            circuit.get_outputs.each{|o| code << "#{o.name} : out std_logic;"}
            code.lines[-1].delete_suffix!(";")
            code.indent=1
            code << ");"
            code.indent=0
            code << "end #{circuit.name};"
            code.newline
            code << "architecture netenos of #{circuit.name} is"
            code.indent=1
            wires = circuit.wires.collect{|wire| wire.get_full_name}
            wires.each do |wire_name|
                code << "signal #{wire_name} : std_logic;"
            end
            signals=circuit.components.collect{|comp| comp.get_outputs}.flatten

            signals.each do |sig|
                code << "signal #{sig.get_full_name} : std_logic;"
            end
            code.indent=0
            code << "begin"
            code.indent=1
            
            code << "----------------------------------"
            code << "-- Components interconnect "
            code << "----------------------------------"
            circuit.components.each do |comp|
                comp_entity=comp.class.to_s.split("::").last.downcase
                code << "#{comp.name} : entity gtech_lib.#{comp_entity}_d"
                code.indent=2
                if comp.is_a? Netlist::Gate
                    code << "generic map("
                    code.indent+=1
                    if comp.propag_time[delay_model] == 0 # for example a buffer with 0 delay in real benchmark circuits 
                        code << "#{comp.propag_time[delay_model]} fs," # rising
                        code << "#{comp.propag_time[delay_model]} fs" # falling
                    else
                        code << "#{(comp.propag_time[delay_model])*1000} fs," # rising
                        code << "#{(comp.propag_time[delay_model] - 2)*1000} fs" # falling
                    end
                    # code << "#{(comp.propag_time[delay_model] + 1)*1000} fs," # rising
                    # code << "#{(comp.propag_time[delay_model] - 1)*1000} fs," # falling
                    
                    code.indent-=1
                    code << ")" # * Conversion from nanoseconds into picoseconds to avoid float in vhdl source code
                end
                code << "port map("
                code.indent=3
                # if comp.is_a? Dff
                #     code << "clk => clk,"
                # end
                comp.get_inputs.each do |input|
                    if input.get_source.is_a?(Netlist::Constant)
                        if input.get_source.instance_of?(Netlist::Zero)
                            code << "#{input.name} => '0',"
                        else
                            code << "#{input.name} => '1',"
                        end 
                    else    
                        code << "#{input.name} => #{input.get_source.get_full_name},"
                    end
                end
                comp.get_outputs.each do |output|
                    # wire=output.fanout.first
                    if output.get_sinks[0].class == Netlist::Wire
                        code << "#{output.name} => #{output.get_sinks[0].get_full_name},"
                    else
                        code << "#{output.name} => #{output.get_full_name},"
                    end
                end
                code.lines[-1].delete_suffix!(",")
                code.indent=2
                code << ");"
            end
            code.indent=1
            code << "----------------------------------"
            code << "-- Wiring primary ouputs "
            code << "----------------------------------"
            circuit.get_outputs.each do |output|
                if output.get_source.is_a? Netlist::Constant
                    code << "#{output.name} <= #{output.get_source.is_a?(Netlist::Zero) ? "'0'" : "'1'"};"
                else
                    code << "#{output.name} <= #{output.get_source.get_full_name};"
                end
            end
            code.indent=0
            code << "end netenos;"
            filename=code.save_as("#{circuit.name}.vhd")
            if $VERBOSE
                puts "[+] generated circuit '#{filename}'"
            end
        end
    
        def generate_realistic circuit, delay_model = :int_multi
            code=Code.new
            code << ieee_header
            code.newline
            code << "library gtech_lib;"
            code.newline
            code << "entity #{circuit.name} is"
            code.indent=1
            code << "port("
            code.indent=2
            # code << "clk : in  std_logic;"
            circuit.get_inputs.each{|i|  code << "#{i.name} : in  std_logic;"}
            circuit.get_outputs.each{|o| code << "#{o.name} : out std_logic;"}
            code.lines[-1].delete_suffix!(";")
            code.indent=1
            code << ");"
            code.indent=0
            code << "end #{circuit.name};"
            code.newline
            code << "architecture netenos of #{circuit.name} is"
            code.indent=1
            wires = circuit.wires.collect{|wire| wire.get_full_name}
            wires.each do |wire_name|
                code << "signal #{wire_name} : std_logic;"
            end
            signals=circuit.components.collect{|comp| comp.get_outputs}.flatten

            signals.each do |sig|
                code << "signal #{sig.get_full_name} : std_logic;"
            end
            code.indent=0
            code << "begin"
            code.indent=1
            
            code << "----------------------------------"
            code << "-- Components interconnect "
            code << "----------------------------------"
            circuit.components.each do |comp|
                comp_entity=comp.class.to_s.split("::").last.downcase
                code << "#{comp.name} : entity gtech_lib.#{comp_entity}_d"
                code.indent=2
                if comp.is_a? Netlist::Gate
                    code << "generic map("
                    code.indent+=1
                    code << "#{((comp.propag_time[delay_model] - 0.25 + 0.25)*1000).to_i} fs," # rising_hold
                    code << "#{((comp.propag_time[delay_model] + 0.25)*1000).to_i} fs," # rising_setup
                    code << "#{(([comp.propag_time[delay_model] - 0.25 - 0.25,0].max)*1000).to_i} fs," # falling_hold
                    code << "#{(([comp.propag_time[delay_model] - 0.25,0].max)*1000).to_i} fs"  # falling_setup
                    code.indent-=1
                    code << ")" # * Conversion from nanoseconds into picoseconds to avoid float in vhdl source code
                end
                code << "port map("
                code.indent=3
                # if comp.is_a? Dff
                #     code << "clk => clk,"
                # end
                comp.get_inputs.each do |input|
                    code << "#{input.name} => #{input.get_source.get_full_name},"
                end
                comp.get_outputs.each do |output|
                    # wire=output.fanout.first
                    if output.get_sinks[0].class == Netlist::Wire
                        code << "#{output.name} => #{output.get_sinks[0].get_full_name},"
                    else
                        code << "#{output.name} => #{output.get_full_name},"
                    end
                end
                code.lines[-1].delete_suffix!(",")
                code.indent=2
                code << ");"
            end
            code.indent=1
            code << "----------------------------------"
            code << "-- Wiring primary ouputs "
            code << "----------------------------------"
            circuit.get_outputs.each do |output|
                code << "#{output.name} <= #{output.get_source.get_full_name};"
            end
            code.indent=0
            code << "end netenos;"
            filename=code.save_as("#{circuit.name}.vhd")
            if $VERBOSE
                puts "[+] generated circuit '#{filename}'"
            end
        end

        def generate_classic circuit, delay_model = :one
            code=Code.new
            code << ieee_header
            code.newline
            code << "library gtech_lib;"
            code.newline
            code << "entity #{circuit.name} is"
            code.indent=1
            code << "port("
            code.indent=2
            # code << "clk : in  std_logic;"
            circuit.get_inputs.each{|i|  code << "#{i.name} : in  std_logic;"}
            circuit.get_outputs.each{|o| code << "#{o.name} : out std_logic;"}
            code.lines[-1].delete_suffix!(";")
            code.indent=1
            code << ");"
            code.indent=0
            code << "end #{circuit.name};"
            code.newline
            code << "architecture netenos of #{circuit.name} is"
            code.indent=1
            wires = circuit.wires.collect{|wire| wire.get_full_name}
            wires.each do |wire_name|
                code << "signal #{wire_name} : std_logic;"
            end
            signals=circuit.components.collect{|comp| comp.get_outputs}.flatten
            signals.each do |sig|
                code << "signal #{sig.get_full_name} : std_logic;"
            end
            code.indent=0
            code << "begin"
            code.indent=1
            
            code << "----------------------------------"
            code << "-- Components interconnect "
            code << "----------------------------------"
            circuit.components.each do |comp|
                comp_entity=comp.class.to_s.split("::").last.downcase
                code << "#{comp.name} : entity gtech_lib.#{comp_entity}_d"
                code.indent=2
                if comp.is_a? Netlist::Gate
                    code << "generic map(#{(comp.propag_time[delay_model]*1000).to_i} fs)" # * Conversion from nanoseconds into picoseconds to avoid float in vhdl source code
                end
                code << "port map("
                code.indent=3
                # if comp.is_a? Dff
                #     code << "clk => clk,"
                # end
                comp.get_inputs.each do |input|
                    if input.get_source.is_a?(Netlist::Constant)
                        if input.get_source.instance_of?(Netlist::Zero)
                            code << "#{input.name} => '0',"
                        else
                            code << "#{input.name} => '1',"
                        end 
                    else    
                        code << "#{input.name} => #{input.get_source.get_full_name},"
                    end
                end
                comp.get_outputs.each do |output|
                    # wire=output.fanout.first
                    if output.get_sinks[0].class == Netlist::Wire
                        code << "#{output.name} => #{output.get_sinks[0].get_full_name},"
                    else
                        code << "#{output.name} => #{output.get_full_name},"
                    end
                end
                code.lines[-1].delete_suffix!(",")
                code.indent=2
                code << ");"
            end
            code.indent=1
            code << "----------------------------------"
            code << "-- Wiring primary ouputs "
            code << "----------------------------------"
            circuit.get_outputs.each do |output|
                # if output.get_source.get_full_name.include?("Zero") #!DEBUG
                #     pp "here"
                # end
                if output.get_source.is_a? Netlist::Constant
                    code << "#{output.name} <= #{output.get_source.is_a?(Netlist::Zero) ? "'0'" : "'1'"};"
                else
                    code << "#{output.name} <= #{output.get_source.get_full_name};"
                end
            end
            code.indent=0
            code << "end netenos;"
            filename=code.save_as("#{circuit.name}.vhd")
            if $VERBOSE
                puts "[+] generated circuit '#{filename}'"
            end
        end
    end

end
