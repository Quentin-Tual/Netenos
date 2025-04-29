
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "./test_compTestbench.rb"
require 'ruby-prof'
require 'benchmark'

include Netlist

class Test_blif_and_HTinsertion < Test_compTestbench
    
    def initialize
        # @uut = Converter::ConvBlif2Netlist.new
        pp "Start"
    end
    
    def gen_case 
        load_blif("/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/f51m.blif")
        # @circ_init = @uut.convert "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/clip.blif"
        # puts "Original circuit has combinational loop: #{circ.has_combinational_loop?}"
        # pp @circ_init.getNetlistInformations :one
        pp @circ_init.getNetlistInformations $DELAY_MODEL
        @timings_h = @circ_init.get_timings_hash $DELAY_MODEL
        @slack_h = @circ_init.get_slack_hash
        @circ_init.get_netlist_precedence_grid
        @one_vector_proba = BigDecimal("1.0") / 2**@circ_init.get_nb_inputs 
        @transi_proba_h = @circ_init.get_transition_probability_h
        @transi_proba_h.keys.each do |k| 
            @transi_proba_h[k.name] = @transi_proba_h[k]
            @transi_proba_h.delete(k)
        end
        @circ_init.cache_inputs_in_name2obj
        # generator = nil
        
        # @viewer = Converter::DotGen.new
        # @viewer.dot @circ_init, "./rand_circ.dot"
        
        gen_circ_files(@circ_init)
        # pp circ.get_insertion_points(4)
    end

    def nominal_sim
        # todo : generate testbenchs for nominal simulation for comparison
        unless @tb_generated 
            testbench_gen
            @tb_generated = true
        end
        #todo : generate stim
        unless @stim_generated
            stim_gen
            # stim_solve(@modifier.get_payload_delay)
            @stim_generated = true
        end
        # todo : generate compile script
        unless @script_generated 
            script_gen
            @script_generated = true
        end
        # todo : run simulation
        `./compile.sh`
        # todo : return trig_vec_nom 
        return File.read("detections_#{$FREQ}.txt").split.uniq.map!(&:to_i).length
        # return `wc -l detections_#{$FREQ}.txt`.split[0].to_i
                
    end

    def nominal_eval2 initExpr, detectability_max

        procs_list = nil
         
        # Benchmark.bm do |x|
        #     x.report("Expr + Proc gen :"){
                # ! Optimization possible, cache expr on gates having multiple sinks on circ_init ? How to not use cache on the trojan paths ?
                altExpr = @circ_alt.get_all_ruby_expr
                # trig_vectors = Set.new

                exp_to_test = initExpr.values.zip(altExpr.values).select{|exp_pair| exp_pair[0] != exp_pair[1]}

                procs_list = exp_to_test.collect do |initE, altE|
                    operand_list = altE.scan(/i[0-9]+/).uniq.join(",")
                    [@circ_init.get_eval_proc(initE, operand_list), @circ_alt.get_eval_proc(altE)]
                end
        #     }
        # end

        diff = []

        procs_list.each do |initP, altP|
            tmp_diff = []
            nb_args = altP.arity
            puts "nb_test_vec = 2**#{nb_args} = #{2**nb_args}"
            if nb_args > 24 # ! Ignoring it is not enough, maybe we should refuse it by default (else we'll have a higher detectability than expected)
                return 0
            else
                exhaustive_test_seq = [true,false].repeated_permutation(nb_args)
                exhaustive_test_seq.each do |v|
                    if initP.call(*v) ^ altP.call(*v)
                        # trig_vectors << v
                        # h = {}
                        # altP.parameters.each_with_index{|(_, inp), i| h[inp] = v[i]}
                        tmp_diff << v
                    end
                    break if tmp_diff.length > detectability_max
                end

                # diff[altP] = tmp_diff

                # diff.each do |altP, v_list|
                    tmp_diff.each do |v|
                        h = {}
                        altP.parameters.each_with_index do |(_,inp), i|
                            h[inp] = v[i] 
                        end
                        diff << h
                    end
                # end

                diff.combination(2).each do |hx, hy| 
                    if hx.keys.select{|k| hy[k]}.all?{|k| hx[k] == hy[k]}
                        diff.delete(hy) 
                    end
                    break if diff.length == 1
                end
            end

            break if diff.length > detectability_max
        end
        
        return diff.length
    end

    def nominal_eval initExpr, detectability_max

        procs_list = nil
         
        # Benchmark.bm do |x|
        #     x.report("Expr + Proc gen :"){
                # ! Optimization possible, cache expr on gates having multiple sinks on circ_init ? How to not use cache on the trojan paths ?
                altExpr = @circ_alt.get_all_ruby_expr
                # trig_vectors = Set.new

                exp_to_test = initExpr.values.zip(altExpr.values).select{|exp_pair| exp_pair[0] != exp_pair[1]}

                procs_list = exp_to_test.collect do |initE, altE|
                    operand_list = altE.scan(/i[0-9]+/).uniq.join(",")
                    [@circ_init.get_eval_proc(initE, operand_list), @circ_alt.get_eval_proc(altE)]
                end
        #     }
        # end

        diff = []

        procs_list.each do |initP, altP|
            nb_args = altP.arity
            # puts "nb_test_vec = 2**#{nb_args} = #{2**nb_args}"
            unless nb_args > 24 # ! Ignoring it is not enough, maybe we should refuse it by default (else we'll have a higher detectability than expected)
                exhaustive_test_seq = [true,false].repeated_permutation(nb_args)
                exhaustive_test_seq.each do |v|
                    if initP.call(*v) ^ altP.call(*v)
                        # trig_vectors << v
                        h = {}
                        altP.parameters.each_with_index{|(_, inp), i| h[inp] = v[i]}
                        diff << h
                    end
                    break if diff.length >= detectability_max
                end

                diff.combination(2).each do |hx, hy| 
                    if hx.keys.select{|k| hy[k]}.all?{|k| hx[k] == hy[k]}
                        diff.delete(hy) 
                    end
                    break if diff.length == 1
                end
            end

            break if diff.length >= detectability_max
        end
        
        return diff.length
    end

    def compare_transi_proba
        initProba = @transi_proba_h
        altProba = @circ_alt.get_transition_probability_h(true)

        

        altProba.keys.each do |k| 
            altProba[k.name] = altProba[k]
            altProba.delete(k)
        end

        proba_diff = @circ_init.get_outputs.collect do |o|
            g = o.get_source_gates
            # pp initProba[g.name] 
            # pp altProba[g.name]
            proba_diff = (initProba[g.name] - altProba[g.name]).abs
        end

        puts "proba_diff : #{proba_diff}"

        proba_diff.all?{|proba| proba < $DETECTABILITY} and proba_diff.any?{|proba| proba >= @one_vector_proba}
    end
    
    def run 
        gen_case 
        forbidden_locs = Set.new
        trigger_pool = []
        trig = nil
        circ_init_name = @circ_init.name.clone
        mod_name = circ_init_name + "_altered"

        @tb_generated = false
        @stim_generated = false
        @script_generated = false

        initExpr = @circ_init.get_all_ruby_expr 
        
        # result = RubyProf.profile do
            loop do   
                # @circ_init = Marshal.load(File.read("#{circ_init_name}.enl"))
                tmp_circ = Marshal.load(File.read("#{circ_init_name}.enl"))
                tmp_circ.name = mod_name
                precedence_grid = tmp_circ.get_netlist_precedence_grid
                timing_h = tmp_circ.get_timings_hash($DELAY_MODEL)
                @modifier = Inserter::Tamperer.new(tmp_circ, precedence_grid, timing_h, delay_model: $DELAY_MODEL, trigger_pool: trigger_pool)
                @modifier.select_ht("og_s38417",4)
                @modifier.forbidden_locs = @modifier.trigger_pool_2_obj(forbidden_locs)
                @circ_alt = @modifier.insert2 
                raise "Error: Combinational loop detected on circ_alt." if @circ_alt.has_combinational_loop?
                forbidden_locs = @modifier.forbidden_locs
                trigger_pool = @modifier.trigger_pool_2_name
                @circ_alt.name = mod_name
                # todo : generate vhdl for both circuits
                gen_circ_files(@circ_alt)
                
                # puts "compare_transi_proba : #{compare_transi_proba}"

                detectability_max = (0.01*(2**@circ_init.get_nb_inputs).ceil)

                trig_vec_nom = 0

                # Benchmark.bm do |x|
                    # x.report("Eval:"){
                        trig_vec_nom = nominal_eval2(initExpr, detectability_max) 
                    # }
                    puts "trig_vec_nom (eval): #{trig_vec_nom}"
                    
                    # x.report("Sim:"){
                        trig_vec_nom = nominal_sim
                    #     break if trig_vec_nom > 0 and trig_vec_nom < detectability_max
                    # }
                    puts "trig_vec_nom (simu): #{trig_vec_nom}"
                # end

                # ! Stocker les vecteurs déclencheurs dans "detections_1.txt" pour compatibilité avec les expériences
                # break if trig_vec_nom > 0 and trig_vec_nom < detectability_max

                break if compare_transi_proba
            end
        # end
        # printer = RubyProf::FlatPrinter.new(result)
        # printer.print(STDOUT)

        puts @modifier.get_ht_stage

        pp @circ_alt.getNetlistInformations $DELAY_MODEL
        pp @modifier.ht_is_inserted?
        @circ_alt.get_dot_graph
        @circ_init.get_dot_graph
    end
end

if __FILE__ == $0
    # $CIRC_CARAC = [6, 3, 10, [:even, 0.70]]
    $DELAY_MODEL = :one
    $COMPILER = :ghdl3
    $OPT = [:ghdl, :all_sig]
    $FREQ = 1
    $DETECTABILITY = 0.01

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        'rm *'
        env = Test_blif_and_HTinsertion.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end