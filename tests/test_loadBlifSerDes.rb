require_relative "../lib/netenos.rb"
require_relative "../lib/converter/convBlif2Netlist.rb"

include Netlist
# include VHDL

class Test_convBlif2Netlist 
    def initialize
        Netlist::generate_gtech(4)
        @uut = Converter::ConvBlif2Netlist.new
    end

    def run
        # nb_inputs = @uut.get_nb_inputs("/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/clip.blif")
        circ = @uut.convert "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/xor5.blif"
        # circ = @uut.convert "../xparc.blif"
        # circ = @uut.convert "../p82.blif"
        # circ = @uut.convert("../test.blif", truth_table_format: false)

        grid = circ.get_netlist_precedence_grid
        circ.get_exact_crit_path_length($DELAY_MODEL)
        circ.get_slack_hash
        Converter::DotGen.new.dot circ, "./test_loadBlifSerDes.dot"
        
        Serializer.new.serialize(circ)
        circ.save_as("#{circ.name}.sexp","sexp")
        circ2 = Deserializer.new.deserialize("#{circ.name}.sexp")
        grid = circ2.get_netlist_precedence_grid
        circ2.get_exact_crit_path_length($DELAY_MODEL)
        circ2.get_slack_hash
        Converter::DotGen.new.dot circ2, "./test_loadBlifSerDes2.dot"
    end
end

if __FILE__ == $0
    # $CIRC_CARAC = [6, 3, 10, [:even, 0.70]]
    $DELAY_MODEL = :int_multi
    $COMPILER = :ghdl5
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