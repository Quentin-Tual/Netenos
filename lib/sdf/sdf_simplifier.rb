module SDF
  class SimplifierVisitor < Visitor
    SDF_COLS = %i[min typ max]

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

    def visit_ABSOLUTE(subject)
      min_values, typ_values, max_values = SDF_COLS.collect do |col|
        subject.iopaths.collect do |dly_node|
          dly_node.apply_fun_to_col(@fun, col)
        end
      end
      @new_min, @new_typ, @new_max = [min_values, typ_values, max_values].collect { |arr| apply_fun_to_arr(arr) }
      visit_node(subject)
    end

    def visit_INTERCONNECT(subject)
      @new_min, @new_typ, @new_max = SDF_COLS.collect { |col| subject.apply_fun_to_col(@fun, col) }
      subject.delays.accept(self)
    end

    def visit_IOPATH(subject)
      subject.delays.accept(self)
    end

    def visit_DelayTable(subject)
      subject.rise.accept(self)
      subject.fall.accept(self)
    end

    def visit_DelayArray(subject)
      subject.min = format('%.3f', @new_min)
      subject.typ = format('%.3f', @new_typ)
      subject.max = format('%.3f', @new_max)
    end

    def apply_fun_to_arr(values)
      if @fun == :avg or @fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(@fun)
      end
    end
  end
end
