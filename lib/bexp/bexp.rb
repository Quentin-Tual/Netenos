module Bexp
  class ASTNode
    include ::Visitable

    def accept(visitor)
      self_classname = self.class.name.split('::').last.downcase
      visitor.send("visit_#{self_classname}".to_sym, self)
    end
  end

  class Operator < ASTNode
    attr_reader :operands

    def initialize(*operands)
      @operands = operands
    end
  end

  class And < Operator; end
  class Or < Operator; end

  class Not < Operator
    def initialize(*operands)
      raise "More operands than expected for a not operation, #{operands.length} instead of 1" if operands.length > 1

      super(*operands)
    end
  end

  # Not used
  class Operand < ASTNode
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class SMTConverter < Visitor
    # Allow to visit each node of a Bexp and to return a SMTLIB boolean expression in the form of an array

    def visit_and(node)
      exp = ['(', 'and']
      node.operands.each do |op|
        exp += op.accept(self)
      end
      exp << ')'
    end

    def visit_or(node)
      exp = ['(', 'or']
      node.operands.each do |op|
        exp += op.accept(self)
      end
      exp << ')'
    end

    def visit_not(node)
      exp = ['(', 'not']
      node.operands.each do |op|
        exp += op.accept(self)
      end
      exp << ')'
    end

    def visit_operand(node)
      [node.name]
    end
  end

  class RubyConverter < Visitor
    # Allow to visit each node of a Bexp and to return a Ruby boolean expression in a string class object
    def initialize
      @operand_idx = -1
      @sym_tab = Hash.new { |h, k| h[k] = (@operand_idx += 1) }
    end

    def visit_and(node)
      exp = '('
      operands = node.operands.collect do |op|
        op.accept(self)
      end
      exp += operands.join(' && ')
      exp += ')'
      exp
    end

    def visit_or(node)
      exp = '('
      operands = node.operands.collect do |op|
        op.accept(self)
      end
      exp += operands.join(' || ')
      exp += ')'
      exp
    end

    def visit_not(node)
      exp = '(! '
      exp += node.operands.first.accept(self)
      exp += ')'
      exp
    end

    def visit_operand(node)
      "i[#{@sym_tab[node.name]}]"
    end
  end
end
