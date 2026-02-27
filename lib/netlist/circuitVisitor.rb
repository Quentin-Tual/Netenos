module Netlist

  class CircuitVisitor < Visitor
    # Abstract class for all circuit exploration tasks
    attr_reader :visited

    def initialize nl
      @nl = nl
      @visited = Set.new([])
    end

    def visited? obj
      @visited.add?(obj) ? false : true
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