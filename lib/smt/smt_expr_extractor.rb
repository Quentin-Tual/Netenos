module SMT
  class SMTExprExtractor < Netlist::BackwardUniqDFS
    attr_reader :expr

    def initialize nl, delays, sdf_col: :typ, inserted_gates: [], write_constants: true, crit_path_delay: nil, smt_format: :rec
      super(nl)
      @delays = delays
      @gate_min_dly = @nl.get_comp_min_delay(:sdf, dly_db: @delays)
      @sdf_col = sdf_col
      @src = []
      @expr = []
      add_all_nl_inputs_constants if write_constants
      @prefix = nl.name + '/'
      @inserted_gates = inserted_gates
      @write_constants = write_constants
      @transition_instant = 0
      @upper_bound = crit_path_delay
      @smt_format = smt_format
    end

    def save_as path 
      File.write(path, print, mode: 'a')
    end

    def print 
      @expr.join("\n") + "\n"
    end

    def visit_Port p
      super
    end

    def visit_Gate g
      super # unless @inserted_gates.include?(g)

      sp_names = get_source_port_names(g)
      ioarcs = get_ioarcs(g)
      
      # retrieve rise and fall delays for each ioarc
      rise_dlys, fall_dlys = get_rise_fall_dlys(g, ioarcs)

      # complete gate output expression with according delays for rise, fall and comb cases
      rise_expr = risefall_expr(g, sp_names, rise_dlys)
      fall_expr = risefall_expr(g, sp_names, fall_dlys)
      comb_expr = comb_expr(g,sp_names)

      prefixed_name = @prefix + g.get_output.get_full_name
      
      # store expressions
      @expr << rise_fun(prefixed_name, rise_expr.join(' '))
      @expr << fall_fun(prefixed_name, fall_expr.join(' '))
      @expr << comb_fun(prefixed_name, comb_expr.join(' '))
      @expr << zerod_fun(prefixed_name, nodly_expr(g, sp_names).join(' '))
      if @smt_format == :simple
        max_rise_dly = rise_dlys.max
        max_fall_dly = fall_dlys.max
        @expr << risefallcomb_fun(prefixed_name, [max_rise_dly, max_fall_dly]) 
      else
        @expr << risefallcomb_fun(prefixed_name) 
      end
    end

    def visit_Wire w
      super

      prefixed_name = @prefix + w.name
      s = w.get_source
      sname = @prefix + s.get_full_name

      rise_dly = @delays.get_wire_dly(w, :rise, @sdf_col)
      fall_dly = @delays.get_wire_dly(w, :fall, @sdf_col)

      comb_expr = "#{sname}C"
      zerod_expr = "(#{sname} t)"

      if (rise_dly == fall_dly) and (fall_dly == 0)
        @expr << comb_fun(prefixed_name, comb_expr)
        @expr << zerod_fun(prefixed_name, zerod_expr)
        @expr << wire_nodly_fun(prefixed_name)
      else
        rise_expr = "(#{sname} (- t #{rise_dly}))"
        fall_expr = "(#{sname} (- t #{fall_dly}))"
        @expr << rise_fun(prefixed_name, rise_expr)
        @expr << fall_fun(prefixed_name, fall_expr)
        @expr << comb_fun(prefixed_name, comb_expr)
        @expr << zerod_fun(prefixed_name, zerod_expr)
        if @smt_format == :simple
          @expr << risefallcomb_fun(prefixed_name, [rise_dly, fall_dly])
        else
          @expr << risefallcomb_fun(prefixed_name) 
        end
      end
    end

    private

    def add_all_nl_inputs_constants
      @nl.get_inputs.each do |ip|
        ip_name = ip.get_full_name
        declare_input_constant(ip_name)
      end
    end

    def visit_gate_output(op)
      super
    end

    def declare_input_constant(name)
      @expr << "(declare-const #{name}_d Bool)"
      @expr << "(declare-const #{name}_a Bool)"
    end 

    def visit_prim_input(ip)
      pip_name = ip.get_full_name
      # declare_input_constant(pip_name) if @write_constants
      @expr << "(define-fun #{@prefix}#{pip_name} ((t Int)) Bool (ite (< t 0) #{pip_name}_d #{pip_name}_a))"
      @expr << "(define-fun #{@prefix}#{pip_name}C () Bool #{pip_name}_d)"
    end

    def visit_prim_output(op)
      super

      source = op.get_source
      source_name = source.get_full_name
      @expr << "(define-fun #{@prefix}#{op.name} ((t Int)) Bool (#{@prefix}#{source_name} t))"
    end

    def get_source_port_names g
      source_ports = g.get_inputs.collect{|ip| ip.get_source} # gate output or primary input sources
      source_ports.collect do |sg| 
        if sg.is_a?(Netlist::Gate) 
          @prefix + sg.get_output.get_full_name
        else 
          @prefix + sg.get_full_name
        end
      end
    end

    def get_ioarcs(g)
      g.get_inputs.collect do |ip|
        [ip.get_full_name, g.get_output.get_full_name]
      end
    end

    def get_rise_fall_dlys(g, ioarcs)
      [:rise,:fall].collect do |transi|
        ioarcs.collect do |ioarc| 
          @delays.get_gate_dly(
            g, 
            ioarc, 
            transi, 
            @sdf_col
          )
        end
      end
    end

    def risefall_expr g, sp_names, risefall_dlys
      expr = g.class::SMT_EXPR.dup
      expr.map! do |w|
        if $SMT_KEYWORDS.include? w
          w
        else
          ip_index = w[1..].to_i
          # change delay fixing
          "(#{sp_names[ip_index]} (- t #{risefall_dlys[ip_index]}))"
        end
      end
    end

    def comb_expr g, sp_names
      expr = g.class::SMT_EXPR.dup
      expr.map! do |w|
        if $SMT_KEYWORDS.include? w
          w
        else
          ip_index = w[1..].to_i
          # change delay fixing
          "#{sp_names[ip_index]}C"
        end
      end
    end

    def nodly_expr g, sp_names
      expr = g.class::SMT_EXPR.dup
      expr.map! do |w|
        if $SMT_KEYWORDS.include? w
          w
        else
          ip_index = w[1..].to_i
          # change delay fixing
          "(#{sp_names[ip_index]} t)"
        end
      end
    end

    def risefallcomb_fun signame, params=nil
      case @smt_format
      when :rec
        risefallcomb_rec_fun(signame)
      when :arrays
        risefallcomb_array_assert_fun(signame)
      when :simple
        risefallcomb_simple_fun(signame, *params)
      when :pure
        risefallcomb_pure_fun(signame)
      else
        risefallcomb_simple_fun(signame, *params)
      end
    end

    def risefallcomb_pure_fun signame
