require_relative "../lib/netenos.rb"
# require_relative "../lib/converter/computeStim5.rb"

include Netlist
# include VHDL

class Test_computeStim
    attr_accessor :compStim, :circ
    
    def initialize
        @compStim = nil
        @circ = nil
        @insert_points = nil
        @targeted_transition = nil

        @generator = Netlist::RandomGenComb.new *$CIRC_CARAC
    end

    def load_circuit
        @circ = Marshal.load(IO.read("test.enl"))

        @compStim = Converter::ComputeStim.new(@circ, :int_multi)
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
        @circ = @generator.getValidRandomNetlist "test"
        @circ.getNetlistInformations $DELAY_MODEL

        @compStim = Converter::ComputeStim.new(@circ, :int_multi)

        events_computed = nil
        loop do 
            events_computed = @compStim.generate_stim
            break if !events_computed.empty?
        end
        # pp "here"
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

            @compStim = Converter::ComputeStim.new(@circ, :int_multi)
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

    def verif_compute
        puts
        puts "Insertion point : #{@insert_points[0].name}"
        puts "Targeted : #{@targeted_transition.signal.name}, #{@targeted_transition.timestamp}, #{@targeted_transition.value}"
        # pp res

        puts "Inputs events :"
        @compStim.get_inputs_events.each do |e|
            puts "#{e.signal.name}, #{e.timestamp}, #{e.value}"
        end

        simulate

        # * : Load VCD wavetrace file (only necessary signals)
        signals_to_extract = @compStim.transitions.flatten.difference(@compStim.get_inputs_events).collect{|e| "#{e.signal.name}_o0".downcase}
        vcd_loader = VCD::Vcd_Signal_Extractor.new
        trace = vcd_loader.extract2 "#{@circ.name}_#{$FREQ}_tb.vcd", $COMPILER, signals_to_extract

        # * : Only events on extracted signals
        events_to_verify = @compStim.transitions.flatten.difference(@compStim.get_inputs_events).collect{|e| e}
        
        if simulation_matches_computations? trace, events_to_verify
            puts "Computed behavior is correct."    
        else
            puts "Computed behavior is not valid."
        end
    end

    def simulate
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
        tb_generator.gen_testbench(:asynch, $FREQ, @circ.name, asynch_stim: @compStim.get_inputs_events)

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
    end

    def run
        # get_resolvable_case
        # load_circuit
        # verif_compute
        generate_stim_on_random_circuit
    end
end

if __FILE__ == $0
    $CIRC_CARAC = [8, 4, 10, [:even, 0.6]]
    $DELAY_MODEL = :int_multi
    $COMPILER = :ghdl3
    $FREQ = 1

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        'rm *'
        # print(self.class)
        env = Test_computeStim.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end