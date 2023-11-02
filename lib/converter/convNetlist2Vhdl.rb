# require_relative '../vhdl.rb'
require_relative '../netlist.rb'

module Netlist

    class ConvNetlist2Vhdl
        # * : Convert a Netlist to a Vhdl not decorated AST.
        # * : Then it will need to be visited to decorate it and verify its correctness.
        # * : Finally the decorated AST will be ready to be deparsed to recover a VHDL source code file (structural). 

        # TODO : Add a "library/use" in headers of the generated file
        # TODO : create a directory containing the vhdl generated and another directory in it with delayed operators package.

        def initialize netlist = nil
            @netlist = netlist
            @sig_tab = {}
            # @ast = VHDL::AST::Root.new
            @timed = false
            @tb = false
        end

        def gen_gtech
            puts "[+] generating VHDL gtech"
            $GTECH.each do |circuit_klass|
                circuit_name= circuit_klass.to_s.split('::').last.downcase.concat("_d")
                case circuit_name
                when "not_d"
                    circuit_instance=circuit_klass.new("test")
                    func_code="o0 <= not i0 after delay;"
                # when Dff
                #     func_code=Code.new
                #     func_code << "process(clk)"
                #     func_code.indent=2
                #     func_code << "if rising_edge(clk) then"
                #     func_code.indent=4
                #     func_code << "q <= d;"
                #     func_code.indent=2
                #     func_code << "end if;"
                #     func_code.indent=0
                #     func_code << "end process;"
                else
                    mdata=circuit_name.match(/\A(\D+)(\d*)/)
                    op=mdata[1]
                    card=(mdata[2] || "0").to_i
                    circuit_instance=circuit_klass.new("test")
                    assign_lhs=circuit_instance.get_outputs.first.name
                    assign_rhs=circuit_instance.get_inputs.map{|input| input.name}.join(" #{op} ")
                    assign_rhs="not #{assign_rhs}" if op=="not"
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
                puts " |--[+] generated '#{filename}'"
            end
        end
    
        def ieee_header
            code=Code.new
            code << "library ieee;"
            code << "use ieee.std_logic_1164.all;"
            code << "use ieee.numeric_std.all;"
            return code
        end
    
        def generate circuit, delay_model = :one
            code=Code.new
            code << ieee_header
            code.newline
            code << "library gtech_lib;"
            code.newline
            code << "entity #{circuit.name} is"
            code.indent=2
            code << "port("
            code.indent=4
            # code << "clk : in  std_logic;"
            circuit.get_inputs.each{|i|  code << "#{i.name} : in  std_logic;"}
            circuit.get_outputs.each{|o| code << "#{o.name} : out std_logic;"}
            code.lines[-1].delete_suffix!(";")
            code.indent=2
            code << ");"
            code.indent=0
            code << "end #{circuit.name};"
            code.newline
            code << "architecture netenos of #{circuit.name} is"
            code.indent=2
            @sig_tab = {}
            sources=(circuit.get_inputs + circuit.components.map{|comp| comp.get_outputs}).flatten
            # wires = circuit.wires.collect{|wire| wire.get_full_name}.flatten
            # wires.each do |wire|
            #     code << "signal #{wire} : std_logic;"
            # end
            signals=circuit.components.collect{|comp| 
                if comp.get_output.get_sinks[0].class == Wire
                    comp.get_output.get_sinks[0]
                else
                    comp.get_outputs
                end
            }.flatten # TODO : This line gets the wire cause each link is a wire in this netlist -> see how to make it with netenos netlist
            signals.each do |sig|
                code << "signal #{sig.get_full_name} : std_logic;"
            end
            code.indent=0
            code << "begin"
            code.indent=2
            code << "----------------------------------"
            code << "-- input to wire connexions "
            code << "----------------------------------"
            # circuit.get_inputs.each do |global_input| # TODO : 'wire' seems to match with my sinks, but in my case it won't be assign statements but only port maps
            #     global_input.get_sinks.each{|sink| sink.name
            #         code << "#{global_input.sink.name} <= #{input.name};"
            #     } 
            # end
            
            code << "----------------------------------"
            code << "-- component interconnect "
            code << "----------------------------------"
            circuit.components.each do |comp|
                comp_entity=comp.class.to_s.split("::").last.downcase
                code << "#{comp.name} : entity gtech_lib.#{comp_entity}_d"
                code.indent=4
                if comp.is_a? Gate
                    code << "generic map(#{comp.propag_time[delay_model]*1000} fs)" # * Conversion from nanoseconds into picoseconds to avoid float in vhdl source code
                end
                code << "port map("
                code.indent=6
                # if comp.is_a? Dff
                #     code << "clk => clk,"
                # end
                comp.get_inputs.each do |input|
                    code << "#{input.name} => #{input.get_source.get_full_name},"
                end
                comp.get_outputs.each do |output|
                    # wire=output.fanout.first
                    if output.get_sinks[0].class == Wire
                        code << "#{output.name} => #{output.get_sinks[0].get_full_name},"
                    else
                        code << "#{output.name} => #{output.get_full_name},"
                    end
                end
                code.lines[-1].delete_suffix!(",")
                code.indent=4
                code << ");"
            end
            code.indent=2
            code << "----------------------------------"
            code << "-- input to wire to output connexions "
            code << "----------------------------------"
            circuit.get_outputs.each do |output|
                code << "#{output.name} <= #{output.get_source.get_full_name};"
            end
            code.indent=0
            code << "end netenos;"
            filename=code.save_as("#{circuit.name}.vhd")
            puts "[+] generated circuit '#{filename}'"
        end
    end

end
