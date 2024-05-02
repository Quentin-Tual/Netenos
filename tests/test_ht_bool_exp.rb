
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "test_lib.rb"

include Netlist

DELAY_MODEL = :int_multi
FREQ = 1
COMPILER = :nvc

def depth (a)
    return 0 unless a.is_a?(Array)
    return 1 + depth(a[0])
end

def exp_to_h exp, id=0
    h = {}
    if !exp.is_a? Array # primary input
        return {exp => nil}
    elsif exp.length == 2 and exp[0] == "not" # NOT
        if id != 0
            h["#{exp[0]}_#{id}"] = exp_to_h(exp[1])
        else
            h[exp[0]] = exp_to_h(exp[1])
        end
    else # Binary Exp
        if id != 0
            node_name = "#{exp[1]}_#{id}"   
        else
            node_name = exp[1]  
        end

        # if exp[0][0] == "i" and exp[2][0] == "i" and exp[0] == exp[2] 
        #     case exp[1]
        #     when "xor" 
        #         h["false"] = nil
        #     when "and", "or"
        #         h[exp[0]] = nil
        #     when "nand","nor"
        #         h["not"] = {exp[0] => nil}
        #     else
        #         raise "Error : Unexpected operator encountered"
        #     end
        # else
            if exp[0][0] == "not" 
                op_i_0 = 0
            else
                op_i_0 = 1
            end
    
            if exp[2][0] == "not"
                op_i_2 = 0
            else
                op_i_2 = 1
            end

            if exp[0][op_i_0] == exp[2][op_i_2] # Binary exp
                h[node_name] = exp_to_h(exp[0], 1).merge(exp_to_h(exp[2], 2))
            else
                h[node_name] = exp_to_h(exp[0]).merge(exp_to_h(exp[2]))
            end
        # end

    end
    return h
end 
  
