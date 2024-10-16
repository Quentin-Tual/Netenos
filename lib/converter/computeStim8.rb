module Converter

    # Transition = Struct.new(:timestamp, :value)
    class Event 
        attr_reader :signal, :timestamp, :value, :parent
        attr_accessor :children, :forbidden

        def initialize signal, timestamp, value, parent
            @signal = signal
            @timestamp = timestamp
            @value = value

            @parent = parent # will reference an Event class instance
            @children = nil # will reference a Decision class instance
            @forbidden = []
            # @possible = []
        end

        def match? event
           return ((event.signal == @signal) and (event.timestamp == @timestamp) and (event.value == @value))
        end

        def closest_inferior_timestamp events
            events.select{|e| e.timestamp <= timestamp}.min_by{|e| (e.timestamp - timestamp).abs}
        end

        def boolean_value
            case value
            when :R, :S1
                "1"
            when :F, :S0
                "0"
            else
                raise "Error : Unknown transition value encountered. Cannot obtain boolean equivalence."
            end
        end

        def previous_value
            case value
            when :R,:S0
                :S0
            when :F, :S1
                :S1
            else
                raise "Error : Unknown transition value encountered. Cannot obtain boolean equivalence."
            end
        end

        def afterward_value
            case value
            when :R, :S1
                :S1
            when :F, :S0
                :S0
            else
                raise "Error : Unknown transition value encountered. Cannot obtain boolean equivalence for #{value}."
            end
        end
    end

    class Decision
        attr_reader :events, :parent

        def initialize *events
            @events = events
            @parent = events[0].parent
        end

        def match? decision
            # a = @events[0].match?(decision.events[0]) and @events[1].match?(decision.events[1])
            # b = @events[1].match?(decision.events[0]) and @events[0].match?(decision.events[1])
            # a or b
            if decision.events.length == @events.length 
                if  decision.events.length == 2
                    @events.zip(decision.events).all?{|e| e[0].match? e[1]}
                else
                    @events[0].match? decision.events[0]
                end
            else 
                return false
            end
        end

        def include? event
            @events.include? event
        end

        def one_match? event
            @events.any?{|e| e.match? event}
        end 

        # def any_parent_match? parent
        #     @events.any?{|e| e.parent.match? parent}
        # end

        def any_parent_equal? parent
            parent == @parent
        end
    end

    class ComputeStim
        attr_accessor :decisions, :transitions
        attr_reader :side_inputs, :stim_vec, :events_computed, :unobservables, :insert_points

        def initialize netlist, delay_model, forbidden_vectors = []
            @netlist = netlist
            @delay_model = delay_model
            @netlist.getNetlistInformations delay_model
            @signal_events = Hash.new { |hash, key| hash[key]=[] }
            @transitions = []
            # @decisions = []
            @forbidden_transitions = [] #Hash.new([]) # Associates a stack of gate/transition pairs to one gate/decision pair, one key for each decision
            # @decisions_steps = Hash.new([])
            @events_to_process = []#Hash.new { |hash, key| hash[key]=[] }
            @unobservables = []
            @insert_point_observable = nil
            @insert_point = nil
            @forbidden_vectors = forbidden_vectors
            # @logger = Logger.new("test.log") if $VERBOSE
        end

        def get_insertion_points payload_delay
            # * Returns a list of gate which outputs has a slack greater than the payload delay 
            slack_h = @netlist.get_slack_hash(@delay_model)
            return slack_h.select{|slack, gate| slack >= payload_delay}.values.flatten
        end

        def get_cone_outputs insertion_point
            # * search the output from the given insertion_point (last gate of the path)
            # * Tag each gate encountered as "target_path" 
            next_gates = nil

            if insertion_point.instance_of? Netlist::Port and insertion_point.is_global?
                insertion_point.tag = :target_path
                next_gates = insertion_point.get_sink_gates
            else
                insertion_point.partof.tag = :target_path
                if insertion_point.get_source.is_global?
                    insertion_point.get_source.tag = :target_path
                else
                    insertion_point.get_source_comp.tag = :target_path
                end
                next_gates = insertion_point.partof.get_sink_gates
            end

            cone_outputs = []

            until next_gates.empty?
                current_gate = next_gates.shift
                if current_gate.instance_of? Netlist::Port and current_gate.is_global? # * If insertion point is the last gate before a primary output
                    cone_outputs << current_gate
                    next
                end
                current_gate.tag = :target_path

                primary_outputs, current_gate_sinks = current_gate.get_sink_gates.partition{|g| g.is_a? Netlist::Port and g.is_global?}
                current_gate_sinks = current_gate_sinks.select{|g| g.tag != :target_path}
                
                # cone_outputs << current_gate unless primary_outputs.empty?
                cone_outputs << primary_outputs unless primary_outputs.empty?
                cone_outputs.flatten!
                next_gates += current_gate_sinks unless next_gates.include? current_gate
            end

            return cone_outputs 
        end

        def analyse_netlist ht
            case ht
            when "og_s38417"
                delay_required = Inserter::Og_s38417.new.get_payload_out.partof.propag_time[@delay_model]
            when "xor_and"
                delay_required = Inserter::Xor_And.new.get_payload_out.partof.propag_time[@delay_model]
            when "it_s38417"
                delay_required = Inserter::It_s38417.new.get_payload_out.partof.propag_time[@delay_model]
            else
                raise "Error : Unknown hardware trojan #{ht} encountered."
            end

            @insert_points = get_insertion_points(delay_required) 
            # @target_paths_outputs = {}
            # @downstream_outputs = {}
            # @insert_points.each do |signal|
            #     @downstream_outputs[signal] = get_cone_outputs(signal) 
            # end
        end

        def clean_data
            @signal_events = Hash.new { |hash, key| hash[key]=[] }
            @transitions = []
            # @decisions = []
            @forbidden_transitions = [] #Hash.new([]) # Associates a stack of gate/transition pairs to one gate/decision pair, one key for each decision
            # @decisions_steps = Hash.new([])
            @events_to_process = []
            # @netlist.components.each{|comp| comp.tag = nil}
        end

        def generate_stim netlist=nil, ht="og_s38417", save_explicit: "explicit_stim.txt", freq: 1.1
            # @logger.info("Generating stimulus for #{ht} hardware trojan") if $VERBOSE

            if @netlist.nil? and netlist.nil?
                raise "Error : No netlist provided."
            elsif !netlist.nil?
                @netlist = netlist
            end
             
            analyse_netlist(ht)
            
            @events_computed = {}

            @insert_points.each do |insert_point|
                @events_computed[insert_point] = {}
                downstream_outputs = get_cone_outputs(insert_point)
                downstream_outputs.each do |targeted_output|
                    res = nil
                    # @events_computed[insert_point][targeted_output] = {}
                    tmp = nil

                    #!DEBUG
                    # if insert_point.get_full_name == "And2220_i1"
                    #     pp "here"
                    # end

                    targeted_transition = nil
                    [:R,:F].each do |transition|
                        targeted_transition = Converter::Event.new(targeted_output, @netlist.crit_path_length , transition, nil)      
                        # get_cone_outputs(insert_point)
                        res = compute(targeted_transition, insert_point)
                        tmp = get_inputs_events
                        clean_data # Nettoyer @transitions, @forbidden_transitions, ...
                        if res == :success
                            break
                        else 
                            tmp = nil
                            res = nil
                        end
                    end

                    if res == :success
                        @events_computed[insert_point][targeted_transition] = tmp
                        break
                    end
                end

                if @events_computed[insert_point].empty?
                    # raise "Error : Insertion point #{insert_point.name} not observable on any output."
                    pp "Insertion point #{insert_point.get_full_name} not observable on any output or no solution satisfying constraints (authorized vectors, etc)."
                    @unobservables << insert_point.dup
                end
                @netlist.components.each{|comp| comp.tag = nil}
                @netlist.get_inputs.each{|in_p| in_p.tag = nil}
            end

            @events_computed.delete_if{|insert_point, solution| solution.empty?}

            # TODO : Déterminer les vecteurs synchrones pour chaque cas(feuille de l'arbre) de @events_computed. Possible de le faire au cas par cas.
            stim_pair_h = {}
            # TODO : Pour chaque signal à risque calculer un couple de vecteurs 
            @events_computed.each do |insert_point, solution|
                stim_pair_h[insert_point] = {solution.keys[0] => convert_events2vectors(solution.values[0])}
            end

            if !save_explicit.nil?
                rep = (1 / (freq % 1).round(4)).to_i
                save_explicit_stim_file(save_explicit, stim_pair_h, repetition: rep)
            end
 
            # TODO : Transformer les couples de vecteurs en une suite de vecteurs uniques
            # @stim_vec = stim_pair.uniq.flatten 
            @stim_vec = stim_pair_h.collect{|insert_point, solution| solution.values}.flatten

            # pp "test" #!DEBUG
            return @stim_vec
        end

        def compute event, insertion_point
            # @logger.info("Computing event (#{event.signal.get_full_name},#{event.timestamp},#{event.value}) on #{insertion_point.get_full_name}") if $VERBOSE

            @insert_point = insertion_point
            @transitions << Decision.new(*event)
            backpropagate2([event])
            if event.forbidden.any?{|f| f.one_match? event}
            # if @forbidden_transitions.any?{|d| d.include? event}
                # if @forbidden_transitions.length > 1 #!DEBUG
                #     pp "unexpected"
                # end
                return :impossible
            else
                return :success
            end
        end

        def recursive_transitions_deletion parent_to_delete
            
            child_decision = parent_to_delete.children

            unless child_decision.nil?
                child_decision.events.each do |e|
                    recursive_transitions_deletion(e)
                end
            end

            # @forbidden_transitions.delete_if do |d|
            #     d.any_parent_equal? parent_to_delete
            # end
            # @forbidden_transitions.delete(parent_to_delete.parent.children) # Remove the Decision containing the event to delete
            @transitions.delete(parent_to_delete.parent.children) # Remove the Decision containing the event to delete
            @signal_events[parent_to_delete.signal].delete(parent_to_delete)
            @events_to_process.delete(parent_to_delete)
            if !@insert_point_observable.nil? and @insert_point_observable.include?(parent_to_delete)
                @insert_point_observable = nil
            end
            # parent_to_delete.parent.children = nil # Remove reference from parent to the instance to delete
            
        end

        def backtrack wrong_event
            # @logger.info("Backtracking event (#{wrong_event.signal.name},#{wrong_event.timestamp},#{wrong_event.value})") if $VERBOSE

            # if wrong_event.signal.name == "Nand2400"  #!DEBUG
            #     pp "here"
            # end

            if wrong_event.signal.instance_of?(Netlist::Port) and wrong_event.signal.is_global? and wrong_event.signal.is_output?
                wrong_event.forbidden << Decision.new(*wrong_event) # * Event contradicts itself -> ends the research
                # @forbidden_transitions << Decision.new(*wrong_event)
                return 
            end

            wrong_decision = wrong_event.parent.children
            # wrong_decision = @transitions.select{|e| e.include? wrong_event}[0]
            wrong_decision.events.each do |e|
                recursive_transitions_deletion(e)
            end
            wrong_decision.parent.children = nil
            # TODO : Ajouter la décision responsable du backtrack aux décisions interdites
            wrong_decision.parent.forbidden << wrong_decision
            # TODO : Supprimer les forbidden decisions pour cette décision
            wrong_decision.events.each{|e| e.children = nil} # Remove reference to garbage the events resulting of the decision deleted  

            # wrong_decision.each{|e| recursive_transitions_deletion(e)}
            # @transitions.delete(wrong_decision)
            if wrong_decision.events == @insert_point_observable
                @insert_point_observable = nil
            end

            
            # @forbidden_transitions.delete_if do |d|
            #     wrong_decision.any?{|e| d.any_parent_equal? e}
            # end


            # @events_to_process.delete_if do |e|
            #     e.parent == 
            #     # e.parent == wrong_event.parent
            # end
            
            # print "Backtracking :" #!DEBUG
            # pp wrong_event.signal

            
            # @forbidden_transitions << wrong_decision

            # TODO : Retourner la dernière transition
            @events_to_process << wrong_decision.parent
        end

        def backpropagate2 event
            
            if @events_to_process.empty?
                @events_to_process = [event].flatten
            else
                @events_to_process << event
                @events_to_process.flatten!
            end
            
            e = nil 
            while !@events_to_process.empty? and @events_to_process != [nil]
                # last_choice = get_last_choice
                e = @events_to_process.pop 
                if e.nil?
                    raise "Error : nil event encountered"
                end 
                # @logger.info("Backpropagating event (#{e.signal.name},#{e.timestamp},#{e.value})") if $VERBOSE

                # print "Backpropagate :" #!DEBUG
                # pp e.signal

                g = e.signal

                # * If g is a primary INPUT
                if g.instance_of? Netlist::Port and g.is_global? and g.is_input?
                    if @events_to_process.empty? or @events_to_process == [nil] # * Should break the while, before check inputs
                        test_vec_couple = convert_events2vectors(get_inputs_events)
                        if !(@forbidden_vectors & test_vec_couple).empty?
                            backtrack(e)
                        end
                    end
                    next
                end

                e_inputs = compute_transitions(e)
                if e_inputs.nil? or e_inputs == [nil]
                    # puts "transitions :"
                    # pp @transitions #!DEBUG
                    # puts "forbidden transitions :"
                    # pp @forbidden_transitions #!DEBUG
                    # e_inputs = compute_transitions(e) #!DEBUG
                    backtrack(e)
                    next
                end
             
                new_decision = Decision.new(*e_inputs)
                if e.children.nil?
                    e.children = new_decision
                else
                    raise "Error : children already defined for event #{e}"
                end

                if !(@signal_events[new_decision.events[0].signal].include?(new_decision.events[0]) and @signal_events[new_decision.events[1].signal].include?(new_decision.events[1]))
                    # * Push in order to process at first the target path 
                    @events_to_process << e_inputs.sort_by{|e| e.signal.tag.to_s}
                    @events_to_process.flatten!
                    
                    @transitions << new_decision
                    e_inputs.each{|e| @signal_events[e.signal] << e}

                    if e_inputs.collect{|e| e.signal}.include? @insert_point
                        @insert_point_observable = e_inputs
                    end
                end

            end
           
        end 

        def is_fixed_transitions_compatible? events
            # * : 'events' compatibility with each other
            if events.length > 1
                if (events[0].signal == events[1].signal) and (events[0].timestamp == events[1].timestamp) and (events[0].value != events[1].value)
                    return false
                end
            end

            # * : 'events' compatibility with fixed transitions

            # * : Value incompatibility (same timestamp)
            events.each do |event|
                event_list = @signal_events[event.signal]

                event_list.reverse_each do |fixed_event| # * : reverse_each expecting it helps to reduce number of iterations (the latest added should be the closest to the proposed transition)
                    if fixed_event.timestamp == event.timestamp and fixed_event.value != event.value
                        return false
                    end
                end

                # * Different timestamp and incompatible value (resulting state of the earliest transition)
                # Value incompatibility : Latest fixed transition results in a value which make impossible the proposed transition
                # latest_event_timestamp = 0.0
                previous_event = Event.new(nil,0.0,nil,nil)
                next_event = nil
                event_list.sort_by{|e| e.timestamp}.each do |e| 
                    if e.timestamp < event.timestamp and e.timestamp > previous_event.timestamp
                        previous_event = e
                    end
                    if e.timestamp > event.timestamp
                        next_event = e
                        break
                    end
                end

                # if !previous_event.signal.nil?
                #     values = [previous_event.value, event.value]
                #     if [[:R,:R], [:F,:F], [:S1,:R], [:S0, :F], [:R, :S0], [:F, :S1]].include? values
                #         return false
                #     end
                # end

                # if !next_event.nil?
                #     values = [event.value, next_event.value]
                #     if [[:R,:R], [:F,:F], [:S1,:R], [:S0, :F], [:R, :S0], [:F, :S1]].include? values
                #         return false
                #     end
                # end
                 
                # Inertial Delay Incompatibility : An existing transition is too close from the proposed one, impossible according to inertial delay model

                event.signal.get_sink_gates.each do |sink|
                    if sink.instance_of? Netlist::Port and sink.is_global?
                        next
                    else 
                        if !previous_event.signal.nil? and ((event.timestamp - previous_event.timestamp) < sink.propag_time[@delay_model] and (previous_event.afterward_value != event.previous_value))
                            return false
                        end
                        if !next_event.nil? and (next_event.timestamp - event.timestamp) < sink.propag_time[@delay_model] and  event.afterward_value != next_event.previous_value
                            return false
                        end
                    end
                end
            end

            return true
        end
        
        # def verify_transition *events
        #     # * : Constraint -> uniq instant for non stable transition on inputs
        #     new_input_events = events.select{|e| e.signal.instance_of? Netlist::Port and e.signal.is_global? and e.signal.is_input?}
        #     if !new_input_events.empty?
        #         convertible = is_convertible?(get_inputs_events + new_input_events)
        #     else 
        #         convertible = true
        #     end
        #     if !convertible
        #         return false
        #     end
        #     # * Non-forbidden transitions constraint

        #     not_forbidden = @forbidden_transitions.none?{|decision| decision.match?(Decision.new(*events))}  
        #     if !not_forbidden
        #         return false
        #     end
        #     # * Compatibility constraints (regarding other fixed transitions)
        #     compatibility = is_fixed_transitions_compatible?(events)
        #     if !compatibility
        #         return false
        #     end

        #     return true
        #     # if !new_input_events.empty?
        #     #     return (tmp and is_convertible?(get_inputs_events + new_input_events))
        #     # else
        #     #     return tmp 
        #     # end
        # end

        def compute_transitions event, input_transition = nil
            # * : Compute the expected transition at the output and the deducted transition at the inputs
            # * : Optionnally an input transition is given, then the computation is easier
            # * : Decision is made regarding registered forbidden values

            # TODO : récupérer les transitions applicable aux entrées de la porte pour obtenir cette transition en sortie
            gate = event.signal

            if gate.instance_of? Netlist::Port and gate.is_global? and gate.is_output? 
                wire_event = Event.new(gate.get_source_comp, event.timestamp, event.value, event)
                if event.forbidden.any?{|f| f.one_match? wire_event}
                # if @forbidden_transitions.any? {|decision| decision.one_match? wire_event} 
                    return nil
                else
                    return [wire_event]
                end
            end

            possible_inputs_transitions = gate.get_input_transition(event.value)

            if @insert_point_observable.nil?
                possible_inputs_transitions = target_path_controlling(possible_inputs_transitions, event.signal)
            end

            possible_inputs_events = get_event_list(possible_inputs_transitions, event)

            # * : Check if possible to verify if one transition has already been fixed, if it is the case, then skip to the end accepting it.
            possible_inputs_events.each do |proposed_events|
                if @signal_events[event.signal].any?{|e| !e.children.nil? and e.children.match? Decision.new(*proposed_events)}
                    # event.possible = possible_inputs_events - proposed_events
                    return proposed_events
                end
            end

            possible_inputs_events.select! do |proposed_events|
                !is_forbidden?(proposed_events, event)
            end

            possible_inputs_events.select! do |proposed_events|
                new_input_events = proposed_events.select{|e| e.signal.instance_of?(Netlist::Port) and e.signal.is_global? and e.signal.is_input?}

                if new_input_events.empty?
                    true
                else
                    is_convertible?(get_inputs_events + new_input_events)
                end
            end

            possible_inputs_events.each do |proposed_events|
                if is_fixed_transitions_compatible?(proposed_events)
                    # event.possible = possible_inputs_events - proposed_events
                    return proposed_events
                end
            end 

            # TODO : la boucle est terminée et aucune transition n'a été validée -> lancer un backtracking 
            return nil
        end

        def target_path_controlling possible_inputs_transitions, gate 

            if gate.instance_of? Netlist::Not
                possible_inputs_transitions.select! do |inputs_transition|
                    if gate.get_source_gates[0].tag == :target_path
                        non_stable_transition_on? gate.get_source_gates[0] or inputs_transition[0] == :R or inputs_transition[0] == :F
                    else
                        true
                    end 
                    # (gate.get_source_gates[0].tag == :target_path and ([:R,:F].include? inputs_transition[0] or non_stable_transition_on? gate.get_source_gates[0])) or (gate.get_source_gates[0].tag != :target_path)
                end
            else
                possible_inputs_transitions.select! do |inputs_transition|
                    is_target_path = [gate.get_source_gates[0].tag == :target_path, gate.get_source_gates[1].tag == :target_path]
                    if (!is_target_path[0] and !is_target_path[1])
                        true
                    else
                        if is_target_path[0]
                            (non_stable_transition_on? gate.get_source_gates[0] or inputs_transition[0] == :R or inputs_transition[0] == :F)
                        else
                            (non_stable_transition_on? gate.get_source_gates[1] or inputs_transition[1] == :R or inputs_transition[1] == :F)
                        end
                    end
                end
            end

            return possible_inputs_transitions
        end

        def get_event_list transition_pairs, event
            gate = event.signal
            source_gate0 = gate.get_source_gates[0]
            source_gate1 = gate.get_source_gates[1]
            input_transition_time = event.timestamp - gate.propag_time[@delay_model]
            
            transition_pairs.collect do |trans_pair|
                e0 = Event.new(source_gate0, input_transition_time, trans_pair[0], event)
                if trans_pair.length > 1
                    e1 = Event.new(source_gate1,input_transition_time, trans_pair[1], event)
                    [e0, e1]
                else
                    [e0]
                end
            end
        end

        def is_forbidden?(events, parent)
            # * : Check if the event list contains a forbidden transition
            parent.forbidden.any?{|f| f.match? Decision.new(*events)}
            # @forbidden_transitions.none?{|decision| decision.match?(Decision.new(*events))} # ! Opti : Check if possible to avoid using none? method on @forbidden_transitions -> use forbidden_children in each event allowing to ease adding, deleting, and verifying the forbidden transitions
        end

        def non_stable_transition_on? signal
            @signal_events[signal].flatten.any? do |e|
                [:R,:F].include?(e.value)
            end
        end

        def is_convertible? event_list
            event_list.select!{|e| [:R,:F].include? e.value}
            
            if event_list.empty?
                return true
            end

            ref = event_list[0].timestamp
            if event_list.all?{|e| e.timestamp == ref}
                return true
            else 
                return false
            end
        end

        def convert_events2vectors input_events
            # * Converts an event list into a couple test vectors.
            # ! Events must be convertible (see is_convertible?) 
            if !is_convertible?(input_events)
                raise "Error : Given events are not convertible into synchronous test vectors."
            end

            # TODO : Identifier l'instant de transition
            transition_instant = nil
            input_events.each do |e| 
                if (e.value == :R or e.value == :F) 
                    transition_instant = e.timestamp
                    break
                end
            end

            # TODO : Récupérer les évènements avant et après l'instant de transition

            # TODO : construire un vecteur de départ avec les valeur avant l'instant de transition
            # TODO : construire un vecteur d'arrivée avec les après l'instant de transition
            origin_vector = {}
            arrival_vector = {}
            input_events.each do |e|
                if e.timestamp == transition_instant
                    case e.value
                    when :R
                        origin_vector[e.signal] = "0"
                        arrival_vector[e.signal] = "1"
                    when :F
                        origin_vector[e.signal] = "1"
                        arrival_vector[e.signal] = "0"
                    when :S1
                        origin_vector[e.signal] = "1"
                        arrival_vector[e.signal] = "1"
                    when :S0
                        origin_vector[e.signal] = "1"
                        arrival_vector[e.signal] = "0"
                    else
                        raise "Error : Unknown transition value"
                    end
                elsif e.timestamp < transition_instant
                    origin_vector[e.signal] = e.boolean_value
                else
                    arrival_vector[e.signal] = e.boolean_value
                end
            end

            @netlist.get_inputs.each do |in_p|
                if (!origin_vector.include?(in_p) and !arrival_vector.include?(in_p))
                    origin_vector[in_p] = :S1 # ! Default value, can be changed to "X" if necessary
                    arrival_vector[in_p] = :S1 # ! Default value, can be changed to "X" if necessary
                end
            end

            # TODO : s'il manque des valeurs dans un des deux vecteurs (don't care) remplir avec la même valeur que dans l'autre vecteur  
            input_events.collect{|e| e.signal}.uniq.each do |in_p|
                if !origin_vector.include?(in_p)
                    origin_vector[in_p] = arrival_vector[in_p]
                elsif !arrival_vector.include?(in_p)
                    arrival_vector[in_p] = origin_vector[in_p]
                end
            end

            origin_vector = origin_vector.sort_by{|signal, value| signal.name[1..].to_i}.collect{|e| e[1]}.join
            arrival_vector = arrival_vector.sort_by{|signal, value| signal.name[1..].to_i}.collect{|e| e[1]}.join

            return origin_vector, arrival_vector
        end     

        def get_inputs_events
            return @netlist.get_inputs.collect do |in_p|
                @signal_events[in_p]
            end.flatten
        end

        def colorFixedGates
            @signal_events.each do |signal, events|
                signal.tag = :ht
            end
        end

        def save_explicit_stim_file path, stim_pair_h, bin_stim_vec: false, repetition: 1
            if path[-4..-1]!=".txt" and path[-5..-1]!=".stim"
                path.concat ".txt"
            end

            src = Code.new
            src << "# Stimuli sequence"
            src << "# Unobservables : #{@unobservables.length}" 

            stim_pair_rh = stim_pair_h.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(insert_point, solution), result|
                signal = solution.keys[0].signal
                vectors = solution.values[0]
                result[vectors] << [insert_point, signal]
            end
            # stim_pair_rh = stim_pair_rh.invert

            stim_pair_rh.each do |vectors, target|
                src << "# " + (target.collect{|insert_point, output| "s=#{insert_point.get_full_name}, o=#{output.get_full_name}"}.join("; "))
                repetition.times do |i|
                    vectors.each do |vec|
                        if !vec.nil? # ! TEST DEBUG
                            if bin_stim_vec 
                                src << vec.reverse
                            else
                                src << vec.reverse.to_i(2)
                            end
                        else 
                            raise "Error : nil test vector encountered."
                        end
                    end
                end
            end 

            src.save_as path
        end

        def save_as_txt path, vec_list, bin_stim_vec: false 
            if path[-4..-1]!=".txt" and path[-5..-1]!=".stim"
                path.concat ".txt"
            end

            src = Code.new
            src << "# Stimuli sequence"

            vec_list.each do |vec|
                if !vec.nil? # ! TEST DEBUG
                    if bin_stim_vec 
                        src << vec.reverse
                    else
                        src << vec.reverse.to_i(2)
                    end
                else 
                    raise "Error : nil test vector encountered."
                end
            end 

            src.save_as path
        end
    end
end