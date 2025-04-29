require_relative "ht.rb"

module Inserter

    class Buf < HT
        attr_accessor :components # DEBUG

        def initialize ht_delay = 2
            # * : For the moment the only parameters allowed are power of 2 numbers. This is faster to develop and easier for a start. It may evolve later to allow more possibilities.
            super
            payload = Netlist::Buffer.new(ht_delay)
            @netlist = payload
            @components = [payload]
            @payload_in = payload.get_inputs[0]
            @payload_out = payload.get_outputs[0]
        end

    end

end