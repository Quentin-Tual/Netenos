require_relative "../netenos.rb"

module Netlist

    class RandomGenComb
        attr_accessor :netlist, :grid, :ng

        def initialize nb_inputs = 10, nb_outputs = 5, height = 5, gate_distrib = [:even, 0.5], exclude_gate_type: []
            @netlist = nil
            if gate_distrib[0] == :even    
                @ng = lambda {|l| nb_inputs*gate_distrib[1]} # Rectangle shape
            elsif gate_distrib[0] == :decreasing
                @ng = lambda {|l| nb_inputs/((1/gate_distrib[1])+l)} # Inverted Pyramid shape
            elsif gate_distrib[0] == :custom
                b = nb_inputs * gate_distrib[1]
                a = (nb_outputs - b)/height
                @ng = lambda {|l| a*l + b}
            end

            @caracs = {
                :nb_inputs => nb_inputs,
                :nb_outputs => nb_outputs,
                :height => height
            }
            # Initialize variables to fill the sources pool later
            @available_sources = {} # Contains available sources for each layer
            @already_used_sources = {} # Contains already used sources for each layer
            @sources_usage_count = {} # Associates each source to its current fanout load (useful to control fan out charge in circuit generated)
            @available_primary_output_sources = {}
            exclude_gate_type << "Buffer"
            @gate_pool = $GTECH.select{|klass| !exclude_gate_type.include?(klass.name.split("::")[-1])}
        end

        def getValidRandomNetlist name = "rand_#{self.object_id}", delay_model = :int_multi, compiler = :ghdl
            attempts = 0
            loop do 
                attempts += 1
                # * Generate a random netlist
                getRandomNetlist(name)
                @netlist.getNetlistInformations delay_model

                # * Simulate with a transition exhaustive stimulation
                simulate(delay_model, compiler)

                # * Load VCD file resulting

                # vcd_loader = VCD::Vcd_Signal_Extractor.new
                # trace = vcd_loader.extract2 "#{@netlist.name}_#{1}_tb.vcd", compiler

                # * If every output signal take both value 0 and 1 at least one time in the simulation -> end the loop
                validity = File.read("validity").split[0].to_i.zero? ? false : true
                break if validity and !@netlist.has_combinational_loop?
            end
            puts "Found with #{attempts} attempts." if $VERBOSE #!DEBUG
            clean_simulation
            # * Return the found netlist
            return @netlist
        end

        def simulate delay_model, compiler
            # * Generate gtech
            vhdl_generator = Converter::ConvNetlist2Vhdl.new(@netlist)
            vhdl_generator.gen_gtech
            
            # * Generate circuit vhdl description file
            vhdl_generator.generate(@netlist, delay_model)

            # * Generate compile.sh and makefile
            vhdl_compiler = Converter::VhdlCompiler.new
            vhdl_compiler.gtech_makefile(".", compiler)
            vhdl_compiler.circ_compile_script(".", @netlist.name, [1], [compiler, :minimal_sig], gtech_path: ".", vcd: false)

            # * Generate transition exhaustivity stimulation
            stim_generator = Converter::GenStim.new(@netlist)
            # stim_generator.gen_exhaustive_trans_stim
            stim_generator.gen_exhaustive_incr_stim
            stim_generator.save_as_txt("stim.txt")

            # * Generate testbench file 
            tb_generator = Converter::GenTestbench.new(@netlist)
            tb_generator.gen_testbench("stim.txt", 1, @netlist.name)

            # * Run simulation
            `make`
            `./compile.sh` 
        end

        def clean_simulation 
            `rm *.o`
            `rm *_tb`
            `rm *_d.vhd`
            `rm *.cf`
            `rm makefile`
        end

        def getRandomNetlist name = "rand_#{self.object_id}"
            # Initialize variables to fill the sources pool later
            @available_sources = {} # Contains available sources for each layer
            @already_used_sources = {} # Contains already used sources for each layer
            # @sources_usage_count = {} # Associates each source to its current fanout load (useful to control fan out charge in circuit generated)
            @available_primary_output_sources = {}
            
            @netlist = Netlist::Circuit.new(name)
            @grid = Array.new(@caracs[:height])

            gen_profile @caracs[:nb_inputs], @caracs[:nb_outputs]
            fill_state_variables
            wire_all_sources

            return @netlist
        end
        
        def gen_profile nb_inputs, nb_outputs
            # **** Misc instantiation for later ****

            inputs = [] 
            nb_inputs.times{|nth| 
                @netlist << Netlist::Port.new("i#{nth}", :in)
            } 

            outputs = []
            nb_outputs.times{|nth| 
                @netlist << Netlist::Port.new("o#{nth}", :out)
            }

            # **** Components Grid Generation ****

            @grid.length.times do |layer|
                @grid[layer] = Array.new(@ng.call(layer).to_i) # calling ng being number of gates per layer depending on a lambda function (shape of the netlist defined by this lambda)
                @grid[layer].length.times do |cell|
                    @grid[layer][cell] = @gate_pool.sample.new
                    @netlist << @grid[layer][cell] # Adding each components to the netlist components list
                end 
            end

        end

        # **** Components Wiring ****

        # * : Wire the given sink to a randomly selected source located at a lower layer (than the given one)
        def wire_to_random_source sink, layer_max = @grid.length+1
            # * : Select all lower layers than the sink's one (layer_max)
            # autorized_layers = @available_sources.keys.select{|layer| layer <= layer_max}
            autorized_layers = @available_sources.keys.select{|layer| layer <= layer_max}


            # * : Verify if the sink to wire is a primary output
            if sink.is_global? and sink.is_output?
            # * : Select a source in sources not already plugged to primary output
                autorized_layers = @available_primary_output_sources.keys.select{|layer| layer <= layer_max}

                if !@available_primary_output_sources.empty?
                    selected_layer = autorized_layers[-1]
                   
                    selected_source = @available_primary_output_sources[selected_layer].sample
                else
                    raise "Error : Internal error encountered. Situation not yet handled, you can try changing netlist generation parameters."
                end
            # * : If none available then delete the output (at first sight, the best option)
                sink <= selected_source

                # * : Update variables
                # @available_primary_output_sources[selected_layer].delete(selected_source)
                @available_primary_output_sources[selected_layer].filter!{|source| source != selected_source}

                if @available_primary_output_sources[selected_layer].empty?
                    @available_primary_output_sources.delete selected_layer
                end

                @sources_usage_count[selected_layer][selected_source] += 1
            # * : If there is not available sources (not used at all sources) at a lower layer
            elsif !@available_sources.empty? and !autorized_layers.empty?
                # * : Select an available source to be wired
                selected_layer = autorized_layers.sample

                min_value = @sources_usage_count[selected_layer].values.min
                min_pairs = @sources_usage_count[selected_layer].each_with_object([]) { |(key, value), arr| arr << [key, value] if value == min_value }

                selected_source = (min_pairs.sample)[0]
                
                sink <= selected_source

                @sources_usage_count[selected_layer][selected_source] += 1

                # * : Update variables 
                # * : Delete the source wired from the available sources 
                @available_sources[selected_layer].filter!{|source| source != selected_source}
                # * : Register the source as an @already_used_source 
                if @already_used_sources.keys.include? selected_layer 
                    @already_used_sources[selected_layer] << selected_source
                else 
                    @already_used_sources[selected_layer] = [selected_source]
                end 

                if @available_sources[selected_layer].empty?
                    # * : If the layer is empty, clean it
                    @available_sources.delete selected_layer
                end
            else
                # * : Select a source already used respecting the layer_max constraint
                autorized_layers = @already_used_sources.keys.select{|layer| layer <= layer_max}
                selected_layer = autorized_layers.sample

                min_value = @sources_usage_count[selected_layer].values.min
                min_pairs = @sources_usage_count[selected_layer].each_with_object([]) { |(key, value), arr| arr << [key, value] if value == min_value }

                selected_source = (min_pairs.sample)[0]

                sink <= selected_source
                # * : Update the variables
                @sources_usage_count[selected_layer][selected_source] += 1
            end
        end

        # * : Fill the @available_sources variable
        def fill_state_variables
            curr_layer = 0
            @available_sources[curr_layer] = []
            @sources_usage_count[curr_layer] = {}

            # * : For each primary input
            @netlist.get_inputs.each do |primary_input|
                # * : Register the primary input as an available source
                @available_sources[curr_layer] << primary_input
                @sources_usage_count[curr_layer][primary_input] = 0
            end

            # * : For each layer of the grid
            @grid.length.times do |layer|
                # * : Use an offset cause level 0 is for primary inputs
                # * : Register each component output as an available source
                @available_sources[layer+1] = []
                @available_primary_output_sources[layer+1] = []
                @sources_usage_count[layer+1] = {}
                @grid[layer].each do |comp|  
                    comp.get_outputs.each do |comp_out|
                        @available_sources[layer+1] << comp_out
                        @available_primary_output_sources[layer+1] << comp_out
                        @sources_usage_count[layer+1][comp_out] = 0
                    end 
                end
            end
        end

        # * : Wire each sink to each source by layer
        def wire_all_sources
            # * : For each layer in the grid
            @grid.length.times do |layer|
                # * : For each component of a layer
                @grid[layer].each do |comp|
                    # * : For each input the this component
                    comp.get_inputs.each do |sink|
                        # * : Wire the input(sink) with a randomly selected source (located at a lower layer )
                        wire_to_random_source sink, layer
                    end
                end 
            end

            # * : For each primary output 
            @netlist.get_outputs.each do |primary_output|
                # * : Wire it to a randomly selected source
                wire_to_random_source primary_output
            end

            @netlist.components.each do |comp|
                o = comp.get_free_output
                if o.nil?
                    next
                else
                    nth = @netlist.ports[:out].length
                    @netlist << Netlist::Port.new("o#{nth}", :out)
                    @netlist.ports[:out][-1] <= o
                end
            end
        end

        def getNetlistInformations delay_model
            return @netlist.getNetlistInformations delay_model
        end

        ## ! WIP code, not functionnal
        def scan_netlist
            # * : Inputs scanned first 
            @netlist.get_inputs.each do |global_input|
                @stages[global_input] = 0
                @branch_points[global_input] = 0
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


        ## ! WIP code, not functionnal
        def get_back
            # puts("Entered get_back") # DEBUG
            if @branch_points.empty?
                # puts "Getting back but no more branch points"
            end
            curr_port, curr_stage = @branch_points.keys.last, @branch_points.delete(@branch_points.keys.last)
            i = 0
            # ! : Wire ici et pb avec le partof, voir si un cas en plus à prendre en compte, il semblerait qu'un wire ait été utilisé comme branch_point, cela ne semble pas conforme. 
            # ! : Vérifier si le curr_port est un wire avant d'ajouter un branch point et si c'est le cas, get_forward, finalement on ne reste jamais sur un Wire, ce n'est un état que temporaire, pas d'étape importante avec un Wire, ils doivent rester transparents
            curr_comp = curr_port.partof
            # puts " -> #{curr_port.get_full_name}, #{curr_stage}, #{curr_comp.name}"
            possible_next = curr_comp.get_outputs[0].get_sinks

            if curr_port.is_global? and curr_port.is_input?
                curr_comp, curr_stage, curr_port = get_forward(curr_comp, curr_stage, curr_port)
            else
                while possible_next[i].partof != curr_port  and i < possible_next.length-1
                    i += 1
                end

                if i >= possible_next.length-1
                    # puts "Getting back again successively"
                    curr_comp, curr_stage = get_back
                else 
                    curr_comp = possible_next[i + 1].partof
                    # puts "Adding a branch point"
                    # if curr_comp.class == Wire
                    #     puts "Wire can't be a branch point"
                    #     curr_comp, curr_stage, curr_port = get_forward(curr_comp, curr_stage, curr_port) 
                    # end
                    @branch_points[possible_next[i + 1]] = curr_stage
                end
            end

            return curr_comp, curr_stage
        end


        ## ! WIP code, not functionnal
        def get_forward curr_comp, curr_stage, curr_port
            # puts("Entered get_forward") # DEBUG
            @stages[curr_comp] = curr_stage

            if curr_port.get_sinks.length > 1
                # puts "Adding a branch_point"
                curr_comp = curr_port.get_sinks[0].partof
                curr_stage += 1
                if curr_port.class == Netlist::Wire
                    @branch_points[curr_port.get_source] = curr_stage
                else 
                    @branch_points[curr_port] = curr_stage
                end
                
            else
                if curr_port.get_sinks[0].class == Wire
                    return get_forward(curr_port.get_sinks[0], curr_stage, curr_port.get_sinks[0]) 
                else
                    curr_comp = curr_port.get_sinks[0].partof
                    curr_stage += 1
                end
            end

            return curr_comp, curr_stage, curr_port
        end

        ## ! WIP code, not functionnal
        def visit_netlist2 curr_comp, curr_stage
            # @branch_points = {curr_comp => curr_stage} # ! déterminer le cas initial permettant de rentrer dans la boucle
            # * : curr_port = output ports 
            # * : branch_points = array of pairs (port, stage)
            # puts("Entered visit_netlist2") # DEBUG
            while !@branch_points.empty?
                # puts("Iterating in visit_netlist2")
                # puts(curr_comp.name) # DEBUG
                curr_port = curr_comp.get_outputs[0]
                if curr_port.is_global? and curr_port.is_output?
                    curr_comp, curr_stage = get_back 
                # ! : Possible optimization by changing conditions
                elsif @stages.include? curr_comp
                    if @stages[curr_comp] < curr_stage 
                        curr_comp, curr_stage, curr_port = get_forward(curr_comp, curr_stage, curr_port)
                    else
                        curr_comp, curr_stage = get_back
                    end
                else
                    curr_comp, curr_stage, curr_port = get_forward(curr_comp, curr_stage, curr_port)
                end
            end

            return @stages
        end

        ## ! WIP code, not functionnal
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

        ## ! WIP code, not functionnal
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
    end
end
