module SMT
  class SMTExprExtractor < Netlist::CircuitVisitor
    attr_reader :expr

    def initialize nl, delays, sdf_col: :typ
      super(nl)
      @delays = delays
      @sdf_col = sdf_col
      @src = []
      @expr = []
      @prefix = nl.name + '/'
    end

    def save_as path 
      File.write(path, print, mode: 'a')
    end

    def print 
      @expr.reverse.join("\n")
    end

    def visit_Port p
      return if visited?(p)

      # Plusieurs cas selon que p est :
      #   - une sortie primaire 
      #   - la sortie d'une porte
      #   - l'entrée d'une porte ?
      #   - une entrée primaire
      
      primary_port = p.is_global?
      input_port = p.is_input?

      case [primary_port, input_port]
      when [false, false] # sortie d'une porte (le + fréquent)
        visit_gate_output(p)
      when [true, true]   # entrée primaire (le 2eme + fréquent) 
        visit_prim_input(p)
      when [true, false]  # sortie primaire (le 3 eme + fréquent)
        visit_prim_output(p)
      else # entrée d'une porte (ne devrait jamais arriver)
        raise "Error : unexpected primary input #{p.get_full_name} encountered during the visit of #{@nl.name}"
      end

      if p.is_output? and p.is_global?
        p.get_source_gates.accept(self)
      end
    end

    def visit_gate_output(op)
      op.partof.accept(self)
    end

    def declare_input_constant(name)
      @expr << "(declare-const #{name}_d Bool)"
      @expr << "(declare-const #{name}_a Bool)"
    end 

    def visit_prim_input(ip)
      pip_name = ip.get_full_name
      @expr << "(define-fun #{@prefix}#{pip_name}C () Bool #{pip_name}_d)"
      @expr << "(define-fun #{@prefix}#{pip_name} ((t Int)) Bool (ite (< t 0) #{pip_name}_d #{pip_name}_a))"
      declare_input_constant(pip_name)
    end

    def visit_prim_output(op)
      source = op.get_source
      source_name = source.get_full_name
      @expr << "(define-fun #{@prefix}#{op.name} ((t Int)) Bool (#{@prefix}#{source_name} t))"
      source.accept(self)
    end

    # Modulariser cette méthode
    def visit_Gate g      
      return if visited?(g)

      sps = g.get_inputs.collect{|ip| ip.get_source} # gate output or primary input sources
      sp_names = sps.collect do |sg| 
        if sg.is_a?(Netlist::Gate) 
          @prefix + sg.get_output.get_full_name
        else 
          @prefix + sg.get_full_name
        end
      end

      prefixed_name = @prefix + g.get_output.get_full_name
      # write multiple cases (rise fall comb)
      @expr << risefallcomb_rec_fun(prefixed_name) 
      
      op_name = g.get_output.get_full_name
      ioarcs = g.get_inputs.collect do |ip|
        [ip.get_full_name, op_name]
      end

      # retrieve rise and fall delays for each ioarc
      rise_dlys = ioarcs.collect do |ioarc| 
        @delays.get_gate_dly(
          g, 
          ioarc, 
          :rise, 
          @sdf_col
        )
      end

      fall_dlys = ioarcs.collect do |ioarc| 
        @delays.get_gate_dly(
          g, 
          ioarc, 
          :fall, 
          @sdf_col
        )
      end

      # complete gate output expression with according delays for rise, fall and comb cases
      rise_expr = g.class::SMT_EXPR.dup
      rise_expr.map! do |w|
        if $SMT_KEYWORDS.include? w
          w
        else
          ip_index = w[1..].to_i
          # change delay fixing
          "(#{sp_names[ip_index]} (- t #{rise_dlys[ip_index]}))"
        end
      end

      fall_expr = g.class::SMT_EXPR.dup
      fall_expr.map! do |w|
        if $SMT_KEYWORDS.include? w
          w
        else
          ip_index = w[1..].to_i
          # change delay fixing
          "(#{sp_names[ip_index]} (- t #{fall_dlys[ip_index]}))"
        end
      end

      comb_expr = g.class::SMT_EXPR.dup
      comb_expr.map! do |w|
        if $SMT_KEYWORDS.include? w
          w
        else
          ip_index = w[1..].to_i
          # change delay fixing
          "#{sp_names[ip_index]}C"
        end
      end

      # store expressions
      @expr << rise_fun(prefixed_name, rise_expr.join(' '))
      @expr << fall_fun(prefixed_name, fall_expr.join(' '))
      @expr << comb_fun(prefixed_name, comb_expr.join(' '))
      
      # visit sources ports
      sps.each do |sp|
        sp.accept(self)
      end
    end

    def visit_Wire w
      return if visited?(w)

      prefixed_name = @prefix + w.name
      s = w.get_source
      sname = @prefix + s.get_full_name
      @expr << risefallcomb_rec_fun(prefixed_name) 
    
      rise_dly = @delays.get_wire_dly(w, :rise, @sdf_col)
      fall_dly = @delays.get_wire_dly(w, :fall, @sdf_col)

      rise_expr = "(#{sname} (- t #{rise_dly}))" 
      fall_expr = "(#{sname} (- t #{fall_dly}))"
      comb_expr = "#{sname}C"

      
      @expr << rise_fun(prefixed_name, rise_expr)
      @expr << fall_fun(prefixed_name, fall_expr)
      @expr << comb_fun(prefixed_name, comb_expr)

      s.accept(self)
    end

    private

    def risefallcomb_rec_fun signame
"(define-fun-rec #{signame} ((t Int)) Bool
  (ite (<= t 0)
    #{signame}C
    (ite (= (#{signame} (- t 1)) true)
      (#{signame}F t)
      (#{signame}R t)
    )
  )
)"
    end

    def rise_fun signame, rise_expr
"(define-fun #{signame}R ((t Int)) Bool 
  #{rise_expr}
)"
    end

    def fall_fun signame, fall_expr
"(define-fun #{signame}F ((t Int)) Bool 
  #{fall_expr}
)"  
    end

    def comb_fun signame, comb_expr
"(define-fun #{signame}C () Bool 
  #{comb_expr}
)"
    end
  end
end