module SDF
  class NoiseAdder < Visitor
    attr_reader :history

    def initialize#(variation_rate)
      # @variation_rate = variation_rate
      @prng = Random.new
      @history = []
    end

    def visit_node(subject)
      subject.subnodes.map { |n| n.accept(self) }
    end

    def ignore_edge(subject); end

    def visit_edgenode(subject)
      ignore_edge(subject)
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
      add_noise(subject)
    end

    def visit_INTERCONNECT(subject)
      ignore_edge(subject)
    end

    def visit_IOPATH(subject)
      ignore_edge(subject)
    end

    def add_noise(subject)
      # new_val = subject.apply_fun(@fun)
      subject.subnodes.map do |delayTable|
        delayTable.delays.attr_list.map do |delayArray|
          set_values(delayArray)
        end
      end
    end

    def set_values(subject)
      # random_noise = @prng.rand(@variation_rate*2) - @variation_rate
      # @history << random_noise
      # new_typ = (subject.typ.to_f + random_noise*subject.typ.to_f).round(3)
      # new_typ = [new_typ, subject.min.to_f].max
      # new_typ = [new_typ, subject.max.to_f].min
      min = subject.min.to_f
      max = subject.max.to_f
      unless min >= max 
        new_val = rand(min..max).round(3)
        @history << new_val - subject.typ.to_f
        subject.typ = format('%<num>1.3f', num: new_val)
      end
    end
  end
end
