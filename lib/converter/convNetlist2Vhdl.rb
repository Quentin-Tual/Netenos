# require_relative '../vhdl.rb'
require_relative '../netlist.rb'

require_relative 'gtechGenerator'
require_relative 'gtech_generators/classicGtechGenerator'
require_relative 'gtech_generators/aleaGtechGenerator'

require_relative 'circDescriptor'
require_relative 'circ_descriptors/classicCircDescriptor'
require_relative 'circ_descriptors/aleaCircDescriptor'

module Converter

    class ConvNetlist2Vhdl
        # * : Convert a Netlist to a Vhdl format
        VHDL_IN_NAME_SEP='_'

        def initialize netlist = nil
            @gtech = Netlist::get_gtech
        end

        def vhdl_full_name p
          p.get_full_name.tr($FULL_PORT_NAME_SEP,VHDL_IN_NAME_SEP)
        end

        def gen_gtech gtech_type = "classic"
            class_name = gtech_type.capitalize + 'GtechGenerator'
            gtech_generator_class = Module.const_get("Converter::"+class_name)
            gtech_generator_class.new.gen_gtech
        end

        def generate circ, delay_model = :int_multi, gtech_type = "classic", opts: {}
            class_name = gtech_type.capitalize + 'CircDescriptor'
            # generate_method = "generate_#{gtech_type}".to_sym
            circ_descriptor_class = Module.const_get("Converter::"+class_name)
            circ_descriptor_class.new(circ, delay_model, opts).gen_description
            # self.send(generate_method, circ, delay_model)
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
            wires = circuit.wires.collect{|wire| vhdl_full_name(wire)}
            wires.each do |wire_name|
                code << "signal #{wire_name} : std_logic;"
            end
            signals=circuit.components.collect{|comp| comp.get_outputs}.flatten

            signals.each do |sig|
                code << "signal #{vhdl_full_name(sig)} : std_logic;"
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
                        code << "#{input.name} => #{vhdl_full_name(input.get_source)},"
                    end
                end
                comp.get_outputs.each do |output|
                    # wire=output.fanout.first
                    if output.get_sinks[0].class == Netlist::Wire
                        code << "#{output.name} => #{vhdl_full_name(output.get_sinks[0])},"
                    else
                        code << "#{output.name} => #{vhdl_full_name(output)},"
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
                    code << "#{output.name} <= #{vhdl_full_name(output.get_source)};"
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
            wires = circuit.wires.collect{|wire| vhdl_full_name(wire)}
            wires.each do |wire_name|
                code << "signal #{wire_name} : std_logic;"
            end
            signals=circuit.components.collect{|comp| comp.get_outputs}.flatten

            signals.each do |sig|
                code << "signal #{vhdl_full_name(sig)} : std_logic;"
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
                    code << "#{input.name} => #{vhdl_full_name(input.get_source)},"
                end
                comp.get_outputs.each do |output|
                    # wire=output.fanout.first
                    if output.get_sinks[0].class == Netlist::Wire
                        code << "#{output.name} => #{vhdl_full_name(output.get_sinks[0])},"
                    else
                        code << "#{output.name} => #{vhdl_full_name(output)},"
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
                code << "#{output.name} <= #{vhdl_full_name(output.get_source)};"
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
            wires = circuit.wires.collect{|wire| vhdl_full_name(wire)}
            wires.each do |wire_name|
                code << "signal #{wire_name} : std_logic;"
            end
            signals=circuit.components.collect{|comp| comp.get_outputs}.flatten
            signals.each do |sig|
                code << "signal #{vhdl_full_name(sig)} : std_logic;"
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
                        code << "#{input.name} => #{vhdl_full_name(input.get_source)},"
                    end
                end
                comp.get_outputs.each do |output|
                    # wire=output.fanout.first
                    if output.get_sinks[0].class == Netlist::Wire
                        code << "#{output.name} => #{vhdl_full_name(output.get_sinks[0])},"
                    else
                        code << "#{output.name} => #{vhdl_full_name(output)},"
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
                    code << "#{output.name} <= #{vhdl_full_name(output.get_source)};"
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
