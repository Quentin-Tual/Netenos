module Netlist
  class CircuitVisitor < Visitor
    # Abstract class for all circuit exploration tasks
    attr_reader :visited

    def initialize(nl)
      @nl = nl
      @visited = Set.new([])
    end

    def visited?(obj)
      @visited.add?(obj) ? false : true
    end

    def visit_Circuit(_c)
      raise_not_implemented
    end

    def visit_Gate(_g)
      raise_not_implemented
    end

    def visit_Port(_p)
      raise_not_implemented
    end

    def visit_Wire(_w)
      raise_not_implemented
    end

    def visit_Constant(_const)
      raise_not_implemented
    end
  end
end
