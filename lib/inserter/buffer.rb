require_relative "ht.rb"

module Inserter

    class Buf < HT

        def initialize ht_delay = 2
            super()
            payload = Netlist::Buffer.new(propag_time: ht_delay)
            @netlist = payload
            @components = [payload]
            @payload_in = payload.get_inputs[0]
            @payload_out = payload.get_outputs[0]
        end

    end

end