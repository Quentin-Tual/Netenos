# require './lib/vhdl.rb'
require_relative '../converter.rb'
require 'erb'

module Converter
    class GenTestbench
        attr_accessor :stimuli, :netlist_data

        def initialize netlist, margin=0, crit_path_length=nil
            @netlist_data = data_extraction(netlist, margin, crit_path_length)
            @tb_src = Code.new
            @portmap = ""
        end

        def data_extraction netlist, margin=0, crit_path_length=nil
            # * : Extracts data used in testbench ERB template 
            ret = {}
            ret[:entity_name] = netlist.name
            ret[:ports] = {
                (:in) => netlist.get_inputs.collect{|p| p.name},
                (:out) => netlist.get_outputs.collect{|p| p.name}
            }
            
            if crit_path_length.nil?
                ret[:crit_path_length] = (netlist.crit_path_length) + margin
            else
                ret[:crit_path_length] = crit_path_length + margin   
            end

            return ret
        end

        def gen_testbench stim_type = :random, freq = 1, circ_name = "circ", nb_cycle = 20, phase: 0, stim_file: "text"
            # * : Generates a VHDL testbench in text format based on a ERB template stored in the project. The option stim is used to indicates if we want stimuli in it or not, the type of stimuli are indicated (random). Frequency at which the circuit will be stimulated can also be specified in args as a multipler of the critical path length.  
            @freq = freq
            @instance_name = circ_name
            @phase = @netlist_data[:crit_path_length] * phase

            gen_arch_body_uut_portmap
            case stim_type
            when String 
                @stim_file_path = stim_type # stim_type is the path to the stim sequence (test vector) file
                @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_template3.vhdl"))
            when :passed
                # gen_arch_body_filebased_stim(@stimuli, circ_name)
                if circ_name.include?("_altered")
                    circ_init_name = circ_name.split("_altered").join
                elsif circ_name.include?("_copied")
                    circ_init_name = circ_name.split("_copied").join
                else 
                    circ_init_name = circ_name
                end
                @stim_file_path = "#{circ_init_name}.txt"
                @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_template3.vhdl")) 
            when :random
                @stimuli = gen_arch_body_stim_assign(gen_stimuli(stim_type, nb_cycle))
                @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_template2.vhdl")) 
            else
                @stimuli = ""
                @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_template2.vhdl")) 
                warn "Warning: No stimuli in testbench for #{circ_name}."
            end
            # * : Load the template and bind computed values to it
            # @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_template2.vhdl")) # tb_template2 is used to only observe, inputs stimulis are entered at nominal frequency. 
            if phase == 0
                @netlist_data[:entity_name] = "#{@netlist_data[:entity_name]}_#{@freq.to_s.split(".").join}_tb"
                filename = "./#{circ_name}_#{freq.to_s.split('.').join}_tb.vhd"
            else
                @netlist_data[:entity_name] = "#{@netlist_data[:entity_name]}_#{@freq.to_s.split(".").join}_#{phase.to_s.split(".").join}_tb"
                filename = "./#{circ_name}_#{freq.to_s.split('.').join}_#{phase.to_s.split(".").join}_tb.vhd"
            end
            
            src = @engine.result(binding)

            
            File.write(filename, src)

            return netlist_data[:ports][:out].collect{|out_name| "tb_#{out_name.downcase}_s"}  
        end

        def gen_arch_body_uut_portmap
            # * : Generates uut instantiation and port map 
            @portmap = ""
            # @portmap.concat "       nom_clk,\n"
            @netlist_data[:ports][:in].length.times {|pname|    
                @portmap.concat "       tb_in(#{pname})"
                @portmap.concat ", \n"
            }
            @netlist_data[:ports][:out].length.times {|pname|    
                @portmap.concat "       tb_out(#{pname})"
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

            nb_cycle = stim_hash.values[0].length 

            nb_cycle.times{ |i|
                @netlist_data[:ports][:in].length.times{ |pin|
                    stim_src.concat "           tb_in(#{pin}) <= '#{stim_hash[pin][i]}';\n"
                }
                stim_src.concat "       wait for nom_period;\n"
            }

            return stim_src
        end
    end

# TODO : Add chessboard pattern, sliding one, sliding zero,... simple patterns ?
end