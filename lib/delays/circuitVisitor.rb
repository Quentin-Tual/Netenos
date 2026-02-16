module Netlist
  
  class CircuitVisitor < Visitor
    # Abstract class for all circuit exploration tasks

    def initialize nl
      @nl = nl
      @visited = Set.new([])
    end

    def raise_not_implemented
      raise "Error: Not implemented"
    end

    def visited? obj
      if @visited.include? obj
        true
      else
        @visited << obj
        false
      end
    end

    def visit_Circuit c
      raise_not_implemented
    end

    def visit_Gate g
      raise_not_implemented
    end

    def visit_Port p
      raise_not_implemented
    end

    def visit_Wire w
      raise_not_implemented
    end
    
    def visit_Constant const
      raise_not_implemented
    end
  end

end