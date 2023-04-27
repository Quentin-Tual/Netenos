require_relative "../netlist.rb"

module Netlist

    class ConvNetlist2Matrix 
        attr_reader :id_tab

        # ! : Ajouter une suppression des doublons

        def initialize netlist = nil
            @netlist = netlist
            @id_tab = {}
            @matrix = [] # * : Will be a 2dim array accessed as @matrix[source_index][sink_index]. Represents a directed acyclic graph.  
            @index = 0
            @wires = {}
        end

        def start
            scanNetlist
            convNetlist
        end

        def scanGlobalInputs
            @netlist.get_inputs.each do |ginp|
                @id_tab[ginp.name] = @index
                @index += 1
            end
        end

        def scanComponents
            @netlist.components.each do |comp|
                @id_tab[comp.name] = @index
                @index += 1
            end
        end

        def scanGlobalOutputs
            @netlist.get_outputs.each do |goutp|
                @id_tab[goutp.name] = @index
                @index += 1
            end
        end

        def scanWires
            @netlist.wires.each do |w|
                @wires[w.name] = w.get_sinks.collect{|sink| sink.get_full_name.split['_'][0]} # ! : could be a global output so reuse this function, however certainly optimisable 
            end
        end

        def scanNetlist
            scanGlobalInputs
            scanComponents
            scanGlobalOutputs
            scanWires
            @matrix = Array.new(@id_tab.size){Array.new(@id_tab.size,0)}# * : matrix of the size of the id_tab : n x n with n the number of elements registered
        end 

        def convWire sink_name, source_name
            sink_ids = @wires[sink_name].collect do |w_sink_name| 
                @id_tab[w_sink_name]
            end

            sink_ids.each do |sink_id| 
                @matrix[@id_tab[source_name]][sink_id] = 1
            end
        end

        def convGlobalInputs
            @netlist.get_inputs.each do |ginp|
                ginp.get_sinks.each do |sink|
                    if sink.is_wire?
                        convWire(sink.get_full_name.split('_')[0],ginp.name)
                    else
                        @matrix[@id_tab[ginp.name]][@id_tab[sink.get_full_name.split('_')[0]]] = 1
                    end
                end
            end
        end

        def convComponents
            @netlist.components.each do |comp|
                comp.get_outputs.each do |outp|
                    outp.get_sinks.each do |sink|
                        if sink.is_wire?
                            convWire(sink.get_full_name.split('_')[0], comp.name)
                        else
                            @matrix[@id_tab[comp.name]][@id_tab[sink.get_full_name.split('_')[0]]] = 1
                        end
                    end
                end
            end
        end

        def convNetlist
            convGlobalInputs
            convComponents
            return @matrix
        end

    end

end