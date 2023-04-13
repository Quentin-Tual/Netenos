module Netlist
    class DotGen
        attr_accessor :code

        def dot circuit, *path
            @code = Code.new()
            @sym_tab = {}
            head circuit.name
            comp circuit.components
            ios circuit.ports
            wiring circuit
            circuit.components.each{|comp| comp_wiring comp }
            foot circuit.name, path
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
                  @sym_tab[port.name] = Port
                end
            end
        end

        def comp components
            components.each do |comp|
                inputs=comp.get_inputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
                outputs=comp.get_outputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
                fanin="{#{inputs}}"
                fanout="{#{outputs}}"
                label="{#{fanin}| #{comp.name} |#{fanout}}"
                code << "#{comp.name}[shape=record; style=filled;color=cadetblue; label=\"#{label}\"]"
                @sym_tab[comp.name] = Circuit
            end
        end

        def wiring circuit
            circuit.get_inputs.each{ |source|
                source.get_sinks.each{ |sink|
                    if sink.class == Wire
                        wire sink, source
                    else
                        write_wiring source, sink
                    end
                }
            }
        end
        
        def comp_wiring comp
            comp.get_outputs.each{ |source|
                source.get_sinks.each{ |sink|
                    if sink.class == Wire
                        wire sink, source
                    else
                        write_wiring source, sink
                    end
                }
            }
        end

        def wire w, source
            # wireName = "w#{source.get_full_name}"
            @code << "#{w.get_full_name}[shape=point];"
            @code << "#{source.get_full_name} -> #{w.get_full_name}[arrowhead=none]"
            w.get_sinks.each{|sink|
                write_wiring w, sink
            }
        end

        def write_wiring source, sink
            @code << "#{source.get_full_name} -> #{sink.get_full_name};"
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