"(define-fun #{signame} ((t Int)) Bool
  (ite (<= t 0)
    #{signame}C
    (ite (not (#{signame}0D t))
      (#{signame}F t)
      (#{signame}R t)
    )
  )
)"
    end

    def risefallcomb_rec_fun signame
"(define-fun-rec #{signame} ((t Int)) Bool
  (ite (<= t 0)
    #{signame}C
    (ite (not (or (#{signame}0D t) (#{signame}F t) ))
      false
      (ite (and (#{signame}0D t) (#{signame}R t) )
        true
        (#{signame} (- t #{@gate_min_dly})) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)"
    end

    # INACCURATE AND WRONG 
    def risefallcomb_simple_fun signame, max_rise_delay, max_fall_delay
"(define-fun #{signame} ((t Int)) Bool
  (ite (<= t 0)
    #{signame}C
    (ite (#{signame}0D t)
      (ite (#{signame}R t)
        true
        (#{signame}R (- t #{max_rise_delay}))
      )
      (ite (not (#{signame}F t))
        false
        (#{signame}F (- t #{max_fall_delay}))
      )
    )
  )
)"
    end

    # DOES NOT SPEED UP THE PROCESS
    def risefallcomb_array_assert_fun signame
"(declare-const #{signame}_arr (Array Int Bool))
(assert (= (select #{signame}_arr #{@transition_instant}) #{signame}C))
(assert (forall ((t Int))
  (=> (and (> t #{@transition_instant}) (< t #{@upper_bound}))
    (ite (not (or (#{signame}0D t) (#{signame}F t)))
      (= (select #{signame}_arr t) false)
      (ite (and (#{signame}0D t) (#{signame}R t))
        (= (select #{signame}_arr t) true)
        (= (select #{signame}_arr t) (select #{signame}_arr (- t #{@gate_min_dly})))
      )
    )
  )
))
(define-fun #{signame} ((t Int)) Bool 
  (select #{signame}_arr t)
)"
    end

    def wire_nodly_fun signame
"(define-fun #{signame} ((t Int)) Bool
  (#{signame}0D t)
)"
    end

    def zerod_fun signame, nodly_expr
"(define-fun #{signame}0D ((t Int)) Bool
  #{nodly_expr}
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