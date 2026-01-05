require_relative '../converter.rb'
require 'erb'

module Converter
  class GenCompTestbench
    attr_accessor :stimuli, :netlist_data
    
    def initialize netlist_init, netlist_alt, delay_model, margin: 2
      @delay_model = delay_model
      
      @netlist_init_data = data_extraction(netlist_init, margin)
      @netlist_alt_data = data_extraction(netlist_alt, margin)
      
      crit_path_max = [@netlist_init_data[:crit_path_length], @netlist_alt_data[:crit_path_length]].max
      @netlist_init_data[:crit_path_length] = crit_path_max
      @netlist_alt_data[:crit_path_length] = crit_path_max
      
      @tb_src = Code.new
      @portmap = ""
    end
    
    def data_extraction netlist, margin
      ret = {}
      
      ret[:entity_name] = netlist.name
      
      ret[:ports] = {
        (:in) => netlist.get_inputs.collect{|p| p.name},
        (:out) => netlist.get_outputs.collect{|p| p.name}
      }
      
      ret[:crit_path_length] = (netlist.get_exact_crit_path_length(@delay_model))
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
        @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_templates/tb_comp_template3.vhdl"))
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
    def initialize netlist_init, netlist_alt, delay_model, margin: 2
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
        @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_templates/tb_detect_template2.vhdl"))
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

  class GenRealflowTestbench 

    def initialize mapped_nl, pnr_nl, apnr_nl
      @mapped_nl_data = data_extraction(mapped_nl)
      @pnr_nl_data = data_extraction(pnr_nl)
      @apnr_nl_data = data_extraction(apnr_nl)
    end

    def data_extraction netlist
      { 
        entity_name: netlist.name,
        inputs: netlist.get_inputs.collect{|p| p.name},
        outputs: netlist.get_outputs.collect{|p| p.name}
      }
    end

    def gen_testbench circ_name, stim_file, clk_period = 5, path: ""
      @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/tb_templates/tb_comp_realflow.v"))

      # total_cycles = # Calculer le nombre de vecteurs de test dans le stim_file 
      # bin_vec_stim = # Déterminer la valeur de cette variable dans le stim_file
      tb_entity_name = "tb_#{circ_name}"
      path = "#{tb_entity_name}.v" if path == ""
      bin_vec_stim, stim_cycles = extract_stim_file_info(stim_file).values_at(
        :bin_vec_stim, 
        :stim_cycles
      )
      total_cycles= stim_cycles + 8
      nb_inputs   = @mapped_nl_data[:inputs].length
      nb_outputs  = @mapped_nl_data[:outputs].length
      
      src = @engine.result(binding)
      File.write(path, src)
    end

    def extract_stim_file_info stim_file
      
      header = `head -n 1 #{stim_file}`.chomp.split(';')
      if header[0] == '# Stimuli sequence'
        {
          bin_vec_stim: (header[1] == 'bin'),
          stim_cycles: `grep -vc "^#" #{stim_file}`.chomp.to_i
        }
      else
        raise "Error: Only stim files generated by Netenos are handled."
      end 
    end
  end
end