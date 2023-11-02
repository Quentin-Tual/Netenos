require_relative "ht.rb"
require_relative "../netlist.rb"

module Netlist 
    attr_accessor :components

    class Cotd_s38417 < HT

        def initialize
            # * : For the moment the only parameters allowed are power of 2 numbers. This is faster to develop and easier for a start. It may evolve later to allow more possibilities.
            super
            @netlist = gen_netlist
        end

        def gen_netlist 
            gen_payload
            @payload_in <= gen_triggers
            @payload_in = @payload_in.partof.get_free_input
            return @payload_out.partof
        end

        def gen_triggers 
            new_gates = [Netlist::And2.new, Netlist::And2.new,Netlist::Nor2.new, Netlist::Nand2.new]
            new_gates.each do |g|
                @triggers << g.get_inputs
                @components << g
            end
            @triggers.flatten!

            new_gate = Netlist::And2.new
            new_gate.get_inputs[0] <= @triggers[0].partof.get_output
            new_gate.get_inputs[1] <= @triggers[2].partof.get_output
            @components << new_gate

            last_door = new_gate
            new_gate = Netlist::Nand2.new
            new_gate.get_inputs[0] <= last_door.get_output
            new_gate.get_inputs[1] <= @triggers[4].partof.get_output
            @components << new_gate

            last_door = new_gate
            new_gate = Netlist::Or2.new
            new_gate.get_inputs[0] <= last_door.get_output
            new_gate.get_inputs[1] <= @triggers[6].partof.get_output
            @components << new_gate
            
            last_door = new_gate
            new_gate = Netlist::Nor2.new
            new_gate.get_inputs[0] <= last_door.get_output
            @triggers << new_gate.get_inputs[1]
            @components << new_gate
            
            return new_gate.get_output
        end

        def gen_payload 
            generated_payload = Netlist::Xor2.new
            @components << generated_payload
            @payload_out = generated_payload.get_output
            @payload_in = generated_payload.get_inputs[1]
            return generated_payload
        end

    end

end