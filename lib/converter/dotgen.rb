module Converter
    class DotGen
        attr_accessor :code

        def dot circuit, path = nil, delay_model = :int_multi
            @code = Code.new()
            @sym_tab = {}
            head circuit.name
            comp circuit.components, delay_model
            ios circuit.ports
            wiring circuit
            circuit.components.each{|comp| comp_wiring(comp)}
            return foot circuit.name, path
        end

        def head name
            # @code << "# Test"
            @code << "digraph #{name} {"
            @code.indent=2
            @code << "graph [rankdir = LR];"
        end

        def ios ports
            ports.each do |dir,ports|
                ports.each do |port|
                  @code << "#{port.name}[shape=cds,xlabel=\"#{port.name}\"]"
                  @sym_tab[port.name] = Netlist::Port
                end
            end
        end

        def comp components, delay_model
            components.each do |comp|
                inputs=comp.get_inputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
                outputs=comp.get_outputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
                fanin="{#{inputs}}"
                fanout="{#{outputs}}"
                label="{#{fanin}|{#{comp.name}|{#{comp.propag_time[delay_model]}|#{comp.cumulated_propag_time.to_s}}}|#{fanout}}"
                if comp.tag == :ht
                    color = "orange1"
                elsif comp.tag == :target_path
                    color = "red"
                else
                    color = "cadetblue"
                end
                code << "#{comp.name}[shape=record; style=\"rounded,filled\"; fillcolor=#{color}; label=\"#{label}\"]"
                @sym_tab[comp.name] = Netlist::Circuit
            end
        end

        def wiring circuit
            circuit.get_inputs.each{ |source|
                source.get_sinks.each{ |sink|
                    if sink.class == Netlist::Wire
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
                    if sink.class == Netlist::Wire
                        wire sink, source
                    else
                        write_wiring source, sink
                    end
                }
            }
        end

        def wire w, source
            # wireName = "w#{source.get_dot_name}"
            @code << "#{w.get_dot_name}[shape=point];"
            @code << "#{source.get_dot_name} -> #{w.get_dot_name}[arrowhead=none]"
            w.get_sinks.each{|sink|
                write_wiring w, sink
            }
        end

        def write_wiring source, sink
            @code << "#{source.get_dot_name} -> #{sink.get_dot_name};"
        end

        def foot circuit_name, path
            code.indent=0
            code << "}"
            # puts code.finalize # Debug print
            if path != nil
                code.save_as "#{path}",false,true
                if $VERBOSE
                    puts "[+] Schematic generated : \'#{path}\'"
                end
                return "#{path}"
            else
                code.save_as "#{circuit_name}.dot",false,true
                if $VERBOSE
                    puts "[+] Schematic generated : \'#{circuit_name}.dot\'"
                end
                return "#{circuit_name}.dot"
            end
        end
    end
    
end