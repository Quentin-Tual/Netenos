module Netlist
  
  class GetDelaysVisitor < CircuitVisitor
    # Abstract class for all circuit exploration tasks
    
    def initialize delay_model, wire_delays: false
      @delay_model = delay_model
      @wire_delays = wire_delays
    end

    def raise_not_implemented
      raise "Error: Not implemented"
    end

    def visit_Circuit c
      @delays = @delay_model.new(c) 

      c.components.map{|g| g.accept(self)}
      c.wires.map{|w| w.accept(self)} if @wire_delays

      @delays
    end

    def visit_Gate g
      @delays.add g
    end

    def visit_Wire w
      @delays.add w
    end
  end

end