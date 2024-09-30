require_relative "../lib/netenos.rb"
# require_relative "../lib/converter/computeStim5.rb"

include Netlist
# include VHDL

class Test_computeStim
    attr_accessor :compStim, :circ
    
    def initialize
        @circ = nil
    end

    def load_blif path
        @circ = Converter::ConvBlif2Netlist.new.convert path
    end
    
    def run
        @circ = load_blif("C17.blif")
        @circ.getNetlistInformations($DELAY_MODEL)
        Converter::DotGen.new.dot @circ, "./test.dot"
        slack_h = @circ.get_slack_hash($DELAY_MODEL)

        if slack_h.length <= 1
            puts "Not valid slack"
        else 
            puts "Valid !!"
        end
    end
end

if __FILE__ == $0
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