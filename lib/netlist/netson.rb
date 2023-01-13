module Netlist
    class Netson
        def load file 
            h = JSON.parse(File.read("#{file}")) # gives hash version of the JSON data parsed
            circuit = json_to_netlist h
            
        end

        def json_to_netlist h
            return components_wiring components_instanciation h
        end

        def find_port port_name, circuit
            port_name, comp_name = port_name.split(":")

            if comp_name == nil 
                return circuit.get_port_named(port_name)
            else 
                return circuit.get_component_named(comp_name).get_port_named(port_name)
            end
        end

        def components_wiring circuit
            puts "Components Wiring ..."
            circuit.inputs.each{ |e| 
                e.fanout.each{ |p|
                    break if p.class != String
                    e <= find_port(p, circuit)
                }
                e.fanout.delete_if{ |p| p.class == String}
            }

            circuit.components.each{ |comp| 
                comp.outputs.each{ |e|
                    e.fanout.each{ |p|
                        break if p.class != String
                        e <= find_port(p, circuit)
                    }
                    e.fanout.delete_if{ |e| e.class == String}
                }
            }
            return circuit
        end

        def components_instanciation h, *parent
            case h["class"]
            when "Netlist::Circuit"
                circuit = Circuit.new(h["data"]["name"])
                circuit.partof = h["data"]["partof"]
                circuit.components = h["data"]["components"].collect!{|e| components_instanciation(e,circuit)}
                circuit.ports[:in] = h["data"]["ports"]["in"].collect!{|e| components_instanciation(e, circuit)}
                circuit.ports[:out] = h["data"]["ports"]["out"].collect!{|e| components_instanciation(e, circuit)}
                return circuit
            when "Netlist::Port"
                port = Port.new(h["data"]["name"], h["data"]["direction"].to_sym)
                port.partof = parent[0]
                port.fanin = h["data"]["fanin"]
                port.fanout = h["data"]["fanout"] == nil ? [] : h["data"]["fanout"]
                return port
            when "A"
                a = A.new(h["data"]["name"])
                a.partof = parent[0]
                a.components = h["data"]["components"].collect!{|e| components_instanciation(e,a)}
                tmp = a.ports[:in].zip(h["data"]["ports"]["in"])
                tmp.each{|a_p, h_p| a_p.fanin = h_p["data"]["fanin"]}
                tmp = a.ports[:out].zip(h["data"]["ports"]["out"])
                tmp.each{|a_p, h_p| a_p.fanout = h_p["data"]["fanout"]}
                return a
            when "B" 
                b = B.new(h["data"]["name"])
                b.partof = parent[0]
                b.components = h["data"]["components"].collect!{|e| components_instanciation(e,b)}
                tmp = b.ports[:in].zip(h["data"]["ports"]["in"])
                tmp.each{|b_p, h_p| b_p.fanin = h_p["data"]["fanin"]}
                tmp = b.ports[:out].zip(h["data"]["ports"]["out"])
                tmp.each{|b_p, h_p| b_p.fanout = h_p["data"]["fanout"]}
                return b
            when "C"
                c = C.new(h["data"]["name"])
                c.partof = parent[0]
                c.components = h["data"]["components"].collect!{|e| components_instanciation(e,c)}
                tmp = c.ports[:in].zip(h["data"]["ports"]["in"])
                tmp.each{|c_p, h_p| c_p.fanin = h_p["data"]["fanin"]}
                tmp = c.ports[:out].zip(h["data"]["ports"]["out"])
                tmp.each{|c_p, h_p| c_p.fanout = h_p["data"]["fanout"]}
                return c
            else 
                raise "Error : Unknown class #{h["class"]} encountered."
            end
        end

        # Add components name to port name to ensure the back conversion from JSON to netlist format.  
        def prep_port_names circuit 
            circuit.components.each{ |comp|
                comp.inputs.each{ |port| 
                    port.name = port.name + ":" + comp.name
                }
                # comp.ports.values.each{ |port|
                #     port.name = comp.name + ":" + port.name
                # }
            }
        end

        def save_as_json circuit
            file = File.new("#{circuit.name}.json", "w")
            prep_port_names circuit
            file.puts(JSON.pretty_generate(circuit.to_hash))
            file.close
        end

    end
end