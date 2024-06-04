#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "../lib/converter/genStim2.rb"
require_relative "./test_compTestbench.rb"


$CIRC_CARAC = [8, 4, 15, [:even, 0.70]]
$DELAY_MODEL = :int_multi
$FREQ = 1
$COMPILER = :nvc
$OPT = [$COMPILER, :minimal_sig]

class Test_binStim < Test_compTestbench

    def initialize 

        # * Clean 'tmp' directory just in case
        `rm *`

        # * Build a test case
        super
    end

    def run
        puts "[+] Stimulus generation" if $VERBOSE
        bin_stim_gen
        puts "[+] Testbench generation" if $VERBOSE
        bin_testbench_gen
        puts "[+] Scripts generation" if $VERBOSE
        script_gen
        puts "[+] Compile and simulate" if $VERBOSE
        # * compile and simulate 
        `./compile.sh`
        # puts "Waiting input to continue with trace comparison (memory observation in real time)" #!DEBUG
        # gets
        puts "[+] Trace comparison" if $VERBOSE
        pp trace_comparison
    end

    def bin_stim_gen 
        @stim_generator = Converter::GenStim.new(@circ_init)
        vec_list = @stim_generator.conv_stim_2_vec_list(@stim_generator.gen_exhaustive_incr_stim)
        @stim_generator.extend_exh_trans_in_file(vec_list, "extended_stim.txt",binary_text: false, max_in_mem_elements: 100_000_000)
    end

    def bin_testbench_gen 
        @tb_gen = Converter::GenCompTestbench.new(@circ_init, @circ_alt, $DELAY_MODEL)
        @tb_gen.gen_testbench "extended_stim.txt", $FREQ, bit_vec_stim: false
    end

    def trace_comparison
        # TODO : Charger les traces
        trace_extractor = VCD::Vcd_Signal_Extractor.new
        t = trace_extractor.extract2 "#{@circ_init.name}_#{$FREQ}_tb.vcd", $COMPILER

        # TODO : Instancier un comparateur et lancer la comparaison
        comparator = VCD::Vcd_Comparer.new
        cycle_diff = comparator.compare_comparative_tb_traces2 t["output_traces"], @circ_init.get_outputs.collect{|o| "tb_#{o.name}_s"}, @circ_init.crit_path_length+1, @circ_alt.crit_path_length+1

        return cycle_diff.length
    end
end

if __FILE__ == $0
    Dir.chdir("tmp") do
        puts "Lancement #{__FILE__}" 
        env = Test_binStim.new
        env.run
        puts "Fin #{__FILE__}"
    end
end
  
