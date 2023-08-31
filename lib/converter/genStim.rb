require_relative '../converter.rb'

module Netlist

    class GenStim
        attr_accessor :inputs

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

        def gen_random_stim nb_cycle, trig_cond = nil

            @inputs.each { |pname, pdatatype|
                @stim[pname] = []
            }

            # ! : Replace by until in order to always have the right stimuli number, even when some are deleted to avoid HT triggering ?
            # until @stim.values.last.length == nb_cycle
            # print"Removed cycle : "
            nb_cycle.times do |j|
                @inputs.each { |pname, pdatatype|
                    @stim[pname] << get_rand_val(pdatatype)
                }
                # For each cycle generated, verify if the stimuli added activates the ht trigger, if it does remove them. 
                if !trig_cond.nil?
                    # raise "Error : Work In Progress"
                    if verify_ht_activation(trig_cond)
                        # puts "Another one : #{j}"
                        # puts "triggered by :"
                        # @stim.keys.each{|pname| print "#{@stim[pname].last}, "}
                        remove_last_stim
                        # print "#{j}, "
                    end
                end
            end
            puts
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

            src.save_as path, true
        end
    end

    # TODO : Add chessboard pattern, full one, full zero, moving one, moving zero, ... simple patterns ?
end