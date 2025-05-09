require_relative "../lib/netenos.rb"
require_relative "../lib/converter/computeStim14.rb"
require 'ruby-prof'
require 'logger'

include Netlist
# include VHDL

class Test_computeStim
    attr_accessor :compStim, :circ
    
    def initialize
        @compStim = nil
        @circ = nil
        @insert_points = nil
        @targeted_transition = nil

        @generator = Netlist::RandomGenComb.new(*$CIRC_CARAC)
    end

    def load_blif path
        @circ = Converter::ConvBlif2Netlist.new.convert(path)
        @circ.getNetlistInformations($DELAY_MODEL)
        Converter::DotGen.new.dot @circ, "./#{@circ.name}.dot"
        # @compStim = Converter::ComputeStim.new(@circ, :int_multi)
        # @insert_points = @compStim.get_insertion_points 1.5

        # @circ.components.each{|comp| comp.tag = nil} # Reset tags to avoid trouble in 'get_cone_outputs'
        # target_paths_outputs = @compStim.get_cone_outputs(@insert_points[4]) # ! Nécessite un 'partof' ici

        # Converter::DotGen.new.dot @circ, "./test.dot"

        # @targeted_transition = Converter::Event.new(target_paths_outputs[0], @circ.crit_path_length ,"R", nil)
        # res = @compStim.compute @targeted_transition, @insert_points[0]
        
        # if res == :impossible
        #     puts "Impossible resolution for the circuit loaded."
        #     exit
        # end

        # @compStim.colorFixedGates
        # Converter::DotGen.new.dot @circ, "./processed.dot"
    end

    def load_circuit
        @circ = Marshal.load(IO.read("test.enl"))

        @compStim = Converter::ComputeStim.new(@circ, $DELAY_MODEL)
        @insert_points = @compStim.get_insertion_points 2.5

        @circ.components.each{|comp| comp.tag = nil} # Reset tags to avoid trouble in 'get_cone_outputs'
        target_paths_outputs = @compStim.get_cone_outputs(@insert_points[0]) # ! Nécessite un 'partof' ici

        Converter::DotGen.new.dot @circ, "./test.dot"

        @targeted_transition = Converter::Event.new(target_paths_outputs[0], @circ.crit_path_length ,"R", nil)
        res = @compStim.compute @targeted_transition, @insert_points[0]
        
        if res == :impossible
            puts "Impossible resolution for the circuit loaded."
            exit
        end

        @compStim.colorFixedGates
        Converter::DotGen.new.dot @circ, "./processed.dot"
    end
    
    def generate_stim_on_random_circuit
        @circ_carac = @circ.getNetlistInformations $DELAY_MODEL
        Converter::DotGen.new.dot @circ, "./test.dot"
        @compStim = Converter::ComputeStim.new(@circ, $DELAY_MODEL)#,["10100"])

        events_computed = nil
        # loop do 
            events_computed = @compStim.generate_stim(@circ, "og_s38417", compute_all_transitions: true, all_outputs: true, all_insert_points: true)
            # break if !events_computed.empty?
        # end
        Converter::DotGen.new.dot @circ, "./processed.dot"
        # pp "here"
        return events_computed
        # if @compStim.generate_stim 
        #     pp "Fail"
        # else
        #     pp "Success"
        # end
    end

    def get_resolvable_case
        attempt = 1
        loop do 
            print "Attempt #{attempt} : "
            @circ = @generator.getRandomNetlist "test"
            @circ.getNetlistInformations $DELAY_MODEL

            @compStim = Converter::ComputeStim.new(@circ, $DELAY_MODEL)
            @insert_points = @compStim.get_insertion_points 2.5

            if @insert_points.empty?
                puts "No insertion point found"
                next
            else
                target_paths_outputs = @compStim.get_cone_outputs(@insert_points[0]) # ! Nécessite un 'partof' ici

                Converter::DotGen.new.dot @circ, "./test.dot"

                @targeted_transition = Converter::Event.new(target_paths_outputs[0], @circ.crit_path_length ,"R", nil)
                res = @compStim.compute @targeted_transition, @insert_points[0]
                
                if res == :impossible
                    attempt += 1
                    print "impossible resolution"
                    puts
                end

            end

            break if !(res == :impossible) 
        end

        @compStim.colorFixedGates
        Converter::DotGen.new.dot @circ, "./processed.dot"

        @circ.save_as "."
    end

    def verif_compute inputs_events=nil, output_event=nil
        # puts
        # puts "Insertion point : #{insert_points[0].name}"
        # puts "Targeted : #{@targeted_transition.signal.name}, #{@targeted_transition.timestamp}, #{@targeted_transition.value}"
        # pp res

        if inputs_events.nil?
            inputs_events = @compStim.get_inputs_events
        end
        # puts "Inputs events :"
        # inputs_events.each do |e|
        #     puts "#{e.signal.name}, #{e.timestamp}, #{e.value}"
        # end
        simulate(inputs_events)

        # * : Load VCD wavetrace file (only necessary signals)
        signals_to_extract = inputs_events.collect{|e| "#{e.signal.name}_o0".downcase}
        vcd_loader = VCD::Vcd_Signal_Extractor.new
        trace = vcd_loader.extract2 "#{@circ.name}_#{$FREQ}_tb.vcd", $COMPILER, signals_to_extract

        # * : Only events on extracted signals
        if output_event.nil?
            events_to_verify = @compStim.transitions.flatten.difference(@compStim.get_inputs_events).collect{|e| e}
        else 
            events_to_verify = [output_event]
        end

        if simulation_matches_computations?(trace, events_to_verify)
            # puts "Computed behavior is correct."    
            return true
        else
            # puts "Computed behavior is not valid."
            return false
        end
    end

    def simulate inputs_events
        # * Generate gtech
        vhdl_generator = Converter::ConvNetlist2Vhdl.new(@circ)
        vhdl_generator.gen_gtech
        
        # * Generate circuit vhdl description file
        vhdl_generator.generate(@circ, $DELAY_MODEL)

        # * Generate compile.sh and makefile
        vhdl_compiler = Converter::VhdlCompiler.new
        vhdl_compiler.gtech_makefile(".", $COMPILER)
        vhdl_compiler.circ_compile_script(".", @circ.name, [$FREQ], [$COMPILER, :uut_sig], gtech_path: ".")

        # * Generate testbench file 
        tb_generator = Converter::GenTestbench.new(@circ)
        tb_generator.gen_testbench(:asynch, $FREQ, @circ.name, asynch_stim: inputs_events)

        # * Run simulation
        `make`
        `./compile.sh` 
    end

    def simulate_exh 
        # * Generate gtech
        vhdl_generator = Converter::ConvNetlist2Vhdl.new(@circ)
        vhdl_generator.gen_gtech
        
        # * Generate circuit vhdl description file
        vhdl_generator.generate(@circ, $DELAY_MODEL)

        # * Generate compile.sh and makefile
        vhdl_compiler = Converter::VhdlCompiler.new
        vhdl_compiler.gtech_makefile(".", $COMPILER)
        vhdl_compiler.circ_compile_script(".", @circ.name, [$FREQ], [$COMPILER, :uut_sig], gtech_path: ".")

        # * Generate stimuli file
        stim_generator = Converter::GenStim.new(@circ)
        stim_generator.gen_exhaustive_trans_stim
        stim_generator.save_as_txt("stim.txt")

        # * Generate testbench file 
        tb_generator = Converter::GenTestbench.new(@circ)
        tb_generator.gen_testbench("stim.txt", $FREQ, @circ.name)

        # * Run simulation
        `make`
        `./compile.sh` 
    end
    
    def simulation_matches_computations? trace, events_to_verify
        # * For each event
        events_to_verify.each do |e|
            trace["output_traces"].each_with_index do |instant, i|
                # * Find the associated instant in the trace
                if instant[0] == e.timestamp*1000
                    # * Event is not found at this instant
                    if !instant.include? "#{e.signal.name.downcase}_o0#{e.boolean_value}"
                        # * Check if the expected transition is set earlier (a "stable transition" is not explicitly written in VCD), checking each preceding instant from the closest 
                        (0..i).reverse_each do |index|
                            preceding_instant = trace["output_traces"][index]
                            # * If an event is registered on the same signal at an earlier instant
                            if preceding_instant.any?{|t| t[0...-1] == "#{e.signal.name.downcase}_o0"} 
                                # * If the first preceding event on this signal is not the expected value, computation is incorrect 
                                if !preceding_instant.include? "#{e.signal.name.downcase}_o0#{e.boolean_value}"
                                    return false
                                else
                                    break
                                end
                            end
                        end
                    else
                        break
                    end
                else
                    next
                end
            end
        end

        return true
    end

    def one_insert_point
        load_blif("/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/sqr6.blif")
        @compStim = Converter::ComputeStim.new(@circ, $DELAY_MODEL)

        insert_point = @circ.get_port_named("o10")#.get_inputs[1]
        # insert_point = @circ.get_component_named("And2960").get_inputs[1]
        control_path = @circ.get_output_path(insert_point)[0]
        @compStim.tag_control_path(control_path, :target_path)
        # targeted_output = @compStim.get_cone_outputs(insert_point)[0]
        Converter::DotGen.new.dot @circ, "./#{@circ.name}.dot", $DELAY_MODEL
        expected_event =  Converter::Event.new(control_path[-1], @circ.crit_path_length,:R,nil)
        computed_events = @compStim.compute(expected_event, insert_point)
        if computed_events == :impossible
            puts "Impossible to compute insertion point, no verification possible"
        else
            verif_all_computed_events({insert_point => {expected_event => @compStim.get_inputs_events}})
        end
    end

    def verif_all_computed_events events
        invalid_count = 0
        events.each do |insert_point, ins_points_events|
            ins_points_events.each do |output_transition, e_list|
                # output_events.each do |transition, e_list|
                    if !verif_compute(e_list, output_transition)
                        puts "Invalid computation for : insertion_point -> #{insert_point.get_full_name}, output -> #{output_transition.signal.name}, transition -> #{output_transition.value}"
                        invalid_count += 1
                    else
                        puts "Valid computation for : insertion_point -> #{insert_point.get_full_name}, output -> #{output_transition.signal.name}, transition -> #{output_transition.value}"
                    end
                # end
            end
        end
        if invalid_count > 0
            puts " /!\ Encountered #{invalid_count} invalid computations !"
        else
            puts "All computations are valid !"
        end
    end

    # def verif_all_unobservalbles
    #     # TODO : Générer les fichiers nécessaires à la simulation d'un test exhaustif
    #     # TODO : pour chaque signal non observable
    #     @compStim.unobservables.each do |s|
    #         # TODO : Pour chaque chemin entre 's' et une sortie 'o'

    #             # TODO : ajouter des "probes" sur les signaux concernés permettant au testbench d'y accéder
    #             # TODO : Traduire en une expression vhdl permettant de tester que 's' est observable sur la sortie
    #             # TODO : ajouter l'expression dans un process du testbench, la simulation doit s'arrêter si les conditions sont remplies

    #     end 
    # end

    def run
        # @circ = @generator.getValidRandomNetlist "test"
        # load_blif "../C17.blif"
        # load_blif "../xor5.blif"
        # load_blif "../p82.blif"
        # load_blif "../f51m.blif"
        load_blif "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/sqr6.blif"
        # RubyProf.start
        # get_resolvable_case
        # load_circuit
            # generate_stim_on_random_circuit
        one_insert_point
        # result = RubyProf.stop
        # printer = RubyProf::FlatPrinter.new(result)
        # printer.print(STDOUT)
        # File.write("profile_#{@circ.name}", Marshal.dump(result))
        # if @compStim.events_computed.empty?
        #     raise "No events computed !"
        # end
        # verif_all_computed_events(@compStim.events_computed)
        # @compStim.save_as_txt("computed_stim.txt",@compStim.stim_vec,)
        puts "Unobservables : #{@compStim.unobservables.length}/#{@compStim.insert_points.length}"
        # pp @circ_carac
        # pp @compStim.test
        # simulate_exh
    end
