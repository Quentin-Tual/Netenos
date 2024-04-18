
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
include Netlist

$CIRC_CARAC = [6, 3, 10, [:even, 0.70]]
$DELAY_MODEL = :int_multi
$FREQ = 10

class Test_compTestbench
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
        stim_seq = @stim_generator.gen_exhaustive_trans_stim#, trig_cond)
        @stim_generator.save_as_txt "stim.txt"

        @tb_gen = Converter::GenCompTestbench.new(@circ_init, @circ_alt, $DELAY_MODEL)
        @tb_gen.gen_testbench "stim.txt", $FREQ

        @script_generator = Converter::VhdlCompiler.new 
        @script_generator.gtech_makefile ".", $COMPILER
        `make`
        # * : Only for nominal frequency at first
        @script_generator.comp_tb_compile_script ".", @circ_init.name, @circ_alt.name, [$FREQ], $OPT, gtech_path:"."
    end

    def gen_case
        @generator = Netlist::RandomGenComb.new *$CIRC_CARAC
        # * : Generate a netlist
        @circ_init = @generator.getRandomNetlist("rand")
        @circ_init.getNetlistInformations $DELAY_MODEL
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
    Dir.chdir("tmp") do
        puts "Lancement #{__FILE__}" 
        env = Test_compTestbench.new 
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