def simplify exp_h
# ! Parfois certaines portes nor/nand/xor ne sont pas remplacées, voir comment éviter ces "oublis"
    exp_h.keys.each do |op|
        # op = op.split("_")
        if exp_h[op].nil? or exp_h[op] == false #  ignore branch endings
            next
        else
            # TODO:  Replace key if needed
            case op.split("_")[0]
            when "and"
                # Do nothing
                if exp_h[op].keys.length == 1 # only one sig
                    exp_h[exp_h[op].keys[0]] = exp_h[op][exp_h[op].keys[0]]
                    exp_h.delete(op)
                    op = nil
                end
                nil
            when "or"
                if exp_h[op].keys.length == 1 # only one sig
                    exp_h[exp_h[op].keys[0]] = exp_h[op][exp_h[op].keys[0]]
                    exp_h.delete(op)
                    op = nil
                end
                # Do nothing
                nil
            when "not"
                # new_op = "!#{exp_h[op].keys[0]}"
                # exp_h[new_op] = exp_h.delete(op).values[0]
                # ! Do nothing (pour le moment)
                input_name = exp_h[op].keys[0]
                
                # TODO : Vérifier si la node suivante est un NOT aussi -> supprimer les deux nodes
                if input_name[0] == "i"
                #     exp_h["!#{exp_h[op].keys[0]}"] = nil
                #     exp_h.delete(op)
                    next
                elsif input_name.split("_")[0] == "not"
                    sub_h = exp_h[op][input_name]
                    sub_h_key = sub_h.keys[0]
                    exp_h.delete(op)
                    exp_h[sub_h_key] = sub_h[sub_h_key]
                    if !sub_h[sub_h_key].nil?
                        simplify exp_h[sub_h_key]
                    end
                elsif input_name.split("_")[0] == "nor"
                    sub_h = exp_h[op][input_name]
                    exp_h.delete(op)
                    if exp_h.include? "or"
                        exp_h["or_1"] = exp_h.delete("or")
                        simplify exp_h["or_1"]
                        exp_h["or_2"] = sub_h
                        simplify exp_h["or_2"]
                        op = nil
                    else
                        exp_h["or"] = sub_h
                        op = "or"
                    end
                elsif input_name.split("_")[0] == "nand"
                    sub_h = exp_h[op][input_name]
                    exp_h.delete(op)
                    if exp_h.include? "and"
                        exp_h["and_1"] = exp_h.delete("and")
                        simplify exp_h["and_1"]
                        exp_h["and_2"] = sub_h
                        simplify exp_h["and_2"]
                        op = nil
                    else
                        exp_h["and"] = sub_h
                        op = "and"
                    end
                end
                # TODO : Vérifier si la node suivante est un NAND ou un NOR -> annuler la double négation pour un AND ou un OR
                # op = new_op
            when "nand" # Replace by a "or" followed by "not"
                if exp_h[op].keys.length == 1 # only one sig
                    exp_h["not"] = {exp_h[op].keys[0] => exp_h[op][exp_h[op].keys[0]]}
                    exp_h.delete(op)
                    op = nil
                end

                if exp_h["or"].nil?
                    tmp = exp_h.delete(op).collect{|n,v| {"not_#{n}" => {n => v}} }
                    exp_h["or"] = tmp[0].merge(tmp[1])
                    op = "or"
                else
                    exp_h["or_1"] = exp_h.delete("or")
                    tmp = exp_h.delete(op).collect{|n,v| {"not_#{n}" => {n => v}} }
                    simplify exp_h["or_1"]
                    exp_h["or_2"] = tmp[0].merge(tmp[1])
                    op = "or_2"
                end
            when "nor" # Replace by a "and" followed by "not"
                if exp_h[op].keys.length == 1 # only one sig
                    exp_h["not"] = {exp_h[op].keys[0] => exp_h[op][exp_h[op].keys[0]]}
                    exp_h.delete(op)
                    op = nil
                end

                if exp_h["and"].nil?
                    tmp = exp_h.delete(op).collect{|n,v| {"not_#{n}" => {n => v}} }
                    exp_h["and"] = tmp[0].merge(tmp[1])
                    op = "and"
                else
                    exp_h["and_1"] = exp_h.delete("and")
                    tmp = exp_h.delete(op).collect{|n,v| {"not_#{n}" => {n => v}} }
                    simplify exp_h["and_1"]
                    exp_h["and_2"] = tmp[0].merge(tmp[1])
                    op = "and_2"
                end
            when "xor" # ! Not necessary cause xor operator exists in ruby
                if exp_h[op].keys.length == 1 # only one sig
                    exp_h["false"] = nil
                    exp_h.delete(op)
                    op = nil
                end
                nil
                #     # TODO : Replace by "or","and" and "not" needed
            #     cond1 = exp_h[op].clone
            #     # if cond1.keys[0] == "not"    
            #     #     cond1[cond1["not"].keys[0]] = cond1["not"].values[0]
            #     # end
            #     cond1["not"] = {cond1.keys[0] => cond1.delete(cond1.keys[0])}


            #     cond2 = exp_h[op].clone
            #     # if cond2.keys[1] == "not"    
            #     #     cond2[cond2["not"].keys[0]] = cond2["not"].values[0]
            #     # end
            #     cond2["not"] = {cond2.keys[1] => cond2.delete(cond2.keys[1])}

            #     cond_xor = {"and_1" => cond1, "and_2" => cond2}

            #     if exp_h["or"].nil?
            #         exp_h["or"] = cond_xor 
            #         exp_h.delete(op)
            #         op = "or"
            #     else
            #         exp_h["or_1"] = exp_h.delete("or")
            #         exp_h["or_2"] = cond_xor 
            #         exp_h.delete(op)
            #         op = "or_2"
            #     end
                
            else
                raise "Error: Unknown operator uncountered in global triggering expression."
            end

            if !exp_h[op].nil?
                simplify exp_h[op] # simplify lower graph branches
            end
        end
    end

    return exp_h
end

