module SDF
  class SimplifierRFIOLastValVisitor < SimplifierRFIOVisitor
    SDF_COLS = [:min, :typ, :max]

    def get_last_rise_value g
      SDF_COLS.collect do |col| 
        iopath = g.last
        iopath.get_flat_float_list_rising(col)
      end
    end

    def get_last_fall_value g
      SDF_COLS.collect do |col| 
        iopath = g.last
        iopath.get_flat_float_list_falling(col)
      end
    end

    def simplify_ioarc_group_by_last(subject)
      groups = get_ioarcs_group(subject)
      groups.each do |g|
      # Pour chaque colonne (min, typ, max)
        # Récupérer toutes les valeurs RISE des éléments de g 
        # Récupérer toutes les valeurs FALL des éléments de g
        # Appliquer la fonction @fun pour conserver une seule valeur
        
        @rise_values = get_last_rise_value(g)#.collect{|col_values| apply_fun_to_arr(col_values)}
        @fall_values = get_last_fall_value(g)#.collect{|col_values| apply_fun_to_arr(col_values)}
        # Fixer toutes les valeurs RISE à la valeur obtenue
        # Idem pour les valeurs FALL
        g.each{|iopath_node| iopath_node.accept(self)} 
      end
    end

    def visit_ABSOLUTE(subject)
      unless subject.contains_class? INTERCONNECT
        simplify_ioarc_group_by_last(subject)
      end
    end

  end
end
