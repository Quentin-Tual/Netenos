require_relative '../lib/reverse/invertedNetlist.rb'
require_relative '../lib/netenos.rb'



class Test_InvertedNetlist
  def initialize
    circ = Converter::ConvBlif2Netlist.new.convert("../C17.blif")
    Converter::DotGen.new.dot circ, "./test_initialNetlist.dot"
    @uut = Reverse::InvertedCircuit.new(circ)
    Converter::DotGen.new.dot circ, "./test_invertedNetlist.dot"
  end
  
  def run

    # circ = @uut.convert "../xparc.blif"
    # circ = @uut.convert "../p82.blif"
    # grid = circ.get_netlist_precedence_grid
    # `xdot test_convBlif2Netlist.dot`
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
        env = Test_InvertedNetlist.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end.convert