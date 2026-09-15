class Visitor 
  def visit(subject)
    raise NotImplementedError.new
  end

  def raise_not_implemented
    raise NotImplementedError.new 'Error: not implemented, abstract class and/or unexpected usage'
  end
end

module Visitable 
  def accept(visitor)
    visitor.visit(self)
  end
end