end

if __FILE__ == $0
    # $CIRC_CARAC = [6,4,10, [:custom, 0.5]] # 30 gates
    # $CIRC_CARAC = [8, 4, 10, [:custom, 0.6]] # 40 gates
    # $CIRC_CARAC = [8, 4, 11, [:custom, 0.63]] # 45 gates
    # $CIRC_CARAC = [7, 7, 8, [:custom, 0.78]] # 45 gates short crit_path
    # $CIRC_CARAC = [6, 3, 15, [:custom, 0.5]] # 45 gates long crit_path
    $CIRC_CARAC = [8, 4, 11, [:custom, 0.74]] # 50 gates
    # $CIRC_CARAC = [8, 5, 11, [:custom, 0.65]] # 55 gates
    # $CIRC_CARAC = [8, 4, 15, [:custom, 0.6]] # 60 gates
    # $CIRC_CARAC = [8, 5, 12, [:custom, 0.7]] # 60 gates
    # $CIRC_CARAC = [10, 5, 10, [:custom, 0.75]] # 60 gates short crit_path
    # $CIRC_CARAC = [11, 7, 8, [:custom, 0.8]] # 60 gates very short crit_path
    # $CIRC_CARAC = [8, 8, 15, [:custom, 0.7]] # 93 gates
    $DELAY_MODEL = :one
    $COMPILER = :ghdl3
    $FREQ = 1

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        `rm *`
        `touch test.log`
        # print(self.class)
        env = Test_computeStim.new 
        # env.one_insert_point
        env.run
        puts "Fin #{__FILE__}"
    end
end