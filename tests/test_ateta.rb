#! /usr/env/bin ruby    
require 'benchmark'
require_relative "../lib/netenos.rb"
# require 'netenos'
# require_relative "../lib/converter/genStim2.rb"
# require_relative "./test_compTestbench.rb"


# $CIRC_CARAC = [8, 4, 15, [:even, 0.70]]
$DELAY_MODEL = :one
$HT_DELAY = 1
$FREQ = "Infinity"
$COMPILER = :ghdl
$OPT = [$COMPILER, :minimal_sig]

class Test_ateta

    def initialize 

        # * Clean 'tmp' directory just in case
        # `rm *`

        blifPath = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/f51m.blif"
        circ = Converter::ConvBlif2Netlist.new.convert(blifPath, truth_table_format: true)
        # circ = Marshal.load(File.read("../../rand_3.enl"))
        pp circ.getNetlistInformations($DELAY_MODEL)
        # circ.get_slack_hash
        circ.get_dot_graph
        @nbInputs = circ.get_inputs.length
        @uut = AtetaAddOn::Ateta.new(circ, $HT_DELAY, $DELAY_MODEL)
    end

    def run
        timings = Benchmark.measure{
            vec_list = @uut.generate_stim([])#, ("%0#{@nbInputs}b" % 41).reverse])#,("%0#{@nbInputs}b" % 2).reverse])#, "%0#{@nbInputs}b" % 6])
        }
        puts timings.format

        @uut.save_explicit "test.stim"
    end

    # def gen_testbench 
    #     @tb_gen = Converter::GenCompTestbench.new(@circ_init, @circ_alt, $DELAY_MODEL)
    #     @tb_gen.gen_testbench "test.stim", $FREQ, bit_vec_stim: false
    # end

    # def simulate

    # end
end

if __FILE__ == $0
    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        env = Test_ateta.new
        env.run
        puts "Fin #{__FILE__}"
    end
end
  
