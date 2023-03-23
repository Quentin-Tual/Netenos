require 'json'
require_relative "../netlist.rb"

module Netlist
    class Netson

        def initialize
            @sym_tab = {}
        end

        def load file 
            h = JSON.parse(File.read("#{file}")) # gives hash version of the JSON data parsed
            json_to_netlist h
            return @circuit
        end

        def json_to_netlist h
            inst_global_circ h
            wiring 
        end

        def find_port port_name
            port_name, comp_name = port_name.split(":")

            if comp_name == nil 
                return @circuit.get_port_named(port_name)
            else # TODO : Instancier le Wire 
                return @circuit.get_component_named(comp_name).get_port_named(port_name)
            end
        end

        def wiring
            puts "Components Wiring ..."

            # ! : WIP 

            # @circuit.get_inputs.each{ |e| 
            #     if e.get_sinks.class != String # Then it is a Wire class expected
            #         # TODO : Instancier le Wire 
            #         tmp = Wire.new
            #         tmp.name = e.fanout["data"]["name"]
                    
            #         # TODO : Effectuer les prochaines liaisons (sûrement généralisable -> fonction)
            #         e.fanout["data"]["pluggedInputs"].each{|p| 
            #             tmp <= find_port(p)
            #         }
            #         e = tmp
            #     else # else it is a Port class expected
            #     # break if p.class != String
            #         if !e.nil?
            #             e <= find_port(e.fanout)
            #         end
            #     end
                
            #     # e.fanout.delete_if{ |p| p.class == String}
            # }

            # @circuit.components.each{ |comp| 
            #     # TODO : Mettre à niveau pour l'ajout des Wire et la restructuration du code
            #     comp.outputs.each{ |e|
            #         # * : Devenu un Wire ou un Port mais un seul élément
            #         if e.fanout.class != String

            #             tmp = Wire.new
            #             tmp.name = e.fanout["data"]["name"]
            #             e.fanout["data"]["pluggedInputs"].each{|p| 
            #                 tmp <= find_port(p)
            #             }
            #             e.fanout = tmp
            #         else
            #             e <= find_port(e.fanout) 
            #         end
            #     }
            # }
        end

        def inst_global_circ h
            @circuit = Circuit.new(h["data"]["name"])
            @circuit.partof = h["data"]["partof"]
            @circuit.components = h["data"]["components"].collect!{|e| inst_comp(e, @circuit)}
            @circuit.ports[:in] = h["data"]["ports"]["in"].collect!{|e| inst_port(e, @circuit)}
            @circuit.ports[:out] = h["data"]["ports"]["out"].collect!{|e| inst_port(e, @circuit)}
        end

        def inst_comp h, parent
            comp = Circuit.new(h["data"]["name"])
            comp.partof = parent
            comp.components = h["data"]["components"].collect!{|e| inst_comp(e,comp)}
            comp.ports[:in] = h["data"]["ports"]["in"].collect!{|e| inst_port(e, comp)}
            comp.ports[:out] = h["data"]["ports"]["out"].collect!{|e| inst_port(e, comp)}
            return comp
        end

        def inst_port h, parent
            port = Port.new(h["data"]["name"].split(':')[0], h["data"]["direction"].to_sym)
            port.partof = parent
            @sym_tab["#{port.partof.name}:#{port.name}"] = port
            port.fanin = h["data"]["fanin"]
            h["data"]["fanin"]["class"] == "Netlist::Wire" ? inst_wire(h["data"]["fanin"]) : h["data"]["fanin"]
            h["data"]["fanout"].collect!{|sink| sink["class"] == "Netlist::Wire" ? inst_wire(sink) : sink}
            return port
        end

        def inst_wire h
            wire = Wire.new(h["data"]["name"])
            wire.fanin = h["data"]["fanin"]
            wire.fanout = h["data"]["fanout"]
            return wire
        end
        # def inst_custom_circ h, parent

        # end

        # ? : Un objet Wire fait-il partie d'un composant/circuit, parfois des fils dans les composants, rapprochement avec les "fractales", ajouter un champ "partof" ? Utile ?
        # def inst_wires h, pluggedOutput

        # end        

        # Add components name to port name to ensure the back conversion from JSON to netlist format.  
        def prep_port_names circuit 
            circuit.components.each{ |comp|
                comp.get_ports.each{ |port| 
                    port.name = port.name + ":" + comp.name
                }
            }
        end

        def save_as_json circuit, *path
            if path == []
                file = File.new("#{circuit.name}.json", "w")
            else
                file = File.new("#{path[0]}", "w")
            end
            prep_port_names circuit
            file.puts(JSON.pretty_generate(circuit.to_hash))
            file.close
        end

    end
end