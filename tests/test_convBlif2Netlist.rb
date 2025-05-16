require_relative "../lib/netenos.rb"
require_relative "../lib/converter/convBlif2Netlist.rb"

include Netlist
# include VHDL

class Test_convBlif2Netlist 
    def initialize
        @uut = Converter::ConvBlif2Netlist.new
    end

    def run
        # nb_inputs = @uut.get_nb_inputs("/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/clip.blif")
        circ = @uut.convert "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/f51m.blif"
        # circ = @uut.convert "../xparc.blif"
        # circ = @uut.convert "../p82.blif"
        # circ = @uut.convert("../test.blif", truth_table_format: false)

        grid = circ.get_netlist_precedence_grid
        circ.get_exact_crit_path_length($DELAY_MODEL)
        circ.get_slack_hash
        
        Converter::DotGen.new.dot circ, "./test_convBlif2Netlist.dot"
        `xdot test_convBlif2Netlist.dot`

        # ! TEST
        vhdl_generator = Converter::ConvNetlist2Vhdl.new(circ)
        vhdl_generator.generate(circ, $DELAY_MODEL)
    end
end

if __FILE__ == $0
    # $CIRC_CARAC = [6, 3, 10, [:even, 0.70]]
    $DELAY_MODEL = :int_multi
    $COMPILER = :ghdl3
    # $FREQ = 1

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        'rm *'
        # print(self.class)
        env = Test_convBlif2Netlist.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end