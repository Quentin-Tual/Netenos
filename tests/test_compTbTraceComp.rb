#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "./test_compTestbench.rb"

class Test_compTbTraceCompt < Test_compTestbench

    def initialize 

        # * Clean 'tmp' directory just in case
        `rm *`

        # * Build a test case
        super

    end

    def compare_traces
        # TODO : Charger les traces
        trace_extractor = VCD::Vcd_Signal_Extractor.new
        
        if $FREQ == "Infinity"
            monitored_signals = @circ_init.get_outputs.collect{|o| "tb_#{o.name}"}
        else
            monitored_signals = @circ_init.get_outputs.collect{|o| "tb_#{o.name}_s"}
        end

        t = trace_extractor.extract2 "#{@circ_init.name}_#{$FREQ.to_s.split('.').join}_tb.vcd", $COMPILER, monitored_signals

        # TODO : Instancier un comparateur et lancer la comparaison
        comparator = VCD::Vcd_Comparer.new
        cycle_diff = comparator.compare_comparative_tb_traces2(t["output_traces"], monitored_signals, @circ_init.crit_path_length+1, @circ_alt.crit_path_length+1)

        # pp cycle_diff
        # TODO : Vérifier la correspondance du print avec gtkwave
        return cycle_diff
    end

    def run
        # * Generate, compile and simulate 
        super
        # `./compile.sh`
        compare_traces
    end

end

if __FILE__ == $0
    $CIRC_CARAC = [8, 4, 15, [:even, 0.70]]
    $DELAY_MODEL = :int_multi
    $FREQ = 10
    $COMPILER = :ghdl
    
    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        env = Test_compTbTraceCompt.new
        env.run
        puts "Fin #{__FILE__}"
    end
  end
  
