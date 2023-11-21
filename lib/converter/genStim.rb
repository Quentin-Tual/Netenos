require_relative '../converter.rb'

module Converter

    class GenStim
        attr_accessor :inputs, :stim

        def initialize netlist = nil
            if netlist.nil?
                @inputs = nil
            else
                @inputs = extract_inputs_from_netlist netlist # Contains the name of each input port of the netlist associated to its type
            end
            @stim = {}
        end

        def extract_inputs_from_netlist netlist
            ret = {}
            netlist.get_inputs.each{ |p|
                ret[p.name] = "std_logic" # ! Only bit type supported by Netenos yet
            }
            return ret
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

        def gen_exhaustive_incr_stim

            @inputs.each do |pname, datatype|
                @stim[pname] = ""
            end

            max_value = 2**@inputs.length

            # Generate all possible test vectors (incremental method)
            vec_list = []
            max_value.times do |value|
                bin_value = '%0*b' % [@inputs.length, value]
                vec_list << bin_value.reverse # reverse the list to keep the LSB for i0 and the MSB for iN (N : number of inputs - 1)
            end

            # Compute all possible transitions from one vector to another
            # vec_list = vec_list.permutation(2).to_a.flatten
            tmp = []
            vec_list.each_with_index do |x,i|
                vec_list[i+1..].each do |y|
                    tmp << [x,y]
                end
            end
            tmp << vec_list[0]
            vec_list = tmp.flatten!

            vec_list.each do |vec| 
                @inputs.each_with_index do |pname, index|
                    @stim[pname[0]].concat vec[index]
                end
            end

            # max_value.times do |value|
            #     bin_value = '%0*b' % [@inputs.length, value]
            #     @inputs.each_with_index do |pname, index|
            #         @stim[pname[0]].concat bin_value[index]
            #     end
            # end

            return @stim
        end

        def gen_random_stim nb_cycle, trig_cond = nil
            @inputs.each { |pname, pdatatype|
                rand_num = Random.new.rand(2**nb_cycle) 
                @stim[pname] = '%0*b' % [nb_cycle, rand_num] # preferred for bit stuffing MSBs 0s, forgot if using '.to_s(2). method
            }

            # ! : Replace by until in order to always have the right stimuli number, even when some are deleted to avoid HT triggering ?
            # until @stim.values.last.length == nb_cycle
            # print"Removed cycle : "
            # nb_cycle.times do |j|
            #     @inputs.each { |pname, pdatatype|
            #         @stim[pname] << get_rand_val(pdatatype)
            #     }
            #     # For each cycle generated, verify if the stimuli added activates the ht trigger, if it does remove them. 
            #     if !trig_cond.nil?
            #         if verify_ht_activation(trig_cond)
            #             # puts "Another one : #{j}"
            #             # puts "triggered by :"
            #             # @stim.keys.each{|pname| print "#{@stim[pname].last}, "}
            #             remove_last_stim
            #             # print "#{j}, "
            #         end
            #     end
            # end

            return @stim
        end

        # TODO : WIP
        def gen_sig_hammer_stim nb_cycle
            # ! : Easier to use with nb_cycle >= 1000
            nb_cycle = nb_cycle/(@inputs.length*4) # 3 transition following each stimuli # ? : Avoid the difference between the given nb_cycle and resulting nb_cycle

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
                            3.times do |i|
                                sigHammer_stim[prim_in] << (sigHammer_stim[prim_in][-1] == "0" ? "1" : "0")
                            end
                        else
                            3.times do |i|
                                sigHammer_stim[prim_in] << @stim[prim_in][n]
                            end
                        end
                    end
                end
            end

            @stim = sigHammer_stim
            return @stim
        end

        def verify_ht_activation trig_cond
            # TODO : Iterate on the expression and stack the result obtained with different operations on generated entry values  

            acc_trig_value = nil
            last_word = nil
            trig_eval = []
           
            # Replace name by bool value -> move it into another function
            trig_cond.each do |e|
                if e.class != Array 
                    if ["not","xor","and","or","nand","nor"].include?(e)
                        trig_eval << e
                    else 
                        trig_eval << bool(@stim[e].last)
                    end
                else
                    trig_eval << verify_ht_activation(e)
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
                        when "and"
                            acc_trig_value = (acc_trig_value and e)
                        when "nand"
                            acc_trig_value = not(acc_trig_value and e)
                        when "or"
                            acc_trig_value = acc_trig_value or e
                        when "nor"
                            acc_trig_value = not(acc_trig_value or e)
                        when "not"
                            acc_trig_value = not(e)
                        when "xor"
                            acc_trig_value = ((acc_trig_value and not(e)) or (not(acc_trig_value) and e))
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

            return acc_trig_value
        end

        def bool i 
            if i == "0"
                return false
            else
                return true
            end
        end

        def remove_last_stim
            # removed = []
            @inputs.each do |pname, pdatatype|
                @stim[pname].pop
            end
            # pp removed
        end

        def get_rand_val type = "bit"
            case type
            when "bit"
                return ["0", "1"].sample
            when "std_logic" 
                return ["0", "1"].sample
            else
                raise "Error : During stimuli generation. Only 'bit' data type supported yet."
            end
        end

        def save_csv_stim_as path
            src = Code.new 
            headers = ""
            @stim.keys.each{ |pname|
                headers.concat(pname)
                headers.concat(',')
            }
            headers.delete_suffix!(',')
            src << headers
            @stim.values[0].length.times{ |cycle|
                line = ""
                @stim.keys.each{ |pname|
                    line.concat(@stim[pname][cycle])
                    line.concat(',')
                }
                line.delete_suffix!(',')
                src << line
            }

            src.save_as path
        end
    
        def save_as_txt path
            if path[-4..-1]!=".txt"
                path.concat ".txt"
            end

            src = Code.new
            src << "# Stimuli sequence"

            @stim.values[0].length.times do |cycle|
                line = ""
                @stim.keys.each do |pname|
                    line << @stim[pname][cycle]
                end
                src << line
            end

            src.save_as path
        end 
    

    # TODO : Add chessboard pattern, full one, full zero, moving one, moving zero, ... simple patterns ?
    end
end