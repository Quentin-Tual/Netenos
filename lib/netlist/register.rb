require_relative 'port.rb'
module Netlist
    class Register < Circuit

        def initialize name = "reg_#{self.object_id}", source = nil, sinks = [], partof = nil
            super name, partof
            @ports[:in] = [Netlist::Port.new('d', :in, self)]
            @ports[:in][0].fanin = source
            @ports[:out] = [Netlist::Port.new('q', :out, self)]
            @ports[:out][0].fanout = sinks
        end

    end
end