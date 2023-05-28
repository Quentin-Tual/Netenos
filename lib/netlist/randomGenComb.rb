require_relative "./gate.rb"

module Netlist

    class ImpossibleResolutionException < StandardError
        def initialize(message = "Error : The current generated netlist is not resolvable. Please retry. If it happens too many times, try to change parameters (number of gates, number of IOs, depth).")
            super
        end
    end 

    class RandomGenComb
        attr_reader :netlist

        def initialize gate_number = 10, input_number = 10, output_number = 5, stage_number = 5
            @netlist = nil
            @size = gate_number
            @ios_number = [input_number, output_number]
            @stage_number = stage_number
            @stages = {}

            @available_sinks = {}
            @available_sources = {}
            @source_pool = {}
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

                @available_sources.keys.each{|key|
                    @source_pool[key] = @available_sources[key].dup
                }
                @source_pool[0] = []
                @netlist.get_inputs.each{ |global_input|
                    @source_pool[0] << global_input
                }

                doWiring

            rescue ImpossibleResolutionException => e

                if depth == 10
                    raise "Error : Impossible resolution. Please change parameters and try again."
                
                else 
                
                    @netlist = nil
                    @source_pool = {}
                    @available_sources = {}
                    @available_sinks = {}
    
                    @netlist = self.getRandomNetlist depth+1
                    # ! : May cause troubles if the stack is not large enough (too much failures).
                end

            end
            
            return @netlist
        end

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
            else
                @available_sinks[stage] << random_comp.get_inputs 
            end
            @available_sinks[stage].flatten!

            if @available_sources[stage].nil?
                @available_sources[stage] = []
                @available_sources[stage] << random_comp.get_outputs
            else
                @available_sources[stage] << random_comp.get_outputs
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

        def doWiring
            curr_stage = 0
            @netlist.get_inputs.each do |global_input|
                # * : Avoid to get empty stages
                while @available_sinks[curr_stage].nil?
                    curr_stage += 1
                    # * Avoid stages that became empty during previous loops 
                end
                # * : Link the randomly selected ports
                getAvailableInput(curr_stage) <= global_input
            end

            until @available_sinks.empty? or @available_sources.empty?
                # ! : voir si on peut faire ça plus proprement (double condition à la suite...)
                if (@available_sinks.keys.max <= @available_sources.keys.min)
                    break
                end
                curr_stage = getRandomOutputStage 0, @available_sinks.keys.max
                if curr_stage.nil?
                    break
                else
                    next_stage = getRandomInputStage curr_stage
                    # * : If no stage answer to the conditions -> just pass and let the output for later (global output wiring for example) 
                        source = getAvailableOutput curr_stage
                        sink = getAvailableInput next_stage
                        sink <= source
                    # end
                end
            end

            until @available_sinks.empty?
                @available_sinks.keys.each do |stage|
                    @available_sinks[stage].each do |in_p|
                        selected_stage = @source_pool.keys.select { |num| num >= 0 && num < stage}.sample
                        if @source_pool[selected_stage].nil?
                            raise ImpossibleResolutionException.new
                        end
                        selected_source = @source_pool[selected_stage].sample
                        in_p <= selected_source
                        @source_pool[selected_stage].delete(selected_source)
                        if @source_pool[selected_stage].empty? or @source_pool[selected_stage].nil?
                            @source_pool.delete(selected_stage)
                        end
                    end
                    @available_sinks.delete stage
                end
            end

            to_delete = []
            @netlist.get_outputs.each do |global_output|
                if @available_sources.empty?
                    to_delete << global_output
                else
                    curr_stage = getRandomOutputStage
                    source = getAvailableOutput(curr_stage)
                    global_output <= source
                end
            end

            to_delete.each do |global_output|
                @netlist.ports[:out].delete(global_output)
            end 

            until @available_sources.empty?
                new_global_output = Netlist::Port.new("o#{@netlist.get_outputs.length}", :out)
                @netlist << new_global_output

                new_global_output <= getAvailableOutput(getRandomOutputStage)
            end

        end

    end

end 