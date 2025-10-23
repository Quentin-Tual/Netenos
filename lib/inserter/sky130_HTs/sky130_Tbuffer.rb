require_relative '../ht'

module Inserter
  class Sky130_Tbuffer < HT
    def initialize delay, scl
      super()
      @stdcell = "#{scl}__dlygate4sd1_1" # CHECK if ok  
      # Should act as a gate with a identity function
      @delay=delay
      @netlist = gen_netlist
    end

    def gen_netlist 
      # Create a class using json extracted from the PDK
      klassname = @stdcell.capitalize
      pdk = JSON.parse(File.read($PDK_JSON))
      klass = Netlist.create_pdk_class(klassname, pdk)
      # Instanciate the buffer 
      payload = klass.new("HTpayload")
      payload.propag_time = @delay
      # Set payload_out 
      @payload_out = payload.get_free_output
      # Set payload_in
      @payload_in = payload.get_free_input
      # Set components
      @components << payload
      # Set propag_time
      @propag_time = @delay
    end

  end
end
