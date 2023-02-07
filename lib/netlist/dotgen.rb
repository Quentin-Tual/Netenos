module Netlist
    class DotGen
        attr_accessor :code

        def dot circuit, *path
            @code = Code.new()
            head circuit.name
            ios circuit.ports
            comp circuit.components
            wire circuit
            foot circuit.name path

        end

        def head name
            @code << "# Test"
            @code << "digraph #{name} {"
            @code.indent=2
            @code << "graph [rankdir = LR];"
        end

        def ios ports
            ports.each do |dir,ports|
                ports.each do |port|
                  @code << "#{port.name}[shape=cds,xlabel=\"#{port.name}\"]"
                end
            end
        end

        def comp components
            components.each do |comp|
                inputs=comp.inputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
                outputs=comp.outputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
                fanin="{#{inputs}}"
                fanout="{#{outputs}}"
                label="{#{fanin}| #{comp.name} |#{fanout}}"
                code << "#{comp.name}[shape=record; style=filled;color=cadetblue; label=\"#{label}\"]"
              end
        end

        def comp_wire components
            # Pour chaque composant
            # [nom composant]:[nom output composant] -> [nom composant associé]:[nom input composant associé]
            components.each do |comp|
                comp.outputs.each do |source|
                    source.fanout.each do |sink|
                        source_name = "#{comp.name}:#{source.name}"
                        if sink.partof.partof == nil
                            sink_name = "#{sink.name}"
                        else
                            sink_name = "#{sink.partof.name}:#{sink.name}"
                        end
                        @code << "#{source_name} -> #{sink_name};"
                    end
                end
            end
        end

        def wire circuit
            # Pour chaque port du Circuit global
            # [nom input circuit] -> [nom composant][nom input comp associé]
            circuit.inputs.each do |source|
                source.fanout.each do |sink|
                    if sink.partof.instance_of? Circuit
                        @code << "#{source.name} -> #{sink.name};"
                    else # Sink is a global circuit output
                        @code << "#{source.name} -> #{sink.partof.name}:#{sink.name};"
                    end
                end
            end

            comp_wire circuit.components
        end

        def foot circuit_name, path
            code.indent=0
            code << "}"
            # puts code.finalize # Debug print
            if path != []
                code.save_as "#{path[0]}", verbose=true
            else
                code.save_as "#{circuit_name}.dot",verbose=true
            end
        end
    end
    
end