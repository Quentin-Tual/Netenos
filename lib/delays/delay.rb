module Delays

  # class ArcDelays
  #   # Object containing the delays for each arc in a gate

  #   def initialize g
  #     @g = g
  #     @delays = {}
  #   end

  #   def add sig
  #     raise "Not implemented for #{self.class.name} as it is an abstract class"
  #   end

  #   def p_in_g? p
  #     @g.get_inputs.include?(p)
  #   end

  #   def all_p_in_g? 
  #     @delays.all?{|p,dly| p_in_g?(p)}
  #   end

  #   def valid? 
  #     all_p_in_g?
  #   end
  # end

  class CircuitDelays
    # Abstract class, should not be instanciated

    def initialize nl
      @nl = nl
      @delays = {}
    end

    def add sig
      raise "Not implemented for #{self.class.name} as it is an abstract class"
    end

    def obj_in_nl? obj
      @nl.components.include?(obj) or @nl.wires.include?(obj)
    end

    def all_obj_in_nl? 
      @delays.all?{|obj,dly| obj_in_nl?(obj)}
    end

    def valid? 
      all_obj_in_nl?
    end
  end

  class IntegerDelays < CircuitDelays
    # Object containing a hash associating each circuit component/gate or wire to a delay object   
    attr_reader :nl, :delays

    def initialize nl
      super(nl)
    end

    def add obj, dly
      @delays[obj] = dly
    end

    def only_int_values?
      @delays.values.all?{|v| v.is_a? Integer}
    end

    def valid? 
      super and only_int_values?
    end
  end

  class OneUnitDelays < IntegerDelays
    # Object containing a hash associating each circuit component/gate or wire to a delay object   
    attr_reader :nl, :delays
    
    def initialize nl
      super(nl)
    end

    def add obj
      @delays[obj] = 1
    end

    def only_one_values?
      @delays.values.all?{|v| v == 1}
    end

    def valid? 
      super and only_one_values? 
    end
  end

  class MinTypMaxDelay
    attr_reader :min, :typ, :max

    def initialize min, typ, max # Expecting Integers
      @min = min
      @typ = typ
      @max = max
    end
  end

  class RiseFallDelay
    attr_reader :rise_dly, :fall_dly

    def initialize rise_dly, fall_dly # Expecting MinTypMaxDelay
      @rise_dly = rise_dly
      @fall_dly = fall_dly
    end

    def rise 
      rise_dly
    end

    def fall
      fall_dly
    end

    def max 
      [@rise_dly.max, @fall_dly.max].max
    end

    def min 
      [@rise_dly.min, @fall_dly.min].min
    end
  end

  class ArcDelays 
    attr_reader :arcs

    def initialize *io_dly # Expecting [[i,o,dly],...] with dly a RiseFallDelay
      @arcs = io_dly.each_with_object(Hash.new) do |(i,o, dly), h|
        h[i] = {o => dly} # !!! Considering the gate has only one output
      end
    end

    def ioarc_dly(ip_name, op_name)
      @arcs[ip_name][op_name]
    end

    def max 
      @arcs.values.collect do |subh| 
        subh.values.first.max
      end.flatten.max
    end

    def min
      @arcs.values.collect do |subh| 
        subh.values.first.min
      end.flatten.min
    end
  end

  class SDFDelays < CircuitDelays
    # Object containing a hash associating each circuit component/gate or wire to a delay object   
    attr_reader :nl, :delays, :sdf_filepath
    
    def initialize nl, sdf_filepath
      super(nl)
      @sdf_filepath = sdf_filepath
    end

    # Associates a dly to an object
    def add obj, dly # Expecting a ArcDelays
      @delays[obj] = dly
    end

    def get_wire_dly(w, transi, col)
      @delays[w].send(transi).send(col)
    end

    def get_gate_dly(g, ioarc, transi, col)
      @delays[g].ioarc_dly(*ioarc).send(transi).send(col)
    end

    def wire_worst_dly(w)
      @delays[w].max  
    end

    def gate_worst_dly(g)
      @delays[g].max
    end

    def gate_min_dly(g)
      @delays[g].min
    end

    def create_add obj, dly_val
      if obj.is_a? Netlist::Gate
        io_dlys = obj.get_inputs.collect do |ip|
          [ ip.get_full_name, 
            obj.get_output.get_full_name,
            RiseFallDelay.new(
              MinTypMaxDelay.new(dly_val,dly_val,dly_val),
              MinTypMaxDelay.new(dly_val,dly_val,dly_val)
            )]
        end
        add(obj, ArcDelays.new(*io_dlys))
      elsif obj.instance_of? Netlist::Wire
        rf_dly = RiseFallDelay.new(
          MinTypMaxDelay.new(dly_val,dly_val,dly_val),
          MinTypMaxDelay.new(dly_val,dly_val,dly_val)
        )
        add(obj, rf_dly)
      else
        raise "Error: Unexpected class #{obj.class} encountered for #{obj.name}"
      end
    end 

    def valid? 
      super #and only_one_values? 
    end
  end
end