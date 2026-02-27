module Delays
  
  class TimingAnalyzer < Netlist::BackwardUniqDFS
    attr_reader :timings

    def initialize nl, dly_db
      super(nl)
      @dly_db = dly_db
      @timings = Hash.new

      get_all_arcs.each do |ip|
        @timings[ip] = 0
      end
    end
    
    def [] sig
      @timings[sig]
    end

    def analyze 
      @nl.get_outputs.each do |op|
        op.accept(self)
      end
      @timings
    end

    def crit_path 
      @timings.max_by{|sig, val| val}
    end
    
    def visit_Wire w
      source_timing = super.to_i
      update_timing(w, source_timing)
      source_timing + @dly_db.wire_worst_dly(w)
    end

    def select_port_visit_meth p, primary_port, input_port
      case [primary_port, input_port]
      when [false, false] # sortie d'une porte (le + fréquent)
        visit_gate_output(p)
      when [true, true]   # entrée primaire (le 2eme + fréquent) 
        visit_prim_input(p)
      when [true, false]  # sortie primaire (...)
        visit_prim_output(p)
      when [false, true]  # entrée d'une porte
        visit_gate_input(p)
      else 
        raise "Error : unexpected #{p.inspect} encountered during the visit of #{@nl.name}"
      end
    end

    def visit_Port p
      return @timings[p] if visited?(p)
      print_obj_name(p) if $DEBUG

      primary_port = p.is_global?
      input_port = p.is_input?

      # Plusieurs cas selon que p est :
      #   - une sortie primaire 
      #   - la sortie d'une porte
      #   - l'entrée d'une porte ?
      #   - une entrée primaire
      select_port_visit_meth(p, primary_port, input_port).to_i
    end

    def visit_Gate g
      input_delays = g.get_inputs.collect{|ip| ip.accept(self)}
      gate_delay = @dly_db.gate_worst_dly(g)
      input_delays.max + gate_delay
    end

    private 

    def get_all_arcs
      @nl.get_inputs + \
      @nl.components.collect{|g| g.get_inputs}.flatten + \
      @nl.wires + \
      @nl.get_outputs
    end

    def update_timing obj, timing
      @timings[obj] = timing if @timings[obj] < timing
    end

    def visit_gate_input(ip) 
      update_timing(ip, ip.get_source.accept(self))
    end

    def visit_gate_output(op)
      super
    end

    def visit_prim_input(ip)
      update_timing(ip, 0)
    end

    def visit_prim_output(op)
      update_timing(op, super.to_i)
    end
  end
end
