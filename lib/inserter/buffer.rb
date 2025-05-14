require_relative "ht.rb"

module Inserter

    class Buf < HT
        attr_accessor :components # DEBUG

        def initialize ht_delay = 2
            super
            payload = Netlist::Buffer.new
            @netlist = payload
            @components = [payload]
            @payload_in = payload.get_inputs[0]
            @payload_out = payload.get_outputs[0]
        end

    end

end