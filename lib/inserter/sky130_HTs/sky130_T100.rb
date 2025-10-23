require_relative '../ht'

module Inserter
  class Sky130_T100
    def initialize nb_trigger = 4
      super 
      @netlist = gen_netlist(nb_trigger)
      
      raise "WIP"
    end

    def gen_netlist nb_trigger
      gen_payload
      
      # ...
    end

    def gen_payload
      
    end
    
    def gen_triggers nb_trigger
      
    end

  end
end
