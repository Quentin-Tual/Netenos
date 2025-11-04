module Bexp
  class ASTNode
    include ::Visitable
  end

  class Operator < ASTNode
    attr_reader :operands

    def initialize *operands
      @operands = operands
    end
  end

  class And < Operator; end;
  class Or < Operator; end;
  class Not < Operator; end;

  # Not used 
  class Operand < ASTNode
    attr_reader :name

    def initialize name 
      @name = name
    end
  end
  
  class SMTConverter < Visitor 
    # Allow to visit each node of a Bexp and to return a SMTLIB boolean expression in the form of an array
    # def initialize 
    #   @smt_exp = []
    # end

    def visit(node)
      case node
      when And
        visitAnd(node)
      when Or
        visitOr(node)
      when Not
        visitNot(node)
      when Operand
        visitOperand(node)
      else
        raise "Error: Unexpected class encountered #{node.class} during visit."
      end
    end

    def visitAnd(node)
      exp = ['(','and']
      node.operands.each do |op|
        exp += visit(op)
      end
      exp << ')'
    end

    def visitOr(node)
      exp = ['(','or']
      node.operands.each do |op|
        exp += visit(op)
      end
      exp << ')'
    end

    def visitNot(node)
      exp = ['(','not']
      node.operands.each do |op|
        exp += visit(op)
      end
      exp << ')'
    end

    def visitOperand(node)
      [node.name]
    end
  end
end