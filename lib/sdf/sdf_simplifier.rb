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
      values = subject.subnodes.collect do |delayTable|
        delayTable.delays.attr_list.collect do |delayArray| 
          get_value(delayArray)
        end
      end.flatten
      new_val = values.send(@fun)
      subject.subnodes.map do |delayTable|
        delayTable.delays.attr_list.map do |delayArray| 
          set_values(delayArray,new_val)
        end
      end
    end

    def get_value(subject)
      subject.send(@fun)
    end
    
    def set_values(subject, new_val)
      subject.min = subject.typ = subject.max = new_val
    end
  end
  
end