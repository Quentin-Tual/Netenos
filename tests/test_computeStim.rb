require_relative "../lib/netenos.rb"
require_relative "../lib/converter/computeStim4.rb"

include Netlist
# include VHDL

Dir.chdir("tests") do
    Dir.chdir("tmp") do
        generator = Netlist::RandomGenComb.new(6, 2, 10, [:custom, 0.5])
        # generator = Netlist::RandomGenComb.new 200, 10, 10
        rand_circ = generator.getRandomNetlist "test"
        # puts "Gates amount : #{rand_circ.components.length}"
        rand_circ.getNetlistInformations :int_multi
        # pp rand_circ.get_slack_hash(:int_multi)

        compStim = Converter::ComputeStim.new(rand_circ, :int_multi)
        insert_points = compStim.get_insertion_points 2.5

        if insert_points.empty?
            puts "No insertion point found"
            exit
        end

        # if insert_points[0].is_a? Netlist::Port and insert_points[0].is_global?
        #     pp "HERE"
        # end
        target_paths_outputs = compStim.get_cone_outputs(insert_points[0])

        Converter::DotGen.new.dot generator.netlist, "./test.dot"

        # print "insert_points[0] ="
        pp insert_points[0]
        # print "target_paths_outputs[0] ="
        # pp target_paths_outputs[0]

        targeted_transition = Converter::Event.new(target_paths_outputs[0],rand_circ.crit_path_length ,"R")
        res = compStim.start targeted_transition, insert_points[0]

        pp res
        # compStim.transitions << [targeted_transition]
        # compStim.decisions << [targeted_transition]

        # begin
        #     res = compStim.set_target_path2(targeted_transition, insert_points[0])
        # rescue => exception
        #     pp res
        #     @transitions.each do |t|
        #         pp t
        #     end
        # end
        
        # pp res
        # if res == :dead_end or res == :retry
        #     pp "Dead_end, trying with another targeted transition"
        #     targeted_transition = Converter::Event.new(target_paths_outputs[0], rand_circ.crit_path_length, "F")
        #     compStim = Converter::ComputeStim.new(rand_circ, :int_multi)
        #     insert_points = compStim.get_insertion_points 2.5
        #     target_paths_outputs = compStim.get_cone_outputs(insert_points[0])
        #     res = compStim.set_target_path2(targeted_transition, insert_points[0])
        #     # exit
        # end

        # pp res
        # if res == :dead_end or res == :retry
        #     raise "Dead_end, try with another insertion point, another targeted transition or another output."
        # else
        #     compStim.transitions.each do |t|
        #         pp t
        #     end
        # end

        # compStim.side_inputs.each do |si|
        #     res = compStim.backpropagate(si)
        #     if res == :dead_end or :retry
        #         break
        #     end
        # end
        

        # pp res
        # if res == :dead_end or res == :retry
        #     raise "Dead_end, try with another insertion point, another targeted transition or another output."
        # end

        # compStim.transitions.each do |t|
        #     pp t
        # end
        
        compStim.colorFixedGates
        Converter::DotGen.new.dot rand_circ, "./processed.dot"

        rand_circ.save_as "."


    end
end