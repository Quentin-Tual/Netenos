require_relative "../lib/netenos.rb"
require_relative "../lib/converter/convBlif2Netlist.rb"

# include Netlist
# include VHDL

class Test_booleanExpression
    def initialize
        blif_converter = Converter::ConvBlif2Netlist.new
        @circ = blif_converter.convert "../xor5.blif"
    end

    def run
        exp = {}
        @circ.get_outputs.each{|out_p| exp[out_p] = @circ.get_global_expression(out_p.name)}
        exp.each{|o, expr| exp[o] = @circ.expr_to_h(expr)} 
        exp.each{|o, expr| exp[o] = @circ.get_str_exp(expr)}
        eval_proc = @circ.get_eval_proc(exp.values[0]) 
        pp exp
        Converter::DotGen.new.dot @circ, "./test_booleanExpression.dot"
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
        env = Test_booleanExpression.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end