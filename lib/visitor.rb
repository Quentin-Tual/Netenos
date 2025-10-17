class Visitor 
  def visit(subject)
    raise NotImplementedError.new
  end
end

module Visitable 
  def accept(visitor)
    visitor.visit(self)
  end
end