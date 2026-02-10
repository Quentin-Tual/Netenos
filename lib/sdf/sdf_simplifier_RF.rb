module SDF
  class SimplifierRFVisitor < Visitor
    SDF_COLS = [:min, :typ, :max]

    def initialize(function = :max) 
      @fun = function
    end

    def visit_node(subject)
      subject.subnodes.map { |n| n.accept(self) }
    end

    def ignore_edge(subject); end

    def visit_Root(subject)
      visit_node(subject)
    end

    def visit_DelayNode(subject)
      visit_node(subject)
    end

    def visit_DELAYFILE(subject)
      visit_node(subject)
    end

    def visit_DESIGN(subject)
      ignore_edge(subject)
    end

    def visit_TIMESCALE(subject)
      ignore_edge(subject)
    end

    def visit_CELL(subject)
      visit_node(subject)
    end

    def visit_CELLTYPE(subject)
      ignore_edge(subject)
    end

    def visit_INSTANCE(subject)
      ignore_edge(subject)
    end

    def visit_DELAY(subject)
      visit_node(subject)
    end

    def get_rise_values subject
      SDF_COLS.collect{|col| subject.apply_fun_to_col_rising(@fun,col)}
    end

    def get_fall_values subject
      SDF_COLS.collect{|col| subject.apply_fun_to_col_falling(@fun,col)}
    end

    def visit_ABSOLUTE(subject)
      @rise_values = get_rise_values(subject)
      @fall_values = get_fall_values(subject)

      visit_node(subject)
    end

    def visit_INTERCONNECT(subject)
      ignore_edge(subject)
    end

    def visit_IOPATH(subject)
      subject.delays.accept(self)
    end

    def visit_DelayTable(subject)
      @new_min, @new_typ, @new_max = @rise_values
      subject.rise.accept(self)
      
      @new_min, @new_typ, @new_max = @fall_values
      subject.fall.accept(self)
    end 

    def visit_DelayArray(subject)
      subject.min = "%.3f" % @new_min
      subject.typ = "%.3f" % @new_typ
      subject.max = "%.3f" % @new_max
    end

    def apply_fun_to_arr values
      if @fun == :avg or @fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(@fun)
      end
    end

  end
end
