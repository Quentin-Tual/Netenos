module SDF
  class NullifyRoutingDelays < Visitor

    # def initialize
    #   super
    # end

    def visit_node(subject)
      subject.subnodes.map { |n| n.accept(self) }
    end

    def ignore(subject); end

    def visit_edgenode(subject)
      ignore(subject)
    end

    def visit_Root(subject)
      visit_node(subject)
      return subject
    end

    def visit_DelayNode(subject)
      visit_node(subject)
    end

    def visit_DELAYFILE(subject)
      visit_node(subject)
    end

    def visit_DESIGN(subject)
      ignore(subject)
    end

    def visit_TIMESCALE(subject)
      ignore(subject)
    end

    def visit_CELL(subject)
      is_top_module = subject.instance.data.name.empty?
      is_eco_buffer = subject.instance.data.name.include?('eco_buffer')
      is_a_buffer = subject.celltype.data.include?('buf')
      is_a_delay = subject.celltype.data.include?('dly')

      if (!(is_eco_buffer) and (is_a_buffer or is_a_delay)) or is_top_module # is not an ECO inserted buffer but is a buffer
        subject.delay.accept(self)
      else
        ignore(subject)
      end
    end

    def visit_CELLTYPE(subject)
      ignore(subject)
    end

    def visit_INSTANCE(subject)
      ignore(subject)
    end

    def visit_DELAY(subject)
      visit_node(subject)
    end

    def visit_ABSOLUTE(subject)
      reset_values(subject)
    end

    # def visit_INTERCONNECT(subject)
    #   reset_values(subject)
    # end

    # def visit_IOPATH(subject)
    #   ignore(subject)
    # end

    def reset_values(subject)
      # new_val = subject.apply_fun(@fun)
      subject.subnodes.map do |delayTable|
        delayTable.delays.attr_list.map do |delayArray|
          set_values(delayArray, 0.0)
        end
      end
    end

    def set_values(subject, new_val)
      subject.min = subject.typ = subject.max = new_val
    end
  end
end
