require_relative "../lib/netenos.rb"
require_relative "../lib/converter/computeStim5.rb"

include Netlist
# include VHDL

Dir.chdir("tests") do
    Dir.chdir("tmp") do
        res = nil 
        compStim = nil
        rand_circ = nil
        insert_points = nil
        targeted_transition = nil
        # * Load Netlist
        # rand_circ = Marshal.load(IO.read("test.enl"))


        loop do
            # * Generate Netlist
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
            target_paths_outputs = compStim.get_cone_outputs(insert_points[0]) # ! Nécessite un 'partof' ici

            Converter::DotGen.new.dot rand_circ, "./test.dot"

            # print "insert_points[0] ="
            # pp insert_points[0]
            # print "target_paths_outputs[0] ="
            # pp target_paths_outputs[0]

            targeted_transition = Converter::Event.new(target_paths_outputs[0],rand_circ.crit_path_length ,"R", nil)
            res = compStim.start targeted_transition, insert_points[0]
            
            break if !(res == :impossible) 
        end

        pp insert_points[0]
        pp targeted_transition
        pp res
        
        compStim.colorFixedGates
        Converter::DotGen.new.dot rand_circ, "./processed.dot"

        rand_circ.save_as "."

        compStim.get_inputs_events.each do |e|
            puts "#{e.signal.name}, #{e.timestamp}, #{e.value}"
        end

        puts "End"
    end
end