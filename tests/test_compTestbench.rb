
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "../lib/converter/genStim2.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
include Netlist

class Test_compTestbench
    attr_accessor :circ_init, :circ_alt

    def initialize
        
        puts "[+] Initial circuit generation" if $VERBOSE
        # gen_case 
        load_blif "../f51m.blif"
        # load_enl "../test_circ.enl"
        gen_circ_files @circ_init

        # * : Alter the initial netlist
        @modifier = Inserter::Tamperer.new(@circ_init.clone, @grid, @circ_init.get_timings_hash)
        @modifier.select_ht("og_s38417", $HT_INPUT)

        # stim_compute # ! Test stim computation
                
        puts "[+] Altered circuit generation" if $VERBOSE
        gen_alt_circ
        gen_circ_files @circ_alt

        puts "[+] circ_init reloading" if $VERBOSE
        @circ_init = Marshal.load(IO.read("#{@circ_init.name}.enl"))
    end

    def run
        puts "[+] Stimulus generation" if $VERBOSE
        # stim_gen # ! test_stim computation
        puts "[+] Testbench generation" if $VERBOSE
        testbench_gen
        puts "[+] Scripts generation" if $VERBOSE
        script_gen
        puts "[+] Compile and simulate" if $VERBOSE
        `./compile.sh`
    end

    def stim_gen 
        @stim_generator = Converter::GenStim.new(@circ_init)
        stim_seq = @stim_generator.gen_exhaustive_trans_stim#, trig_cond)
        # stim_seq = @stim_generator.gen_random_stim 100
        @stim_generator.save_as_txt "stim.txt", bin_stim_vec: false
    end

    def stim_compute
        @stim_computor = Converter::ComputeStim.new(@circ_init, $DELAY_MODEL)
        @stim_computor.generate_stim(@circ_init, "og_s38417",save_explicit:"stim.txt")
        # @stim_computor.save_as_txt("computed_stim.txt", @stim_computor.stim_vec)
        @tmp = @stim_computor.events_computed
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

        @viewer = Converter::DotGen.new
        @viewer.dot(@circ_init, @circ_init.name)
    end

    def load_blif path
        blif_loader = Converter::ConvBlif2Netlist.new
        @circ_init = blif_loader.convert path
        @circ_init.getNetlistInformations $DELAY_MODEL
        @grid = @circ_init.get_netlist_precedence_grid

        @vhdl_converter = Converter::ConvNetlist2Vhdl.new
        @vhdl_converter.gen_gtech

        @viewer = Converter::DotGen.new
        @viewer.dot(@circ_init, @circ_init.name)
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
        @viewer = Converter::DotGen.new
    end

    def gen_circ_files circ
        @vhdl_converter.generate circ
        @viewer.dot circ, nil, $DELAY_MODEL
        circ.save_as("./")
    end

    def gen_alt_circ
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
    $CIRC_CARAC = [6, 3, 10, [:even, 0.70]]
    $DELAY_MODEL = :int_multi
    $HT_INPUT = 2
    $FREQ = 1.1
    $OPT = [:ghdl, :all_sig]

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        print(self.class)
        env = Test_compTestbench.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end
  

# circ_init, circ_alt = env.gen_case 

# circ_alt.name = "#{circ_alt.name}_altered"

# env.circ_init = circ_init
# env.circ_alt = circ_alt

# pp env.circ_init.getNetlistInformations $DELAY_MODEL
# pp env.circ_init.object_id
# pp env.circ_alt.getNetlistInformations $DELAY_MODEL
# pp env.circ_alt.object_id


# pp env.circ_init.name
# pp env.circ_alt.name

# # * : (optionnal) Generate a .dot file
# viewer = Converter::DotGen.new
# viewer.dot env.circ_init, nil, $DELAY_MODEL
# # * : (optionnal) Generate a .dot file
# viewer.dot env.circ_alt, nil, $DELAY_MODEL

# # TODO : Générer le vhdl, le testbench, les stim, le script de compil et vérifier les traces

# # * : Generate GTECH  
# vhdl_converter = Converter::ConvNetlist2Vhdl.new
# vhdl_converter.gen_gtech
# # * : Generate the VHD files of the generated circuits
# vhdl_converter.generate env.circ_init
# vhdl_converter.generate env.circ_alt

# stim_generator = Converter::GenStim.new(env.circ_init)
# stim_seq = stim_generator.gen_exhaustive_trans_stim#, trig_cond)
# stim_generator.save_as_txt "stim.txt"

# tb_gen = Converter::GenCompTestbench.new(env.circ_init, env.circ_alt, $DELAY_MODEL)
# tb_gen.gen_testbench "stim.txt"

# # tb_gen = Converter::GenTestbench.new(circ_test, margin_first_sim)
# # tb_gen.stimuli = stim_seq
# # tb_test = tb_gen.gen_testbench "stim.txt", test_frequencies.first, circ_test.name

# # * : Generate the compile and simulate script (convNetlist2Vhdl copy)
# vhdl_CS_script = Converter::VhdlCompiler.new 
# vhdl_CS_script.gtech_makefile ".", :ghdl
# `make`
# # * : Only for nominal frequency at first
# vhdl_CS_script.comp_tb_compile_script ".", env.circ_init.name, env.circ_alt.name, [1]
# # vhdl_CS_script.circ_compile_script ".", @circ_alt.name, [1], [:ghdl, :minimal_sig], true

# # * : Compile and simulate using the script
# system("./compile.sh")


# pp @circ_alt.getNetlistInformations $DELAY_MODEL
# @viewer.dot(@circ_alt, 'rand_circ_mod.dot')
# end
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)