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
            puts "Components Wiring ..."
            wiring_global
            @circuit.components.each{|comp| wiring_component comp}
        end

        def find_port port_name
            port_name, comp_name = port_name.split(":")
            if comp_name == nil 
                return @circuit.get_port_named(port_name)
            else
                return @circuit.get_component_named(comp_name).get_port_named(port_name)
            end
        end

        def wiring_global
            @circuit.get_inputs.each do |global_input|
                wiring_port global_input
            end 
        end

        def wiring_component comp
            comp.get_outputs.each do |source|
                wiring_port source
            end 
        end

        def wiring_port source
            source.get_sinks.each do |sink|
                if sink.class == Netlist::Wire
                    wiring_wire sink
                else
                    # Le fanin du sink aura déjà une valeur donc erreur si on ne le libère par de la référence String 
                    plug source, sink
                end
            end
            # Supprimer les réf par String
            source.fanout.delete_if{|sink| sink.is_a? String}
        end

        def wiring_wire w 
            # * : Links the passed Wire fanout to referenced interfaces. 
            w.get_sinks.each do |sink|
                # Le fanin du sink aura déjà une valeur donc erreur si on ne le libère par de la référence String 
                plug w, sink
            end
            # Supprimer les réf par String
            w.fanout.delete_if{|sink| sink.is_a? String} 
        end

        def plug source, sink
            # Certaines références sont déjà traitées
            if !sink.is_a? Port
                @sym_tab[sink].fanin = nil
                @sym_tab[sink] <= source
            end
        end

        def inst_global_circ h
            @circuit = Circuit.new(h["circuit"]["name"])
            @circuit.partof = h["circuit"]["partof"]
            @circuit.components = h["circuit"]["components"].collect{|e| inst_comp(e, @circuit)}
            @circuit.ports[:in] = h["circuit"]["ports"]["in"].collect{|e| inst_port(e, @circuit)}
            @circuit.ports[:out] = h["circuit"]["ports"]["out"].collect{|e| inst_port(e, @circuit)}
        end

        def inst_comp h, parent
            comp = Circuit.new(h["circuit"]["name"])
            comp.partof = parent
            comp.components = h["circuit"]["components"].collect{|e| inst_comp(e,comp)}
            comp.ports[:in] = h["circuit"]["ports"]["in"].collect{|e| inst_port(e, comp)}
            comp.ports[:out] = h["circuit"]["ports"]["out"].collect{|e| inst_port(e, comp)}
            return comp
        end

        def inst_port h, parent
            port = Port.new(h["port"]["name"].split(':')[0], h["port"]["direction"].to_sym)
            port.partof = parent
            if port.is_global?
                @sym_tab["#{port.name}"] = port
            else
                @sym_tab["#{port.name}:#{port.partof.name}"] = port
            end
            port.fanin = h["port"]["fanin"].is_a?(Hash) ? inst_wire(h["port"]["fanin"]) : h["port"]["fanin"]
            port.fanout = (h["port"]["fanout"] == nil ? [] : (h["port"]["fanout"].collect{|sink| sink.is_a?(Hash) ? inst_wire(sink) : sink}))
            return port
        end

        def inst_wire h
            wire = Wire.new(h["wire"]["name"])
            @sym_tab["#{wire.name}"] = wire
            wire.fanin = h["wire"]["fanin"]
            wire.fanout = h["wire"]["fanout"]
            return wire
        end  

        # Add components name to port name to ensure the back conversion from JSON to netlist format.  
        def prep_port_names circuit 
            circuit.components.each{ |comp|
                comp.get_ports.each{ |port| 
                    port.name = port.name + ":" + comp.name
                }
            }
        end

        def save_as_json circuit, path = "#{circuit.name}.json"
            file = File.new("#{path}", "w")
            prep_port_names circuit
            file.puts(JSON.pretty_generate(circuit.to_hash))
            file.close
        end

    end
end