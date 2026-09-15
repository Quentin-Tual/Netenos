require_relative '../converter'

module Converter
  class GenStim
    attr_accessor :inputs, :stim

    def initialize(netlist = nil)
      if netlist.nil?
        @inputs = nil
      else
        @inputs = extract_inputs_from_netlist netlist # Contains the name of each input port of the netlist associated to its type
      end
      @stim = {}
    end

    def extract_inputs_from_netlist(netlist)
      ret = {}
      netlist.get_inputs.each do |p|
        ret[p.name] = 'std_logic' # ! Only bit and std_logic type supported by Netenos yet
      end
      ret
    end

    # TODO : Add optionnal constraints on stimuli generation, allowing to avoid HT triggering

    # def delete_cycles cycle_list
    #     @stim.keys.each do |sig|
    #         cycle_list.each do |i|
    #             @stim[sig].delete_at(i)
    #         end
    #     end
    #     return @stim
    # end

    def gen_exhaustive_trans_stim
      @inputs.each do |pname, _datatype|
        @stim[pname] = ''
      end

      max_value = 2**@inputs.length

      # Generate all possible test vectors (incremental method)
      vec_list = []
      max_value.times do |value|
        bin_value = format('%0*b', @inputs.length, value)
        vec_list << bin_value.reverse # reverse the list to keep the LSB for i0 and the MSB for iN (N : number of inputs - 1)
      end

      # Compute all possible transitions from one vector to another
      # vec_list = vec_list.permutation(2).to_a.flatten
      tmp = []
      vec_list.each_with_index do |x, i|
        vec_list[i + 1..].each do |y|
          tmp << [x, y]
        end
      end
      tmp << vec_list[0]
      vec_list = tmp.flatten!

      vec_list.each do |vec|
        @inputs.each_with_index do |pname, index|
          @stim[pname[0]].concat vec[index]
        end
      end

      @stim
    end

    def gen_exhaustive_incr_stim(_nb_inputs = nil)
      @inputs.each do |pname, _datatype|
        @stim[pname] = ''
      end

      max_value = 2**@inputs.length

      # Generate all possible test vectors (incremental method)
      vec_list = []
      max_value.times do |value|
        bin_value = format('%0*b', @inputs.length, value)
        vec_list << bin_value.reverse # reverse the list to keep the LSB for i0 and the MSB for iN (N : number of inputs - 1)
      end

      # Conv from a list of vector to a dict of vector by signals
      vec_list.each do |vec|
        @inputs.keys.each_with_index do |pname, index|
          @stim[pname].concat vec[index]
        end
      end

      @stim
    end

    def extend_exhaustive_all_trans(vec_list)
      tmp = []
      vec_list.each_with_index do |x, i|
        vec_list[i + 1..].each do |y|
          tmp << [x, y]
        end
      end
      tmp << vec_list[0]

      tmp.flatten
    end

    def gen_random_stim(nb_cycle, _trig_cond = nil)
      @inputs.each do |pname, _pdatatype|
        rand_num = Random.new.rand(2**nb_cycle)
        @stim[pname] = format('%0*b', nb_cycle, rand_num) # preferred for bit stuffing MSBs 0s, forgot if using '.to_s(2). method
      end

      @stim
    end

    def gen_sig_hammer_stim(nb_cycle)
      # ! : Use it cautiausly, with nb_cycle >= 1000 computation increases drastically
      nb_cycle /= (@inputs.length * 4) # 3 transition following each stimuli # ? : Avoid the difference between the given nb_cycle and resulting nb_cycle

      gen_random_stim nb_cycle

      sigHammer_stim = {}

      nb_cycle.times do |n|
        @stim.keys.each do |varying_in|
          @stim.keys.each do |prim_in|
            if sigHammer_stim[prim_in].nil?
              sigHammer_stim[prim_in] = [@stim[prim_in][n]]
            else
              sigHammer_stim[prim_in] << @stim[prim_in][n]
            end
          end

          @stim.keys.each do |prim_in|
            if prim_in == varying_in
              3.times do |_i|
                sigHammer_stim[prim_in] << (sigHammer_stim[prim_in][-1] == '0' ? '1' : '0')
              end
            else
              3.times do |_i|
                sigHammer_stim[prim_in] << @stim[prim_in][n]
              end
            end
          end
        end
      end

      @stim = sigHammer_stim
      @stim
    end

    def verify_ht_activation(trig_cond)
      acc_trig_value = nil
      last_word = nil
      trig_eval = []

      # Replace name by bool value -> move it into another function
      trig_cond.each do |e|
        trig_eval << if e.class != Array
                       if %w[not xor and or nand nor].include?(e)
                         e
                       else
                         bool(@stim[e].last)
                       end
                     else
                       verify_ht_activation(e)
                     end
      end

      # Evaluate the given expression -> move it into another function
      trig_eval.each do |e|
        case e
        when String
          last_word = e
        else # Booléen TrueClass/FalseClass
          case last_word
          when NilClass
            acc_trig_value = e
            last_word = e
          when String
            case last_word
            when 'and'
              acc_trig_value = (acc_trig_value and e)
            when 'nand'
              acc_trig_value = !((acc_trig_value and e))
            when 'or'
              acc_trig_value = acc_trig_value or e
            when 'nor'
              acc_trig_value = !((acc_trig_value or e))
            when 'not'
              acc_trig_value = !e
            when 'xor'
              acc_trig_value = ((acc_trig_value and !e) or (!acc_trig_value and e))
            else
              raise "Error : Unknown operation encounted in stimuli HT triggering verification : #{last_word}, #{e}"
            end
          else
            raise "Error : Unknown operation encounted in stimuli HT triggering verification : #{last_word}, #{e}"
          end
        end
      end

      if acc_trig_value.nil?
        raise "Error : expression could not be evaluated correctly.\n -> expression : #{trig_eval}\n"
      end

      acc_trig_value
    end

    def bool(i)
      return false if i == '0'

      true
    end

    def remove_last_stim
      # removed = []
      @inputs.each do |pname, _pdatatype|
        @stim[pname].pop
      end
      # pp removed
    end

    def get_rand_val(type = 'bit')
      case type
      when 'bit'
        %w[0 1].sample
      when 'std_logic'
        %w[0 1].sample
      else
        raise "Error : During stimuli generation. Only 'bit' data type supported yet."
      end
    end

    def save_csv_stim_as(path)
      src = Code.new
      headers = ''
      @stim.keys.each do |pname|
        headers.concat(pname)
        headers.concat(',')
      end
      headers.delete_suffix!(',')
      src << headers
      @stim.values[0].length.times do |cycle|
        line = ''
        @stim.keys.each do |pname|
          line.concat(@stim[pname][cycle])
          line.concat(',')
        end
        line.delete_suffix!(',')
        src << line
      end

      src.save_as path
    end

    def save_as_txt(path)
      path.concat '.txt' if path[-4..-1] != '.txt' and path[-5..-1] != '.stim'

      src = Code.new
      src << '# Stimuli sequence'

      unless @stim.nil?
        @stim.values[0].length.times do |cycle|
          line = ''
          @stim.keys.each do |pname|
            line << @stim[pname][cycle]
          end
          src << line
        end
      end

      src.save_as path
    end

    def load_txt(path)
      path.concat '.txt' if path[-4..-1] != '.txt' and path[-5..-1] != '.stim'

      File.read(path).split("\n")[1..]
    end

    def convert_vec_list_2_bool(vec_list)
      vec_list.collect do |vec|
        vec.chars.collect do |b|
          !(b == '0')
        end
      end
    end

    def convert_vec_list_2_stim(vec_list)
      # Reinitialize
      @inputs.each do |pname, _datatype|
        @stim[pname] = ''
      end

      return vec_list if vec_list.nil?

      # convert
      vec_list.each do |vec|
        @inputs.keys.each_with_index do |pname, index|
          @stim[pname].concat vec[index]
        end
      end

      @stim
    end

    def conv_stim_2_vec_list(trace)
      vec_list = []

      unless trace.nil?
        trace.values[0].length.times do |cycle|
          line = ''
          trace.keys.each do |pname|
            line << trace[pname][cycle]
          end
          vec_list << line
        end
      end

      vec_list
    end

    def save_vec_list(path, vec_list)
      src = Code.new
      src << '# Stimuli sequence'

      vec_list.each do |vec|
        raise 'Error : nil test vector encountered.' if vec.nil? # ! TEST DEBUG

        src << vec # .reverse
      end

      src.save_as path
    end

    # TODO : Add chessboard pattern, full one, full zero, moving one, moving zero, ... simple patterns ?
  end
end
