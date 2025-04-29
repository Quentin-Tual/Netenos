
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "../lib/converter/genStim2.rb"
require_relative "../lib/converter/computeStim14.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
include Netlist

class Test_compTestbench
    attr_accessor :circ_init, :circ_alt

    def initialize
        
        puts "[+] Initial circuit generation" if $VERBOSE
        # gen_case 

        load_blif $CIRC_PATH

        if @circ_init.has_combinational_loop?
            raise "Error : Combinational loop detected in #{@circ_init}"
        end

        # load_blif "../f51m.blif"
        # load_enl "../test_circ.enl"
        gen_circ_files @circ_init

  

        # stim_compute # ! Test stim computation
                
        puts "[+] Altered circuit generation" if $VERBOSE
        gen_alt_circ
        gen_circ_files @circ_alt

        puts "[+] circ_init reloading" if $VERBOSE
        @circ_init = Marshal.load(IO.read("#{@circ_init.name}.enl"))
    end

    def run
        puts "[+] Stimulus generation" if $VERBOSE
        stim_gen # ! Test stim computation
        puts "[+] Testbench generation" if $VERBOSE
        testbench_gen
        puts "[+] Scripts generation" if $VERBOSE
        script_gen
        puts "[+] Compile and simulate" if $VERBOSE
        `./compile.sh`
    end

    def stim_gen 
        @stim_generator = Converter::GenStim.new(@circ_init)
        # stim_seq = @stim_generator.gen_exhaustive_trans_stim#, trig_cond)
        stim_seq = @stim_generator.gen_exhaustive_incr_stim
        # stim_seq = @stim_generator.gen_random_stim 100
        @stim_generator.save_as_txt "stim.txt", bin_stim_vec: false
    end

    def stim_compute
        @stim_computor = Converter::ComputeStim.new(@circ_init, $DELAY_MODEL)
        computed_vectors = @stim_computor.generate_stim(@circ_init, "og_s38417",save_explicit: "stim.txt", freq: $FREQ, compute_all_transitions: true, all_outputs: true, all_insert_points: true)
        # @stim_computor.save_as_txt("computed_stim.txt", @stim_computor.stim_vec)
        @tmp = @stim_computor.events_computed
    end

    def stim_solve ht_delay
        @stim_computor = AtetaAddOn::Ateta.new(@circ_init, ht_delay,$DELAY_MODEL)
        computed_vectors = @stim_computor.generate_stim
        @stim_computor.save_explicit("solved_stim.txt")
    end

    def testbench_gen 
        @tb_gen = Converter::GenCompTestbench.new(@circ_init, @circ_alt, $DELAY_MODEL)
        @tb_gen.gen_testbench "stim.txt", $FREQ, bit_vec_stim: false
    end

    def script_gen
        @script_generator = Converter::VhdlCompiler.new 
        @script_generator.gtech_makefile ".", $COMPILER
        `make`
        # * : Only for nominal frequency at first
        @script_generator.comp_tb_compile_script ".", @circ_init.name, @circ_alt.name, [$FREQ], $OPT, gtech_path:"."
    end

    def load_enl path
        @circ_init = Marshal.load(IO.read(path))
        @circ_init.getNetlistInformations $DELAY_MODEL
        @grid = @circ_init.get_netlist_precedence_grid
 
        @vhdl_converter = Converter::ConvNetlist2Vhdl.new
        @vhdl_converter.gen_gtech

        @circ_init.get_dot_graph $DELAY_MODEL
    end

    def load_blif path
        blif_loader = Converter::ConvBlif2Netlist.new
        @circ_init = blif_loader.convert path
        @circ_init.getNetlistInformations $DELAY_MODEL
        @grid = @circ_init.get_netlist_precedence_grid

        @vhdl_converter = Converter::ConvNetlist2Vhdl.new
        @vhdl_converter.gen_gtech

        @circ_init.get_dot_graph $DELAY_MODEL
    end 

    def gen_case
        @generator = Netlist::RandomGenComb.new *$CIRC_CARAC
        # * : Generate a netlist
        @circ_init = @generator.getRandomNetlist("rand")
        @circ_init.getNetlistInformations $DELAY_MODEL
        @grid = @generator.grid
        # * : Generate gtech
        @vhdl_converter = Converter::ConvNetlist2Vhdl.new
        @vhdl_converter.gen_gtech
        # * : Generate the VHD files of the generated circuits
        # * : Generate a .dot file
        @circ_init.get_dot_graph $DELAY_MODEL
    end

    def gen_circ_files circ
        @vhdl_converter.generate circ
        circ.get_dot_graph $DELAY_MODEL
        circ.save_as("./")
    end

    def gen_alt_circ
        # * : Alter the initial netlist
        @modifier = Inserter::Tamperer.new(@circ_init.clone, @grid, @circ_init.get_timings_hash($DELAY_MODEL), delay_model: $DELAY_MODEL)
        @modifier.select_ht("og_s38417", $HT_INPUT)

        begin
            attempts ||= 0
            @circ_alt = @modifier.insert2 
            
        rescue Inserter::ImpossibleInsertion, Inserter::ImpossibleResolution
            if $VERBOSE
                puts "Insertion attempt number #{attempts}"
            end

            if (attempts += 1) < 1
                gen_case
                gen_circ_files @circ_init
                # * : Alter the initial netlist
                @modifier = Inserter::Tamperer.new(@circ_init, @generator.grid, @circ_init.get_timings_hash)
                @modifier.select_ht("og_s38417")
                # @circ_alt = nil
                retry
            else 
                raise "Error : Unable to insert with given netlist generation parameters"
            end
        end
        @circ_alt.name = "#{@circ_alt.name}_altered"
        @circ_alt.getNetlistInformations $DELAY_MODEL
    end
end

if __FILE__ == $0
    $CIRC_CARAC = [8, 6, 10, [:custom, 0.80]]
    # $DELAY_MODEL = :one
    $DELAY_MODEL = :int_multi
    $HT_INPUT = 2
    $FREQ = "Infinity"
    $COMPILER = :ghdl
    $OPT = [:ghdl, :all_sig]
    $CIRC_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/xor5.blif"

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        print(self.class)
        env = Test_compTestbench.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end