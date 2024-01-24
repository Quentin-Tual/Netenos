require_relative "./gate.rb"

module Netlist

    # ! Not maintained, certainly deprecated and not functionnal

    class ImpossibleResolutionException < StandardError
        def initialize(message = "Error : The current generated netlist is not resolvable. Please retry. If it happens too many times, try to change parameters (number of gates, number of IOs, depth).")
            super
        end
    end

    class RandomGenSeq
        attr_reader :netlist

        def initialize gate_number = 10, input_number = 10, output_number = 5
            @netlist = nil
            @size = gate_number
            @ios_number = [input_number, output_number]

            @stages = {}
            @sink_pool = []
            @available_sinks = {}
            @available_sources = {}
            @source_pool = []
        end

        def getRandomNetlist name = "rand_#{self.object_id}", depth = 0
            begin 
                @netlist = Netlist::Circuit.new(name)

                @ios_number[0].times do |n|
                    new_global_input =  Netlist::Port.new("i#{n}", :in)
                    @netlist << new_global_input
                end

                @ios_number[1].times do |n|
                    new_global_output = Netlist::Port.new("o#{n}", :out)
                    @netlist << new_global_output
                end 

                @size.times do |n|
                    @netlist << getRandomComp
                end

                # TODO : still necessary
                # @available_sources.keys.each{|key|
                #     @source_pool[key] = @available_sources[key].dup
                # }
                
                # TODO :  Use 'source_pool' as a copy of 'available_sources'
                # @source_pool[0] = []
                # @netlist.get_inputs.each{ |global_input|
                #     @source_pool[0] << global_input
                # }

                # TODO : See if possible to reduce complexity (without recursive calls ?)  
                doWiring

                fix_not_connected_comps

                # ! : In theory, not needed in sequential circuits (thanks to registers)
                # TODO : Add a function to detect combinatory loops if necessary ?
                loopsFix

            # ! : same as previous, not needed in sequential circuits
            rescue ImpossibleResolutionException => e

                if depth == 10
                    raise "Error : Impossible resolution. Please change parameters and try again."
                
                else 
                
                    @netlist = nil
                    @sink_pool = []
                    @source_pool = []
                    @available_sources = {}
                    @available_sinks = {}
    
                    @netlist = self.getRandomNetlist depth+1
                    # ! : May cause troubles if the stack is not large enough (too much failures).
                end

            end

            return @netlist
        end

        def loopsFix
            netlist.get_inputs.each do |global_input|
                global_input.get_sinks.each do |sink|
                    detectLoops sink, []
                end
            end
        end

        def detectLoops sink, encountered
            comp = sink.partof
            if comp != @netlist
                if encountered.include? comp
                    # Loop detected
                    insertRegister sink, sink.get_source
                elsif comp.is_a?(Netlist::Register)
                    return 0
                else
                    encountered << comp
                    comp.get_outputs.each do |source|
                        source.get_sinks.each do |sink|
                            detectLoops sink, encountered.dup
                        end
                    end
                end
            else
                # Global output reached
                return 0
            end
        end

        def insertRegister sink, source
            sink.unplug2 source.get_full_name
            # instanciate a new register
            tmp_reg = Netlist::Register.new
            @netlist << tmp_reg
            # link it to the source and the sink specified
            tmp_reg.get_inputs[0] <= source
            sink <= tmp_reg.get_outputs[0]
        end

        # TODO : Refactor as in comb. circuits generation
        def getNetlistInformations
            return @netlist.get_inputs.length, @netlist.get_outputs.length, @netlist.components.length, scan_netlist
        end

        def scan_netlist
            # * : Inputs scanned first 
            @netlist.get_inputs.each do |global_input|
                @stages[global_input] = 0
            end
            
            # * : Following each path
            @netlist.get_inputs.each do |global_input|
                global_input.get_sinks.each do |sink| 
                    visit_netlist sink.partof, 1
                end 
            end
            
            # * : Finish with output as the last_stage.
            last_stage = @stages.values.max + 1
            @netlist.get_outputs.each do |global_output|
                @stages[global_output] = last_stage
            end  

            return @stages.values.max
        end

        def propag_visit sink_comp, curr_stage
        # * : Allows to propagate the visit along the path, taking in account every object types possibly encountered.
            sink_comp.get_outputs.each do |sink_comp_outport|
                sink_comp_outport.get_sinks.each do |sink|
                    if sink.class == Netlist::Wire
                        sink.get_sinks.map{|wire_sink| visit_netlist wire_sink.partof, curr_stage+1}
                    elsif sink.partof.class == Netlist::Register
                        next 
                    else
                        visit_netlist sink.partof, curr_stage+1
                    end
                end
            end
        end 

        def visit_netlist sink_comp, curr_stage
        # * : Recursive function used to fill the @stages attribute, going through the paths from inputs to outputs.
            if sink_comp.partof.nil? 
                return nil
            elsif @stages.keys.include?(sink_comp)
                if @stages[sink_comp] < curr_stage
                    @stages[sink_comp] = curr_stage
                    propag_visit sink_comp, curr_stage
                end
                return nil
            else
                @stages[sink_comp] = curr_stage
                propag_visit sink_comp, curr_stage
            end
        end

        def getRandomComp
            # * : Instantiate a random Gate class object in available types (And, Or, Nor , ...)
            random_comp = $DEF_GATE_TYPES.sample.new
            stage = rand(@stage_number)

            if @available_sinks[stage].nil?
                @available_sinks[stage] = []
                @available_sinks[stage] << random_comp.get_inputs
                @sink_pool << random_comp.get_inputs
                @sink_pool.flatten!
            else
                @available_sinks[stage] << random_comp.get_inputs 
                @sink_pool << random_comp.get_inputs
                @sink_pool.flatten!
            end
            @available_sinks[stage].flatten!

            if @available_sources[stage].nil?
                @available_sources[stage] = []
                @available_sources[stage] << random_comp.get_outputs
                @source_pool << random_comp.get_outputs
                @source_pool.flatten!
            else
                @available_sources[stage] << random_comp.get_outputs
                @source_pool << random_comp.get_outputs
                @source_pool.flatten!
            end
            @available_sources[stage].flatten!
            
            return random_comp
        end

        def getRandomInputStage min = 0
            set = @available_sinks.keys.filter{|key| key > min} 
            return set.sample
        end

        def getRandomOutputStage min = -1, max = @stage_number
            #max =  @available_sources.keys.max
            set = @available_sources.keys.filter{|key| key > min and key < max} #and key < max} 
            return set.sample
        end

        def getAvailableInput stage = 0
            ret = @available_sinks[stage].delete(@available_sinks[stage].sample)

            if @available_sinks[stage].empty?
                @available_sinks.delete stage
            end

            return ret
        end

        def getAvailableOutput stage = 0
            ret = @available_sources[stage].delete(@available_sources[stage].sample)

            if @available_sources[stage].empty?
                @available_sources.delete(stage)
            end

            return ret
        end

        # TODO : See if possible to reduce complexity
        def doWiring

            wire_global_inputs
            
            wire_sinks

            wire_global_outputs 

            # # TODO : while ther is available sinks, connect them to available sources.
            # free_sinks = @sink_pool.select{|sink| sink.is_free?}
            # free_sinks.each do |sink| 
            #     sink <= @source_pool.delete(@source_pool.sample)
            # end

            wire_remaining_free_sources

        end

        def wire_global_inputs
             # todo : Connect every inputs to an available sink
             @netlist.get_inputs.each do |global_input|
                selected_sink = @sink_pool.sample
                selected_sink <= global_input
                @sink_pool.delete(selected_sink)
            end
        end

        def wire_sinks
            # Todo : Connect every components and primary outputs
            @sink_pool.each do |selected_sink|
                if selected_sink.fanin.nil?
                    selected_source = @source_pool.sample
                    if selected_source.nil?
                        raise "Error : no more free sources available."
                    else
                        selected_sink <= selected_source
                        # @sink_pool.delete selected_sink
                    end
                end
            end
        end

        def wire_global_outputs
            # Todo : Verify every primary outputs are connected, connect if not
            # to_delete = []
            @netlist.get_outputs.each do |global_output|
                if global_output.is_free?
                    selected_source = @source_pool.sample
                    global_output <= selected_source
                    @source_pool.delete selected_source
                end
                # Legacy code, only used for specific situations where there is more global outputs than components in the netlist.
                if @source_pool.empty?
                    to_delete << global_output
                end
            end
        end

        def wire_remaining_free_sources
            # TODO : While ther is still available sources, connect them to new primary outputs
            free_sources = @source_pool.select{|source| source.is_free?}
            free_sources.each do |source|
                new_global_output = Netlist::Port.new("o#{@netlist.get_outputs.length}", :out)
                @netlist << new_global_output
                new_global_output <= source
            end
        end

        def fix_not_connected_comps
            # TODO : Detect components which have inputs not connected to a path (usually 2 comb. loops), and connect an output to a path(source randomly selected).
            not_connected_comp = []
            @netlist.components.each do |comp|
                linked_comp = comp.get_inputs.collect{|comp_in| comp_in.get_source.partof}
                if linked_comp.length == 2 # it is a common binary gate 
                    linked_comp.uniq
                    if linked_comp.length == 1 and linked_comp[0] == comp
                        not_connected_comp << comp
                    end
                else # it is a Not gate (unary gate)
                    if linked_comp[0] == comp
                        not_connected_comp << comp
                    end
                end
            end
            not_connected_comp.each do |comp|
                @netlist.components.delete comp
                puts "Isolated component #{comp.name} deleted !" 
            end
            not_connected_comp = nil
        end

    end

end 