require_relative "../netlist.rb"
require_relative "invertedGates.rb"

module Reverse

    class EventFifo
        # TODO : See if necessary to manage events with associations or stuff
        def initialize 
            @events = []
        end

        def push e
            @events.push(e) 
        end
        
        def pop e 
            @events.shift(e)
        end
    end

    class Junction # ? Déplacer dans le ficheir invertedGates.rb ?
        def initialize source, sink_a, sink_b
            @source = source

            @sinks = []
        end

        def update
            # TODO : As all updates but we have to check if constraints are satisfied here
        end
    end

    class InvertedCircuit 

        def initialize circuit
            @relation_tab = Hash.new([])
            @inverted_circuit = convert(circuit)
        end

        # * Convert initial netlist to an inverted format
        def convert circuit
            @inverted_circuit = Netlist::Circuit.new(circuit.name)
            scan_relations(circuit)
            instanciate(circuit)
            apply_connections
        end

        def scan_relations circuit
            circuit.get_outputs.each do |output|
                @relation_tab[output.name] = [output.get_source.get_full_name]
            end

            circuit.components.each do |comp|
                comp.get_outputs.each do |output|
                    @relation_tab[output.get_full_name] += comp.get_source_gates.collect do |sink_gate| 
                        if sink_gate.is_a? Netlist::Gate
                            "#{sink_gate.name}_o0"
                        else 
                            sink_gate.name
                        end
                    end
                end
            end

            # ! Wire not taken into account, WIP
            if !circuit.wires.empty?
                raise "Error : Wires are not taken into account in the inverted netlist."
            end
        end

        def instanciate circuit

            circuit.get_inputs.each do |input|
                @inverted_circuit << Netlist::Port.new(input.name, :out)
            end

            circuit.get_outputs.each do |output|
                @inverted_circuit << Netlist::Port.new(output.name, :in)
            end

            circuit.components.each do |component|
                case component
                when Netlist::And2
                    @inverted_circuit << InvertedAnd2.new(component.name)
                when Netlist::Or2
                    @inverted_circuit << InvertedOr2.new(component.name)
                when Netlist::Xor2
                    @inverted_circuit << InvertedXor2.new(component.name)
                when Netlist::Nand2
                    @inverted_circuit << InvertedNand2.new(component.name)
                when Netlist::Nor2
                    @inverted_circuit << InvertedNor2.new(component.name)
                when Netlist::Not
                    @inverted_circuit << InvertedNot.new(component.name)
                when Netlist::Buffer
                    @inverted_circuit << InvertedBuffer.new(component.name)
                else
                    raise "Error : Unknown component -> Integration of #{component.class.name} into #{self.class.name} is not allowed."
                end
            end
        end

        def apply_connections 
            @relation_tab.each do |signal, sources|
                if signal.include?($FULL_PORT_NAME_SEP)
                    connect_component(signal, sources) # * : signal is a component output
                elsif signal[0] == "o"
                    connect_primary_output(signal, sources) # * : signal is a primary output
                else 
                    raise "Error : Unexpected signal -> Connection of #{signal} to #{sources} impossible."
                end
            end
        end
       
        def connect_component signal, sources
            sink = @inverted_circuit.get_component_named(signal.split($FULL_PORT_NAME_SEP)[0])
            sources = sources.collect do |source|
                if sources.include?($FULL_PORT_NAME_SEP)
                    @inverted_circuit.get_component_named(source)
                else
                    @inverted_circuit.get_port_named(source)
                end 
            end

            sources.each do |source|
                sink <= source
            end
        end


        def connect_primary_output signal, sources
            sink = @inverted_circuit.get_port_named(signal)
                    
            if sources.length > 1
                raise "Error : Multiple sources for a primary output."
            end
            
            if sources[0].include? $FULL_PORT_NAME_SEP
                source = @inverted_circuit.get_component_named(sources[0].split($FULL_PORT_NAME_SEP)[0])
            else
                source = @inverted_circuit.get_port_named(sources[0])
            end

            sink <= source
        end

        def update
            # TODO : Launch update on all the outputs (inputs of the inverted netlist)
        end

    end

end