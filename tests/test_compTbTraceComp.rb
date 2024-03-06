#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "./test_compTestbench.rb"


$CIRC_CARAC = [8, 4, 15, [:even, 0.70]]
$DELAY_MODEL = :int_multi
$FREQ = 10
$COMPILER = :ghdl

class Test_compTbTraceCompt < Test_compTestbench

    def initialize 

        # * Clean 'tmp' directory just in case
        `rm *`

        # * Build a test case
        super

        # * compile and simulate 
        `./compile.sh`

        # TODO : Charger les traces
        trace_extractor = VCD::Vcd_Signal_Extractor.new
        t = trace_extractor.extract "#{@circ_init.name}_#{$FREQ}_tb.vcd", $COMPILER

        # TODO : Instancier un comparateur et lancer la comparaison
        comparator = VCD::Vcd_Comparer.new
        cycle_diff = comparator.compare_comparative_tb_traces t["output_traces"], @circ_init.get_outputs.collect{|o| "tb_#{o.name}_s"}, @circ_init.crit_path_length+1

        pp cycle_diff
        # TODO : Vérifier la correspondance du print avec gtkwave
    end

end

Dir.chdir("tmp") do
    puts "Lancement #{__FILE__}" 
    env = Test_compTbTraceCompt.new
    puts "Fin #{__FILE__}"
end