def get_str_exp exp_h, previous_op = nil 
    str = ""

    # if exp_h.values == [nil]
    #     return exp_h.keys[0]
    # end
    op = exp_h.keys[0]
    # if exp_h.keys.length == 1
    if op[0] == "i"
        str << "v[#{op.split("i")[1]}]"
    elsif op == false
        str << op
    elsif op.split("_")[0] == "not"
        str << "(! "
        str << get_str_exp(exp_h[op])
        str << ")"
    else # donc== 2 
        str << "("
        str << get_str_exp({exp_h[op].keys[0]=> exp_h[op].values[0]})
        str << " "
        case op.split("_")[0]
        when "and"
            str << "&"
        when "or"
            str << "|"
        when "xor"
            str << "^"
        else
            raise "Error : Expression tree not simplified (contained #{op})"
        end
        str << " "
        str << get_str_exp({exp_h[op].keys[1]=> exp_h[op].values[1]})
        str << ")"
    end

    return str
end

def get_proc_from_exp(exp)
    return eval  "lambda {|v| " + exp + " }"
end

if __FILE__ == $0
    Dir.chdir("tmp") do 
        generator = Netlist::RandomGenComb.new(8, 4, 15, [:custom, 0.7])
        # generator = Netlist::RandomGenComb.new 200, 10, 10
        rand_circ = generator.getRandomNetlist "test"
        timings_h = rand_circ.get_timings_hash
        # puts "Gates amount : #{rand_circ.components.length}"
        pp rand_circ.getNetlistInformations :one
        rand_circ.save_as("./")

        viewer = Converter::DotGen.new
        viewer.dot rand_circ,nil,DELAY_MODEL

        # Insert an HT using Tamperer
        modifier = Inserter::Tamperer.new(rand_circ, generator.grid, timings_h)
        modifier.select_ht("xor_and",2)
        modified = modifier.insert2
        modified.name = "alt"
        modified.getNetlistInformations :one

        viewer.dot(modified, 'test_circ_mod.dot',DELAY_MODEL)

        @exp = modifier.get_trigger_conditions

        print(@exp)
        puts

        @exp_h = exp_to_h(@exp)

        pp @exp_h

        test = simplify @exp_h
        pp test

        str_exp = get_str_exp(@exp_h)
        pp str_exp

        is_a_trig_vec = get_proc_from_exp(str_exp)

        stim_gen = Converter::GenStim.new(rand_circ)
        stim = stim_gen.gen_exhaustive_incr_stim
        stim_gen.save_as_txt "stim.txt"
        test_vec = stim_gen.conv_stim_2_vec_list stim

        bool_test_vec = stim_gen.convert_vec_list_2_bool(test_vec)

        trig_vec = []

        bool_test_vec.each_with_index do |v,i|
            if is_a_trig_vec.call(v.reverse)
                # puts "Vector #{i} triggers"
                trig_vec << i + 1 # Can't detect at cycle 0 cause not finished so no value sampled
            end 
        end

        circ_init = Marshal.load(File.read("test.enl"))

        @vhdl_converter = Converter::ConvNetlist2Vhdl.new
        @vhdl_converter.gen_gtech
        @vhdl_converter.generate circ_init
        @vhdl_converter.generate modified

        @tb_gen = Converter::GenCompTestbench.new(circ_init, modified, DELAY_MODEL)
        @tb_gen.gen_testbench "stim.txt", FREQ

        @script_generator = Converter::VhdlCompiler.new 
        @script_generator.gtech_makefile ".", COMPILER
        `make`
        # * : Only for nominal frequency at first
        @script_generator.comp_tb_compile_script ".", circ_init.name, modified.name, [FREQ], [COMPILER, :minimal_sig],  gtech_path:"./"

        `./compile.sh`

        trace_extractor = VCD::Vcd_Signal_Extractor.new
        t = trace_extractor.extract "#{circ_init.name}_#{FREQ}_tb.vcd", COMPILER

        # TODO : Instancier un comparateur et lancer la comparaison
        comparator = VCD::Vcd_Comparer.new
        cycle_diff = comparator.compare_comparative_tb_traces t["output_traces"], circ_init.get_outputs.collect{|o| "tb_#{o.name}_s"}, circ_init.crit_path_length+1, modified.crit_path_length+1


        `echo "#{trig_vec}" > tmp_calculated.txt` 
        `echo "#{cycle_diff.values.flatten.uniq.collect{|e| e/1000}.uniq}" > tmp_simulated.txt`
    end
end