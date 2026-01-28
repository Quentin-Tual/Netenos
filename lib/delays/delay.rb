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

  class SDFDelays < IntegerDelays
    # Object containing a hash associating each circuit component/gate or wire to a delay object   
    attr_reader :nl, :delays
    
    def initialize nl
      super(nl)
    end

    # Associates a dly to an object
    def add obj, dly
      @delays[obj] = dly
    end

    def only_one_values?
      @delays.values.all?{|v| v == 1}
    end

    def valid? 
      super and only_one_values? 
    end
  end
end