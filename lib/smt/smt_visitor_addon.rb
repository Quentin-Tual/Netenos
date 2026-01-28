module SMT
  class SMTExprExtractor < Visitor
    attr_reader :expr

    def initialize nl
      @nl = nl
      @expr = []
    end

    def visit_Port obj
      if obj.is_output? and obj.is_global?
        obj.get_source_gates.accept(self)
      # else it is a primary input and do nothing
      end
    end

    def visit_Gate n
      sn = n.get_source_gates.flatten # gate or global input sources
      sp_names = sn.collect{|sg| sg.is_a?(Netlist::Gate) ? sg.get_output.get_full_name : sg.get_full_name}

      # ip_index = -1
      smt_expr = n.class::SMT_EXPR.dup
      smt_expr.map! do |w|
        if $SMT_KEYWORDS.include? w
          w
        else
          ip_index = w[1..].to_i
          "(#{sp_names[ip_index]} (- t #{n.propag_time[DLY_MDL]}))"
        end
      end

      @expr << "(define-fun #{n.get_output.get_full_name} ((t Int)) Bool #{smt_expr.join(' ')})"
      
      sn.each do |next_node|
        # smt_netlist_traversal(next_node) unless !next_node.is_a?(Netlist::Gate)
        next_node.accept(self)
      end
    end

    def visit_Wire obj
      raise "Error: method not implemented for #{self.class}."
    end
  end
end

# puts 'START'

# DLY_MDL = :sdf
# V_FILE = 'xor5_prepnr.nl.v'
# SDF_FILE = 'mapped_xor5__nom_tt_025C_1v80.sdf'

# c = Verilog.load_netlist(V_FILE)
# SDF.annotate(c, SDF_FILE)

# puts c.getNetlistInformations(DLY_MDL)
# # puts "Boucle comb : #{c.has_combinational_loop?}"
# # gets

# smt_converter = SMT::SMTExpr.new(c)
# c.get_outputs.each do |op|
#   op.accept(smt_converter)
#   # smt_converter.smt_netlist_traversal(op.get_source_gates)
#   # puts "Processed output #{op.get_full_name} : #{res[0..10]}"
#   # File.write("res#{op.name}.txt", res)  
# end
# puts smt_converter.expr

# puts
# puts 'END'