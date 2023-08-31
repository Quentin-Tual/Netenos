# require './lib/vhdl.rb'
require_relative '../converter.rb'
require 'erb'

module Netlist
    class GenTestbench
        attr_accessor :stimuli, :netlist_data

        def initialize netlist
            @netlist_data = data_extraction(netlist)
            @tb_src = Code.new
            @portmap = ""
            
        end

        def data_extraction netlist
            # * : Extracts data used in testbench ERB template 
            ret = {}
            ret[:entity_name] = netlist.name
            ret[:ports] = {
                (:in) => netlist.get_inputs.collect{|p| p.name},
                (:out) => netlist.get_outputs.collect{|p| p.name}
            }
            # @netlist_data[:nb_port] = netlist.get_ports.length
            ret[:crit_path_length] = (netlist.crit_path_length) + 3
 
            return ret
        end

        def gen_testbench stim_type = :random, freq = 1, nb_cycle = 20
            # * : Generates a VHDL testbench in text format based on a ERB template stored in the project. The option stim is used to indicates if we want stimuli in it or not, the type of stimuli are indicated (random). Frequency at which the circuit will be stimulated can also be specified in args as a multipler of the critical path length.  
            @freq = freq

            gen_arch_body_uut_portmap
            case stim_type
            when :passed
                @stimuli = gen_arch_body_stim_assign(@stimuli)
            when :random
                @stimuli = gen_arch_body_stim_assign(gen_stimuli(stim_type, nb_cycle))
            else
                @stimuli = ""
            end

            # * : Load the template and bind computed values to it
            @engine = ERB.new(IO.read "../lib/converter/tb_template2.vhdl") # tb_template2 is used to only observe, inputs stimulis are entered at nominal frequency. 

            return @engine.result(binding)
        end

        def gen_arch_body_uut_portmap
            # * : Generates uut instantiation and port map 
            @portmap = ""
            @portmap.concat "       nom_clk,\n"
            @netlist_data[:ports][:in].each {|pname|    
                @portmap.concat "       tb_#{pname}"
                @portmap.concat ", \n"
            }
            @netlist_data[:ports][:out].each {|pname|    
                @portmap.concat "       tb_#{pname}"
                @portmap.concat ", \n"
            }
            @portmap.delete_suffix! ", \n"
        end

        def gen_stimuli stim_type, nb_cycle

            inputs_data = {}
            @netlist_data[:ports][:in].each{ |pin|
                inputs_data[pin] = "std_logic"
            }
            # netlist_data[:ports][:out].each{ |pout|
            #     inputs_data[pout] = "bit"
            # }
            generator = GenStim.new
            generator.inputs = inputs_data

            case stim_type
            when :random
                stim_hash = generator.gen_random_stim nb_cycle
            else
                raise "Error : unknown stimulation pattern."
            end

            return stim_hash
        end
    
        def gen_arch_body_stim_assign stim_hash #, nb_cycle
            # * : Only if stimulation option is on, generates stimuli and generates the corresponding assign statements in stim process.
            stim_src = "" 

            nb_cycle = stim_hash.values[0].length # ! Verify if it is really what is expected

            nb_cycle.times{ |i|
                @netlist_data[:ports][:in].each{ |pin|
                    stim_src.concat "           tb_#{pin} <= '#{stim_hash[pin][i]}';\n"
                }
                stim_src.concat "       wait for nom_period;\n"
            }

            return stim_src
        end
    end

# TODO : Add chessboard pattern, sliding one, sliding zero,... simple patterns ?
end