require_relative '../converter.rb'
require 'erb'

module Converter
    class GenCompTestbench
        attr_accessor :stimuli, :netlist_data

        def initialize netlist_init, netlist_alt, delay_model, margin: 0
            @netlist_init_data = data_extraction(netlist_init, margin)
            @netlist_alt_data = data_extraction(netlist_alt, margin)
            
            crit_path_max = [@netlist_init_data[:crit_path_length], @netlist_alt_data[:crit_path_length]].max + 1
            @netlist_init_data[:crit_path_length] = crit_path_max
            @netlist_alt_data[:crit_path_length] = crit_path_max

            @tb_src = Code.new
            @portmap = ""
            @delay_model = delay_model
        end

        def data_extraction netlist, margin
            ret = {}

            ret[:entity_name] = netlist.name
            ret[:ports] = {
                (:in) => netlist.get_inputs.collect{|p| p.name},
                (:out) => netlist.get_outputs.collect{|p| p.name}
            }
            # ret[:crit_path_length] = (netlist.get_exact_crit_path_length(@delay_model))

            ret[:crit_path_length] = netlist.crit_path_length + margin

            return ret
        end

        def gen_testbench stim_type = :random, freq = 1, nb_cycle = 20, phase: 0, bit_vec_stim: false 
            @freq = freq
            @phase = (@netlist_init_data[:crit_path_length] * phase).round(3)
            circ_name = @netlist_init_data[:entity_name]

            gen_init_portmap
            gen_alt_portmap

            case stim_type
            when String 
                @stim_file_path = stim_type # stim_type is the path to the stim sequence (test vector) file
                @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_comp_template.vhdl"))
            else
                raise "Error: stimulus type not available for comparer testbench."
            end

            if phase == 0
                @tb_entity_name = "#{@netlist_init_data[:entity_name]}_#{@freq.to_s.split(".").join}_tb"
                filename = "./#{circ_name}_#{freq.to_s.split('.').join}_tb.vhd"
            else
                @tb_entity_name = "#{@netlist_init_data[:entity_name]}_#{@freq.to_s.split(".").join}_#{phase.to_s.split(".").join}_tb"
                filename = "./#{circ_name}_#{freq.to_s.split('.').join}_#{phase.to_s.split(".").join}_tb.vhd"
            end

            src = @engine.result(binding)

            # filename = "./#{circ_name}_#{freq.to_s.split('.').join}_tb.vhd"
            File.write(filename, src)
            # return src # ! legacy but not necessary, generated src is already stored in a file  
        
        end
            
        def gen_init_portmap
            # * : Generates uut instantiation and port map 
            @portmap_init = ""
            # @portmap.concat "       nom_clk,\n"
            @netlist_init_data[:ports][:in].length.times {|pname|    
                @portmap_init.concat "       tb_in(#{pname})"
                @portmap_init.concat ", \n"
            }
            @netlist_init_data[:ports][:out].length.times {|pname|    
                @portmap_init.concat "       tb_out_init(#{pname})"
                @portmap_init.concat ", \n"
            }
            @portmap_init.delete_suffix! ", \n"
        end

        def gen_alt_portmap
            # * : Generates uut instantiation and port map 
            @portmap_alt = ""
            # @portmap.concat "       nom_clk,\n"
            @netlist_alt_data[:ports][:in].length.times {|pname|    
                @portmap_alt.concat "       tb_in(#{pname})"
                @portmap_alt.concat ", \n"
            }
            @netlist_alt_data[:ports][:out].length.times {|pname|    
                @portmap_alt.concat "       tb_out_alt(#{pname})"
                @portmap_alt.concat ", \n"
            }
            @portmap_alt.delete_suffix! ", \n"
        end
    end

    class GenDetectTestbench < GenCompTestbench
        def initialize netlist_init, netlist_alt, delay_model, margin: 0
            super
        end

        def gen_testbench stim_type = :random, freq = 1, nb_cycle = 20, phase: 0, bit_vec_stim: true
            @freq = freq
            @phase = (@netlist_init_data[:crit_path_length] * phase).round(3)
            circ_name = @netlist_init_data[:entity_name]

            gen_init_portmap
            gen_alt_portmap

            case stim_type
            when String 
                @stim_file_path = stim_type # stim_type is the path to the stim sequence (test vector) file
                @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_detect_template.vhdl"))
            else
                raise "Error: stimulus type not available for comparer testbench."
            end

            if phase == 0
                @tb_entity_name = "#{@netlist_init_data[:entity_name]}_#{@freq.to_s.split(".").join}_tb"
                filename = "./#{circ_name}_#{freq.to_s.split('.').join}_tb.vhd"
            else
                @tb_entity_name = "#{@netlist_init_data[:entity_name]}_#{@freq.to_s.split(".").join}_#{phase.to_s.split(".").join}_tb"
                filename = "./#{circ_name}_#{freq.to_s.split('.').join}_#{phase.to_s.split(".").join}_tb.vhd"
            end

            src = @engine.result(binding)

            # filename = "./#{circ_name}_#{freq.to_s.split('.').join}_tb.vhd"
            File.write(filename, src)
            # return src # ! legacy but not necessary, generated src is already stored in a file  
        
        end
    end

end