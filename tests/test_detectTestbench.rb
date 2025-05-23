
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "./test_compTestbench.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
include Netlist

$CIRC_CARAC = [8, 2, 10, [:even, 0.70]]
$DELAY_MODEL = :int_multi
$FREQ = "Infinity"
$COMPILER = :ghdl
$OPT = [$COMPILER, :uut_sig]
$HT_INPUT = 2

class Test_detectTestbench < Test_compTestbench
    attr_accessor :circ_init, :circ_alt

    def initialize
        
        gen_case 
        gen_circ_files @circ_init

        # * : Alter the initial netlist
        @modifier = Inserter::Tamperer.new(@circ_init.clone, @generator.grid, @circ_init.get_timings_hash)
        @modifier.select_ht("og_s38417")
                
        gen_alt_circ
        gen_circ_files @circ_alt

        @circ_init = Marshal.load(IO.read("#{@circ_init.name}.enl"))

        @stim_generator = Converter::GenStim.new(@circ_init)
        stim_seq = @stim_generator.gen_exhaustive_incr_stim#, trig_cond)
        @stim_generator.save_as_txt "stim.txt", bin_stim_vec: "dec"

        @tb_gen = Converter::GenDetectTestbench.new(@circ_init, @circ_alt, $DELAY_MODEL)
        @tb_gen.gen_testbench "stim.txt", $FREQ, bit_vec_stim: false

        @script_generator = Converter::VhdlCompiler.new 
        @script_generator.gtech_makefile ".", $COMPILER
        `make`
        # * : Only for nominal frequency at first
        @script_generator.comp_tb_compile_script ".", @circ_init.name, @circ_alt.name, [$FREQ], $OPT, gtech_path:"."
    end

end

if __FILE__ == $0
    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        env = Test_detectTestbench.new 
        `./compile.sh`
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