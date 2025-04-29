#! /usr/env/bin ruby    

require_relative "../lib/netenos.rb"
require_relative "./test_compTbTraceComp.rb"
require 'logger'
# require 'ruby-prof'

include Netlist

class Test_ExhInsertionComputeStim < Test_compTbTraceCompt
    
    def initialize
        @vhdl_converter = Converter::ConvNetlist2Vhdl.new
        @vhdl_converter.gen_gtech
        load_blif
        @viewer = Converter::DotGen.new
        @viewer.dot @circ_init, "#{@circ_init.name}.dot", $DELAY_MODEL
        @circ_init.save_as './'
        `mv #{@circ_init.name}.enl tmp.enl`
        gen_circ_files @circ_init
    end
    
    def load_blif
        blif_converter = Converter::ConvBlif2Netlist.new
        @circ_init = blif_converter.convert($CIRC_PATH)
        pp @circ_init.getNetlistInformations($DELAY_MODEL)
        @circ_init.get_exact_crit_path_length($DELAY_MODEL)
        @circ_init.get_slack_hash
    end

    def do_one_insertion insert_point
        @tamperer = Inserter::Tamperer.new(@circ_init, @circ_init.get_netlist_precedence_grid)
        @circ_alt = nil
        @circ_alt = @tamperer.insert_buffer_at(insert_point, $BUF_DELAY)
        @circ_alt.name = @circ_alt.name + "_mod"
        @circ_alt.getNetlistInformations($DELAY_MODEL)
         # Reset after insertion
    end

    def run 
        insert_points = @circ_init.get_insertion_points($BUF_DELAY).collect{|ip| ip.get_full_name}
        # TODO : Compute stim
        stim_compute

        results = {}
        insert_points.each do |insert_point_name|
            # if insert_point_name == "And2380_i0" #!DEBUG
            #     pp 'here'
            # end
            insert_point = @circ_init.get_component_named(insert_point_name.split('_')[0]).get_inputs[insert_point_name.split('_')[1][1..].to_i]
            # TODO : Insert buffer at the given point
            do_one_insertion(insert_point)
            @circ_init = Marshal.load(IO.read("tmp.enl"))
            # TODO : Generate altered circuit files
            gen_circ_files @circ_alt
            # TODO : Generate simulation files
            # TODO : Generate testbench
            testbench_gen
            # TODO : Generate script
            script_gen
            # TODO : Run simulation
            `./compile.sh`
            # TODO : Analyze results
            cycle_diff = compare_traces
            # TODO : Save in results
            if !cycle_diff.empty?
                r = :detected
            else
                tmp = `grep '#{insert_point_name}' stim.txt`
                if tmp.empty?
                    r = :no_solution
                else
                    r = :invalid_solution
                end
            end
            results[insert_point] = r
        end

        pp results
    end

end

if __FILE__ == $0
    if ARGV[1].nil?
        # $CIRC_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/cm151a.blif"
        # $CIRC_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/cm150a.blif"
        $CIRC_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/xor5.blif"
    else
        $CIRC_PATH = ARGV[1]
    end
    $DELAY_MODEL = :one
    $COMPILER = :ghdl
    $OPT = [$COMPILER, :all_sig]
    $BUF_DELAY = 1
    $FREQ = "Infinity"

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        'rm *'
        # print(self.class)
        env = Test_ExhInsertionComputeStim.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end
