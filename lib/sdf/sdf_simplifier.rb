module SDF 

 
  class SimplifierVisitor < Visitor
    def initialize function = :max#, ignore_rise_fall = true
      # @ignore_rise_fall = ignore_rise_fall
      @fun = function
    end

    def visit(subject)
      case subject
      when ABSOLUTE
        simplify(subject)
      when Node 
        subject.subnodes.map{|n| n.accept(self)}
      when EdgeNode
        # ignore
      else
        raise "Error: SimplifierVisitor nor applicable on #{subject.inspect}"
      end
    end

    def simplify(subject)
      new_val = subject.apply_fun(@fun)
      subject.subnodes.map do |delayTable|
        delayTable.delays.attr_list.map do |delayArray| 
          set_values(delayArray,new_val)
        end
      end
    end
    
    def set_values(subject, new_val)
      subject.min = subject.typ = subject.max = new_val
    end

  end
end