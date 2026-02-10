module SDF
  class SimplifierRFIOVisitor < Visitor
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
  
    def get_ioarcs_group absolute_node
      absolute_node.subnodes.group_by{|n| n.wire.source_name.name + n.wire.sink_name.name}.values
    end

    def visit_ABSOLUTE(subject)
      unless subject.contains_class? INTERCONNECT
        groups = get_ioarcs_group(subject)
        groups.each do |g|
        # Pour chaque colonne (min, typ, max)
          # Récupérer toutes les valeurs RISE des éléments de g 
          rise_values = SDF_COLS.collect{|col| g.collect{|iopath| iopath.get_flat_float_list_rising(col)}.flatten}
          # Récupérer toutes les valeurs FALL des éléments de g
          fall_values = SDF_COLS.collect{|col| g.collect{|iopath| iopath.get_flat_float_list_falling(col)}.flatten}
          # Appliquer la fonction @fun pour conserver une seule valeur
          @rise_values = rise_values.collect{|col_values| apply_fun_to_arr(col_values)}
          @fall_values = fall_values.collect{|col_values| apply_fun_to_arr(col_values)}
          # Fixer toutes les valeurs RISE à la valeur obtenue
          # Idem pour les valeurs FALL
          g.each{|iopath_node| iopath_node.accept(self)} 
        end
      end
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
