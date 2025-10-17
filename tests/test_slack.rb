require_relative "../lib/netenos.rb"
# require_relative "../lib/converter/computeStim5.rb"

include Netlist
# include VHDL

class Test_computeStim
    attr_accessor :compStim, :circ
    
    def initialize
        @circ = nil
        @generator = Netlist::RandomGenComb.new(*$CIRC_CARAC)
    end

    def load_blif path
        @circ = Converter::ConvBlif2Netlist.new.convert path
    end

    def load_marshal path
        @circ = Marshal.load(File.read(path))
    end

    def gen_rand_circ 
        @circ = @generator.getValidRandomNetlist "test"
        @circ.getNetlistInformations $DELAY_MODEL
    end
    
    def run
        # load_blif("../xor5.blif")
        # gen_rand_circ
        load_marshal("../xor5_wire.msl")
        @circ.getNetlistInformations($DELAY_MODEL)
        Converter::DotGen.new.dot @circ, "./test.dot"
        slack_h = @circ.get_slack_hash

        if slack_h.length <= 1 and slack_h.keys.include?(nil)
            puts "Not valid slack"
        else 
            pp slack_h
            puts "Valid !!"
        end
    end
end

if __FILE__ == $0
    $CIRC_CARAC = [8, 4, 15, [:custom, 0.70]]
    $DELAY_MODEL = :int_multi
    $COMPILER = :ghdl3
    $FREQ = 1

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        'rm *'
        # print(self.class)
        env = Test_computeStim.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end