module Converter

    # Transition = Struct.new(:timestamp, :value)
    class Event 
        attr_reader :signal, :timestamp, :value, :parent
        attr_accessor :children, :forbidden, :possible

        def initialize signal, timestamp, value, parent
            @signal = signal
            @timestamp = timestamp
            @value = value

            @parent = parent # will reference an Event class instance
            @children = nil # will reference a Decision class instance
            @forbidden = []
            @possible = []
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
                raise "Error : Unknown transition value encountered. Cannot obtain previous value of #{value}."
            end
        end

        def afterward_value
            case value
            when :R, :S1
                :S1
            when :F, :S0
                :S0
            else
                raise "Error : Unknown transition value encountered. Cannot obtain afterward value of #{value}."
            end
        end

        def is_non_stable_transition?
            [:R,:F].include?(@value)
        end 

        def get_printable
            "(#{@signal.name}, #{@timestamp}, #{@value})"
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

        def get_printable_events
            events.collect{|e| [e.signal.name, e.timestamp, e.value]}
        end
    end

    class ComputeStim
        attr_accessor :decisions, :transitions, :test
        attr_reader :side_inputs, :stim_vec, :events_computed, :unobservables, :insert_points, :observables

        def initialize netlist, delay_model, forbidden_vectors = []
            @netlist = netlist
            @netlist.getNetlistInformations delay_model
            @delay_model = delay_model
            @forbidden_vectors = Set.new(forbidden_vectors)
            
            @signal_events = Hash.new { |hash, key| hash[key]=[] }
            @transitions = []
            @forbidden_transitions = [] #Hash.new([]) # Associates a stack of gate/transition pairs to one gate/decision pair, one key for each decision
            @events_to_process = []#Hash.new { |hash, key| hash[key]=[] }

            @insert_points = []
            @insert_point = nil
            @insert_point_observable = nil
            @observables = Set.new()
            @unobservables = Set.new()
            @logger = Logger.new("test.log") if $VERBOSE
            # @test = 0
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

            if @netlist.has_combinational_loop?
                raise "Error : Combinational loop detected in the netlist #{@netlist.name}. Cannot compute stimulus vectors."
            end

        end

        def get_insertion_points payload_delay
            # * Returns a list of gate which outputs has a slack greater than the payload delay 
            slack_h = @netlist.get_slack_hash
            return slack_h.select{|slack, gate| slack >= payload_delay and !gate.instance_of?(Netlist::Port)}.values.flatten
        end

        def tag_control_path control_path, tag = :control_path
            control_path.each do |in_p| 
                if in_p.is_global? and in_p.is_output?
                    in_p.tag = tag
                end

                if !(in_p.is_global? and in_p.is_input?)
                    in_p.get_source_gates.tag = tag
                end
            end
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

            cone_outputs = Set.new

            until next_gates.empty?
                current_gate = next_gates.shift
                if current_gate.instance_of? Netlist::Port and current_gate.is_global? # * If insertion point is the last gate before a primary output
                    cone_outputs << current_gate
                    next
                end
                current_gate.tag = :target_path

                primary_outputs, current_gate_sinks = current_gate.get_sink_gates.partition{|g| g.is_a? Netlist::Port and g.is_global?}
                current_gate_sinks = current_gate_sinks.select{|g| g.tag != :target_path}
                
                cone_outputs << primary_outputs unless primary_outputs.empty?
                cone_outputs.flatten!
                next_gates += current_gate_sinks unless next_gates.include? current_gate
            end

            # * Filter primary outputs plugged to a constant
            cone_outputs = cone_outputs.to_a.flatten.select{|g| !g.get_source.instance_of?(Netlist::Constant)}

            return cone_outputs 
        end

        def clean_data
            @signal_events = Hash.new { |hash, key| hash[key]=[] }
            @transitions = []
            @forbidden_transitions = [] 
            @events_to_process = []
            @insert_point_observable = nil
        end

        def generate_stim netlist=nil, ht="og_s38417", save_explicit: "explicit_stim.txt", freq: 1.1, compute_all_transitions: false, all_outputs: false, all_insert_points: false
            @logger.info("Generating stimulus for #{ht} hardware trojan") if $VERBOSE
            
            if @netlist.nil? and netlist.nil?
                raise "Error : No netlist provided."
            elsif !netlist.nil?
                @netlist = netlist
            end

            puts "[+] Generating stimulus for #{ht} hardware trojan on #{@netlist.name}" if $VERBOSE
             
            analyse_netlist(ht)
            
            @events_computed = {}

            @insert_points.each do |insert_point|
                puts " |--[+] Search with insert point #{insert_point.get_full_name}" if $VERBOSE

                # if insert_point.get_full_name == "o1" #!DEBUG
                #     pp 'here'
                # end

                insert_point_event = nil
                if @observables.include? insert_point and !all_insert_points# * If the insert_point is already observable, skip to the next insert point
                    next
                else
                    @events_computed[insert_point] = {}
                    # if insert_point.instance_of?(Netlist::Port) and insert_point.is_output?
                    #     downstream_outputs = [insert_point]
                    # else
                    #     downstream_outputs = get_cone_outputs(insert_point)
                    # end 

                    control_paths = @netlist.get_output_path(insert_point)
                    control_paths.each do |control_path|
                        
                        tag_control_path(control_path, :target_path)
                        targeted_output = control_path[-1]

                        # downstream_outputs.each do |targeted_output|
                            puts "    |--[+] Search with targeted output #{targeted_output.get_full_name}" if $VERBOSE
                            res = nil
                            tmp = nil
                            targeted_transition = nil

                            if compute_all_transitions.nil?
                                last_gate = targeted_output.get_source_comp
                                if last_gate.instance_of? Netlist::Xor2 or last_gate.instance_of? Netlist::Not
                                    transitions_to_try = [:R,:F]
                                else
                                    output_delayed_detectable_transition = last_gate.same_transition_detectable 
                                    transitions_to_try = [output_delayed_detectable_transition, [:R,:F] - [output_delayed_detectable_transition]].flatten
                                end
                            else
                                transitions_to_try = [:R, :F]
                            end

                            transitions_to_try.each do |transition|
                                targeted_transition = Converter::Event.new(targeted_output, @netlist.crit_path_length , transition, nil)      
                                # get_cone_outputs(insert_point)
                                res = compute(targeted_transition, insert_point)
                                tmp = get_inputs_events
                                insert_point_event = @signal_events[insert_point.get_source_comp].find{|e| [:R,:F].include? e.value}
                                clean_data # Nettoyer @transitions, @forbidden_transitions, ...
                                if res == :success
                                    @events_computed[insert_point][targeted_transition] = tmp
                                    break if !compute_all_transitions
                                    # end
                                else 
                                    tmp = nil
                                    res = nil
                                end
                            end

                            if res == :success and !all_outputs
                                # if !all_outputs
                                    break
                                # end
                            end
                        # end

                        @netlist.components.each{|comp| comp.tag = nil}
                        @netlist.get_inputs.each{|in_p| in_p.tag = nil}
                        @netlist.get_outputs.each{|out_p| out_p.tag = nil}
                    end 

                    if @events_computed[insert_point].empty?
                        # pp "Insertion point #{insert_point.get_full_name} not observable on any output or no solution satisfying constraints (authorized vectors, etc)."
                        puts "    |--[+] No solution satisfying constraints for insertion point #{insert_point.get_full_name}." if $VERBOSE
                        @unobservables << insert_point
                    elsif !insert_point_event.nil?
                        puts "    |--[-] Solution found for insertion point #{insert_point.get_full_name}." if $VERBOSE
                        # pp "Insertion point #{insert_point.get_full_name} observable."
                        get_observable_signals(insert_point_event)
                    end
                end
            end

            @events_computed.delete_if{|insert_point, solution| solution.empty?}

            @observables.intersection(@unobservables).each{|s| @unobservables.delete(s)}

            # TODO : Déterminer les vecteurs synchrones pour chaque cas(feuille de l'arbre) de @events_computed. Possible de le faire au cas par cas.
            stim_pair_h = {}
            # TODO : Pour chaque signal à risque calculer un couple de vecteurs 
            @events_computed.each do |insert_point, solution|
                stim_pair_h[insert_point] = solution.each_with_object(Hash.new) do |(expected_transition, events), h|
                    h[expected_transition] = convert_events2vectors(events)
                    # Replace all X values with another 
                    h[expected_transition] = avoid_forbidden_vector2(h[expected_transition])
                end
            end

            if !save_explicit.nil?
                freq == "Infinity" ? rep = 1 : rep = (1 / (freq % 1).round(4)).to_i
                save_explicit_stim_file(save_explicit, stim_pair_h, repetition: rep)
            end
 
            # TODO : Transformer les couples de vecteurs en une suite de vecteurs uniques
            @stim_vec = stim_pair_h.collect{|insert_point, solution| solution.values}.flatten

            return @stim_vec
        end

        def compute event, insertion_point
            @logger.info("Computing event (#{event.signal.get_full_name},#{event.timestamp},#{event.value}) on #{insertion_point.get_full_name}") if $VERBOSE

            @insert_point = insertion_point
            @transitions << Decision.new(*event)
            backpropagate2([event])
            if event.forbidden.any?{|f| f.one_match? event}
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

            @transitions.delete(parent_to_delete.parent.children) # Remove the Decision containing the event to delete
            @signal_events[parent_to_delete.signal].delete(parent_to_delete)
            @events_to_process.delete(parent_to_delete)
            if !@insert_point_observable.nil? and @insert_point_observable.include?(parent_to_delete)
                @insert_point_observable = nil
            end
        end

        def backtrack wrong_event
            @logger.info("Backtracking event (#{wrong_event.signal.name},#{wrong_event.timestamp},#{wrong_event.value})") if $VERBOSE

            # if wrong_event.signal.name == "Xor2840" #!DEBUG
            #     pp 'here'
            # end

            if wrong_event.signal.instance_of?(Netlist::Port) and wrong_event.signal.is_global? and wrong_event.signal.is_output?
                wrong_event.forbidden << Decision.new(*wrong_event) # * Event contradicts itself -> ends the research
            else

                if wrong_event.parent.children.nil?
                    raise "Error : parent #{wrong_event.parent.get_printable} of event #{wrong_event.get_printable} has no children, backtracking impossible (circuit #{@netlist.name})."
                end

                wrong_decision = wrong_event.parent.children
                wrong_decision.events.each do |e|
                    recursive_transitions_deletion(e)
                end
                wrong_decision.parent.children = nil
                # TODO : Ajouter la décision responsable du backtrack aux décisions interdites
                wrong_decision.parent.forbidden << wrong_decision
                # TODO : Supprimer les forbidden decisions pour cette décision
                wrong_decision.events.each{|e| e.children = nil; e.possible = []} # Remove reference to garbage the events resulting of the decision deleted  
                if wrong_decision.events == @insert_point_observable
                    @insert_point_observable = nil
                end
    
                # TODO : Retourner la dernière transition
                @events_to_process << wrong_decision.parent
            end
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
                @logger.info("Backpropagating event (#{e.signal.name},#{e.timestamp},#{e.value})") if $VERBOSE

                g = e.signal

                # if g.name == "Xor2840" and e.timestamp == 1 and e.value == :S0 #!DEBUG
                #     pp 'here'
                # end

                # * If g is not a primary INPUT
                if !(g.instance_of? Netlist::Port and g.is_global? and g.is_input?)
                    e_inputs = compute_transitions(e)

                    if e_inputs.nil? or e_inputs == [nil] or e_inputs == :conflict
                        # ! Infinity loop cause by this part
                        # ? Return a keyword (symbol) in compute_transitions indicating an event on the same signal is causing an absence of solution

                        backtrack(e)

                        # events_with_possibilities = @signal_events[g].select{|x| x != e and !x.possible.empty? and !x.children.nil?}
                        # if events_with_possibilities.empty? or e_inputs != :conflict
                        #         backtrack(e)
                        # elsif e_inputs == :conflict
                        #     if events_with_possibilities.empty?
                        #         raise "Error : Conflict with no signal encountered for event #{e.get_printable}"
                        #     end

                        #     # Explore all branches of other signals
                        #     # e.forbidden = []
                        #     e.possible = []

                        #     events_with_possibilities.each do |same_sig_event|
                        #         # if @signal_events[same_sig_event.children.events[0].signal].include?(same_sig_event.children.events[0])
                        #         backtrack(same_sig_event.children.events[0])
                        #         # end
                        #     end

                        #     # if e.is_non_stable_transition?
                        #         @events_to_process << e
                        #     # end 
                        # end
                    else
                        new_decision = Decision.new(*e_inputs)
                        if e.children.nil?
                            e.children = new_decision
                        else
                            raise "Error : children already defined for event #{e}"
                        end

                        if e_inputs.length == 2 and e_inputs[0].match? e_inputs[1]
                            e_inputs = [e_inputs[0]]
                        end

                        if e_inputs.all?{|x| x.signal.tag == :target_path} or e_inputs.none?{|x| x.signal.tag == :target_path}
                            e_inputs.sort_by{|x| x.signal.cumulated_propag_time}.each do |x|
                                if @signal_events[x.signal].none?{|y| y.match? x}
                                    @events_to_process << x
                                end
                            end
                        elsif e_inputs.any?{|x| x.signal.tag == :target_path}
                            e_inputs.sort_by{|x| x.signal.tag.to_s}.each do |x|
                                if @signal_events[x.signal].none?{|y| y.match? x}
                                    @events_to_process << x
                                end
                            end
                        else
                            raise "Error : Unexpected situation encountered."
                        end
                        
                        @logger.info("Decided of #{new_decision.get_printable_events}") if $VERBOSE
                        e_inputs.each do |x| 
                            if @signal_events[x.signal].none?{|y| y.match? x}
                                @signal_events[x.signal] << x
                            end
                        end

                        concerned_signals = []

                        e_inputs.select{|x| }
                        e_inputs.each do |x|
                            if x.is_non_stable_transition?
                                if x.signal.instance_of? Netlist::Port 
                                    if x.signal.is_global? and x.signal.is_input? 
                                        concerned_signals += x.signal.get_sinks
                                    end
                                else
                                    concerned_signals += x.signal.get_output.get_sinks
                                end
                            end
                        end
                        if concerned_signals.include? @insert_point and @insert_point_observable.nil?
                            @insert_point_observable = e_inputs
                        end
                    end
                end

                if @events_to_process.empty? or @events_to_process == [nil]  and !get_inputs_events.empty? and !e.forbidden.any?{|d| d.include?(e)}# * Should break the while, before check inputs

                    # ! What about partial solutions, some inputs will be set by default to a certain value eventually causing refusal even if the partial solution was right.
                    test_vec_couple = convert_events2vectors(get_inputs_events)
                    # if test_vec_couple.include?('%0*b' % [8, 42])# or test_vec_couple.include?(('%0*b' % [8, 42]).reverse) #!DEBUG
                    #     pp 'here'
                    # end
                    
                    # ! Replace X values by another to avoid forbidden_vectors
                    test_vec_couple = avoid_forbidden_vector2(test_vec_couple)

                    if test_vec_couple.nil? # forbidden_vector encountered
                        @logger.info("Forbidden vector computed, backtrack required") if $VERBOSE
                        
                        # ! If other possibilities exists for some inputs, try backtracking these ones
                        inputs_events_changeable = get_inputs_events#.select{|x| !x.parent.possible.empty? and !x.is_non_stable_transition?}

                        # if inputs_events_changeable.empty?
                        #     backtrack(e)
                        # else
                            # backtrack(inputs_events_changeable.group_by{|x| x.signal}.first[1].first)
                            inputs_events_changeable.group_by{|x| x.signal}.first[1].each do |x|
                                if @signal_events[x.signal].include?(x)
                                    backtrack(x)
                                end
                            end
                        # end
                        # backtrack(e)
                    end

                    @computed_couple = test_vec_couple
                end
            end
        end 

        def get_observable_signals event            
            get_observable_signals(event.parent) unless event.parent.nil?
            if event.signal.instance_of? Netlist::Port
                @observables += event.signal.get_sinks
            else
                @observables += (event.signal.get_output.get_sinks - @netlist.get_outputs)
            end
        end

        def is_fixed_transitions_compatible? events, gate
            # * : 'events' compatibility with each other
            if events.length > 1
                if (events[0].signal == events[1].signal) and (events[0].timestamp == events[1].timestamp) and (events[0].value != events[1].value)
                    return false
                end
            end

            # ! : Necessary for inertial integer delay model
            # * : 'events' compatibility with fixed transitions
    # ! : The following constraints are necessary for inertial integer delay model  
            # * : Value incompatibility (same timestamp)
            events.each do |event|
                event_list = @signal_events[event.signal]

                # * Different timestamp and incompatible value (resulting state of the earliest transition)
                # Value incompatibility : Latest fixed transition results in a value which make impossible the proposed transition
                previous_event = Event.new(nil,0.0,nil,nil)
                next_event = nil
                event_list.sort_by{|e| e.timestamp}.each do |e| 
                    if e == event
                        next
                    end
                    if e.timestamp < event.timestamp and e.timestamp > previous_event.timestamp
                        previous_event = e
                    end
                    if e.timestamp > event.timestamp
                        next_event = e
                        break
                    end
                end

                previous_gate = event.signal
                if !previous_event.signal.nil? 
                    if previous_event.afterward_value != event.previous_value and (previous_event.timestamp+1 == event.timestamp)
                        return false
                    end
                end
                if !next_event.nil?
                    if event.afterward_value != next_event.previous_value and (event.timestamp+1 == next_event.timestamp)
                        return false
                    end
                end
            end

            return true
        end

        def compute_transitions event, input_transition = nil
            # * : Compute the expected transition at the output and the deducted transition at the inputs
            # * : Optionnally an input transition is given, then the computation is easier
            # * : Decision is made regarding registered forbidden values

            # * : Constraints : Allows the insert point to control the output alone, Is not conflicting with already fixed transitions, Is possible with previous gate inertial delay, is not in forbidden transitions 

            # TODO : récupérer les transitions applicable aux entrées de la porte pour obtenir cette transition en sortie
            gate = event.signal

            if gate.instance_of? Netlist::Port and gate.is_global? and gate.is_output? 
                wire_event = Event.new(gate.get_source_comp, event.timestamp, event.value, event)
                if event.forbidden.any?{|f| f.one_match? wire_event}
                    return nil
                else
                    if is_convertible?(get_inputs_events + [wire_event])
                        return [wire_event]
                    else 
                        return nil
                    end
                end
            end

            # * : Check if possible events have already been computed then avoid doing again
            # if event.possible.empty?
                possible_inputs_transitions = gate.get_input_transition(event.value)

                possible_inputs_events = get_event_list(possible_inputs_transitions, event)
            # else
            #     possible_inputs_events = event.possible
            # end

            # * Check if some transitions are not compatible with the current fixed transitions
            possible_inputs_events.select! do |proposed_events|
                proposed_events.none? do |proposed_event|
                    @signal_events[proposed_event.signal].any? do |fixed_event|
                        fixed_event.timestamp == proposed_event.timestamp and fixed_event.value != proposed_event.value
                    end
                end
            end

            possible_inputs_events.select! do |proposed_events|
                new_input_events = proposed_events.select{|e| e.signal.instance_of?(Netlist::Port) and e.signal.is_global? and e.signal.is_input?}
                
                if new_input_events.empty?
                    true
                else
                    is_convertible?(get_inputs_events + new_input_events)
                end
            end

            if possible_inputs_events.empty?
                return :conflict
            else
                not_yet_empty = true
            end

            possible_inputs_events.select! do |proposed_events|
                !is_forbidden?(proposed_events, event)
            end

            if not_yet_empty and possible_inputs_events.empty?
                return :conflict
            end

            if @insert_point_observable.nil?
                possible_inputs_transitions = target_path_controlling2(possible_inputs_events, event.signal)
            end

            possible_inputs_events.each do |proposed_events|
                if is_fixed_transitions_compatible?(proposed_events, gate)
                    if event.possible.empty?
                        event.possible = possible_inputs_events - [proposed_events]
                    else
                        event.possible -= [proposed_events]
                    end
                    return proposed_events
                end
            end

            # TODO : la boucle est terminée et aucune transition n'a été validée -> lancer un backtracking 
            return nil
        end

        def target_path_controlling events, gate
            # ! Opti : Directly compute the right transitions using a method or an attribute of gate
            if gate.instance_of? Netlist::Not or gate.instance_of? Netlist::Buffer
                return events
                # ! En théorie, si la porte source est taggée target_path, alors l'évènement en entrée de gate est forcément non stable car gate est aussi sur le target_path
            else
                is_target_path = [gate.get_source_gates[0].tag == :target_path, gate.get_source_gates[1].tag == :target_path]
                events.select! do |inputs_event|
                    inputs_value = [inputs_event[0].value, inputs_event[1].value]
                    if (!is_target_path[0] and !is_target_path[1])
                        true
                    elsif is_target_path[0] and is_target_path[1]
                        if inputs_event[0].is_non_stable_transition?
                            if inputs_event[1].is_non_stable_transition?
                                if gate.instance_of? Netlist::Xor2
                                    true # Two non stable transitions at the input of a XOR always make a inserted delay detectable
                                elsif inputs_value[0] == inputs_value[1] 
                                    inputs_value[0] == gate.same_transition_detectable # Two identical non stable transitions only detectable for certain values depending of the gate type 
                                elsif inputs_value[0] != inputs_value[1]
                                    inputs_value[0] == gate.opposite_transition_detectable # Two opposite non stable transitions only detectable for certain values depending of the gate type 
                                else
                                    raise "Error : Impossible situation encountered"
                                end
                            else
                                inputs_value[1] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                            end
                        elsif inputs_event[1].is_non_stable_transition?
                            inputs_value[0] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                        else
                            non_stable_transition_on?(gate.get_source_gates[0]) or non_stable_transition_on?(gate.get_source_gates[1]) # Both inputs are stable, not any non stable transition propagated
                        end
                    elsif is_target_path[0] 
                        if inputs_event[0].is_non_stable_transition?
                            if inputs_event[1].is_non_stable_transition?
                                if gate.instance_of? Netlist::Xor2
                                    true # Two non stable transitions at the input of a XOR always make a inserted delay detectable
                                elsif inputs_value[0] == inputs_value[1] 
                                    inputs_value[0] == gate.same_transition_detectable # Two identical non stable transitions only detectable for certain values depending of the gate type 
                                elsif inputs_value[0] != inputs_value[1]
                                    inputs_value[0] == gate.opposite_transition_detectable # Two opposite non stable transitions only detectable for certain values depending of the gate type 
                                else
                                    raise "Error : Impossible situation encountered"
                                end
                            else
                                inputs_value[1] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                            end
                        elsif inputs_event[1].is_non_stable_transition?
                            # If the non stable transition is not on the target path, it is not propagated
                            # ! What if it is a second pass on this gate and a non stable transition is already backpropagated on the target path ? Should we care about it ? Or is everything true/possible ?
                            non_stable_transition_on?(gate.get_source_gates[0])
                        else
                            non_stable_transition_on?(gate.get_source_gates[0]) or non_stable_transition_on?(gate.get_source_gates[1]) # Both inputs are stable, not any non stable transition propagated
                        end
                    elsif is_target_path[1] 
                        if inputs_event[1].is_non_stable_transition?
                            if inputs_event[0].is_non_stable_transition?
                                if gate.instance_of? Netlist::Xor2
                                    true # Two non stable transitions at the input of a XOR always make a inserted delay detectable
                                elsif inputs_value[1] == inputs_value[0] 
                                    inputs_value[1] == gate.same_transition_detectable # Two identical non stable transitions only detectable for certain values depending of the gate type 
                                elsif inputs_value[1] != inputs_value[0]
                                    inputs_value[1] == gate.opposite_transition_detectable # Two opposite non stable transitions only detectable for certain values depending of the gate type 
                                else
                                    raise "Error : Impossible situation encountered"
                                end
                            else
                                inputs_value[0] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                            end
                        elsif inputs_event[0].is_non_stable_transition?
                            # If the non stable transition is not on the target path, it is not propagated
                            # ! What if it is a second pass on this gate and a non stable transition is already backpropagated on the target path ? Should we care about it ? Or is everything true/possible ?
                            non_stable_transition_on?(gate.get_source_gates[1])
                        else
                            non_stable_transition_on?(gate.get_source_gates[0]) or non_stable_transition_on?(gate.get_source_gates[1]) # Both inputs are stable, not any non stable transition proapgated
                        end
                    else
                        raise "Error : Unexpected situation not handled"
                    end
                end

                return events
            end
        end

        def target_path_controlling2 events, gate
            # ! Opti : Directly compute the right transitions using a method or an attribute of gate
            if gate.instance_of? Netlist::Not or gate.instance_of? Netlist::Buffer
                return events
                # ! En théorie, si la porte source est taggée target_path, alors l'évènement en entrée de gate est forcément non stable car gate est aussi sur le target_path
                # events.select! do |inputs_event|
                #     if gate.get_source_gates[0].tag == :target_path # * Si la porte source fait partie du chemin de contrôle (target_path)
                #         non_stable_transition_on? gate.get_source_gates[0] or [:R,:F].include? inputs_event[0].value
                #     else
                #         true
                #     end
                # end
            else
                is_target_path = [gate.get_source_gates[0].tag == :target_path, gate.get_source_gates[1].tag == :target_path]

                if is_target_path.all?{|x| x}
                    if gate.get_source_gates[0].cumulated_propag_time > gate.get_source_gates[1].cumulated_propag_time
                        is_target_path[1] = false 
                    else
                        is_target_path[0] = false
                    end
                end

                if (!is_target_path[0] and !is_target_path[1])
                    return events
                else
                    events.select! do |inputs_event|
                        inputs_value = [inputs_event[0].value, inputs_event[1].value]
                        if is_target_path[0] and is_target_path[1]
                            # raise "Error: More than one path tagged as target_path, unexpected situation."
                            if inputs_event[0].is_non_stable_transition?
                                if gate.instance_of? Netlist::Xor2
                                    true # Two non stable transitions at the input of a XOR always make a inserted delay detectable
                                elsif inputs_event[1].is_non_stable_transition?
                                    if inputs_value[0] == inputs_value[1] 
                                        gate.get_source_gates[0] == gate.get_source_gates[1]
                                        # inputs_value[0] == gate.same_transition_detectable # Two identical non stable transitions only detectable for certain values depending of the gate type 
                                    elsif inputs_value[0] != inputs_value[1]
                                        false
                                        # true # Two opposite non stable transitions only detectable for certain values depending of the gate type 
                                    else
                                        raise "Error : Impossible situation encountered"
                                    end
                                else
                                    inputs_value[1] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                                end
                            elsif inputs_event[1].is_non_stable_transition?
                                if gate.instance_of? Netlist::Xor2
                                    true # Two non stable transitions at the input of a XOR always make a inserted delay detectable
                                else
                                    inputs_value[0] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                                end
                            else
                                non_stable_transition_on?(gate.get_source_gates[0]) or non_stable_transition_on?(gate.get_source_gates[1]) # Both inputs are stable, 0 non stable transition propagated
                            end
                        elsif is_target_path[0] 
                            if inputs_event[0].is_non_stable_transition?
                                if gate.instance_of? Netlist::Xor2
                                    true # Two non stable transitions at the input of a XOR always make a inserted delay detectable
                                elsif inputs_event[1].is_non_stable_transition?
                                    if inputs_value[0] == inputs_value[1] 
                                        inputs_value[0] == gate.same_transition_detectable # Two identical non stable transitions only detectable for certain values depending of the gate type 
                                    elsif inputs_value[0] != inputs_value[1]
                                        inputs_value[0] == gate.opposite_transition_detectable # Two opposite non stable transitions only detectable for certain values depending of the gate type 
                                    else
                                        raise "Error : Impossible situation encountered"
                                    end
                                else
                                    inputs_value[1] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                                end
                            elsif inputs_event[1].is_non_stable_transition?
                                # If the non stable transition is not on the target path, it is not propagated
                                # ! What if it is a second pass on this gate and a non stable transition is already backpropagated on the target path ? Should we care about it ? Or is everything true/possible ?
                                non_stable_transition_on?(gate.get_source_gates[0])
                            else
                                non_stable_transition_on?(gate.get_source_gates[0]) or non_stable_transition_on?(gate.get_source_gates[1]) # Both inputs are stable, not any non stable transition propagated
                            end
                        elsif is_target_path[1] 
                            if inputs_event[1].is_non_stable_transition?
                                if gate.instance_of? Netlist::Xor2
                                    true # Two non stable transitions at the input of a XOR always make a inserted delay detectable
                                elsif inputs_event[0].is_non_stable_transition?
                                    if inputs_value[1] == inputs_value[0] 
                                        inputs_value[1] == gate.same_transition_detectable # Two identical non stable transitions only detectable for certain values depending of the gate type 
                                    elsif inputs_value[1] != inputs_value[0]
                                        inputs_value[1] == gate.opposite_transition_detectable # Two opposite non stable transitions only detectable for certain values depending of the gate type 
                                    else
                                        raise "Error : Impossible situation encountered"
                                    end
                                else
                                    inputs_value[0] != gate.controlling_value # Non stable transition on target path will be propagated only if the value at the other input is not the controlling value
                                end
                            elsif inputs_event[0].is_non_stable_transition?
                                # If the non stable transition is not on the target path, it is not propagated
                                # ! What if it is a second pass on this gate and a non stable transition is already backpropagated on the target path ? Should we care about it ? Or is everything true/possible ?
                                non_stable_transition_on?(gate.get_source_gates[1])
                            else
                                non_stable_transition_on?(gate.get_source_gates[0]) or non_stable_transition_on?(gate.get_source_gates[1]) # Both inputs are stable, not any non stable transition proapgated
                            end
                        else
                            raise "Error : Unexpected situation not handled"
                        end
                    end
                end
                
                return events
            end
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
        end

        def non_stable_transition_on? signal
            @signal_events[signal].flatten.any? do |e|
                [:R,:F].include?(e.value)
            end
        end
        
        def replace_X_values2 v # vector, forbidden_vector
            x_index = v.each_index.select{|e| v[e]=="X"}

            @forbidden_vectors.each do |fv| # forbidden vector
                fv = fv.chars

                if v.zip(fv).none?{|e| e[0] != e[1]}
                    return nil
                end
            end

            if !x_index.empty?
                x_possibilities = ["0","1"].repeated_combination(x_index.length).to_a
                possibilities = x_possibilities.collect do |x|
                    tmp = v.dup
                    x_index.each_with_index do |i, j|
                        tmp[i] = x[j]
                    end
                    tmp.join
                end.to_set

                possibilities -= @forbidden_vectors 
                return possibilities.first
            else
                return v.join
            end
        end

        def avoid_forbidden_vector2(test_vec_couple)
            ov = test_vec_couple[0].chars # original vector
            av = test_vec_couple[1].chars # arrival vector

            ov = replace_X_values2(ov) 
            av = replace_X_values2(av)

            if ov.nil? or av.nil?
                return nil
            else
                return ov, av
            end
        end

        def is_convertible? event_list
            non_stable_event_list = event_list.select{|e| e.is_non_stable_transition?}
            
            # ! Not necessary anymore knowing only one non stable transition can be fixed on a given signal (new algorithm of target_path_controlling)
            if non_stable_event_list.empty?
                return true
                # return false #!DEBUG
            end

            ref = non_stable_event_list[0].timestamp
            if non_stable_event_list.any?{|e| e.timestamp != ref}
                return false
            end

            event_list.each do |e| # ! Opti : Possible d'éviter des vérifications doublons entre certains évènements sur le même signal
                @signal_events[e.signal].each do |e2|
                    if e == e2 # Opti
                        next
                    elsif e.timestamp == ref 
                        if e2.timestamp > ref
                            if e.afterward_value != e2.previous_value
                                return false
                            end
                        elsif e2.timestamp < ref
                            if e2.afterward_value != e.previous_value
                                return false
                            end
                        end
                    elsif e2.timestamp == ref
                        if e.timestamp > ref
                            if e2.afterward_value != e.previous_value 
                                return false
                            end
                        elsif e.timestamp < ref
                            if e.afterward_value != e2.previous_value 
                                return false
                            end
                        end
                    elsif ((e.timestamp < ref and e2.timestamp < ref) or (e.timestamp > ref and e2.timestamp > ref)) and e.value != e2.value 
                        return false
                    end
                end
            end

            return true
        end

        def convert_events2vectors input_events
            # * Converts an event list into a couple test vectors.
            # ! Events must be convertible (see is_convertible?) 
            if input_events.empty?
                raise "Error : No events passed, can't convert empty array into vectors."
            elsif !is_convertible?(input_events)
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

            if transition_instant.nil?
                # if input_events.none?{|e| e.is_non_stable_transition?}
                    raise "Error : Only stable transitions at the inputs. Circuit : #{@netlist.name}, input_events : #{input_events.collect{|e| e.get_printable}}"
                # end
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
                        origin_vector[e.signal] = "0"
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
                    origin_vector[in_p] = "X" # ! Default value, can be changed to "X" if necessary
                    arrival_vector[in_p] = "X" # ! Default value, can be changed to "X" if necessary
                end
            end

            # TODO : s'il manque des valeurs dans un des deux vecteurs (don't care) remplir avec la même valeur que dans l'autre vecteur  
            # ! Default values, different policy can lead to many other possibilities
            input_events.collect{|e| e.signal}.uniq.each do |in_p|
                if !origin_vector.include?(in_p)
                    origin_vector[in_p] = "X"
                elsif !arrival_vector.include?(in_p)
                    arrival_vector[in_p] = "X"
                end
            end

            origin_vector = origin_vector.sort_by{|signal, value| signal.name[1..].to_i}.collect{|e| e[1]}.join
            arrival_vector = arrival_vector.sort_by{|signal, value| signal.name[1..].to_i}.collect{|e| e[1]}.join

            return origin_vector.reverse, arrival_vector.reverse
        end     

        def get_inputs_events
            return @netlist.get_inputs.collect{|in_p| @signal_events[in_p]}.flatten
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
            src << "# Stimuli sequence;#{bin_stim_vec ? "bin" : "dec"};#{@netlist.get_inputs.length};explicit"
            src << "# Unobservables : #{@unobservables.length}" 

            stim_pair_rh = stim_pair_h.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(insert_point, solution), result|
                solution.each do |targeted_transition, vectors|
                    signal = targeted_transition.signal
                    result[vectors] << [insert_point, signal]
                end
                # signal = solution.keys[0].signal
                # vectors = solution.values[0]
            end

            stim_pair_rh.each do |vectors, target|
                src << "# " + (target.collect{|insert_point, output| "s=#{insert_point.get_full_name}, o=#{output.get_full_name}"}.join("; "))
                repetition.times do |i|
                    vectors.each do |vec|
                        if !vec.nil?
                            if bin_stim_vec 
                                src << vec
                            else
                                src << vec.to_i(2)
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
            # src << "# Stimuli sequence"
            src << "# Stimuli sequence;#{bin_stim_vec ? "bin" : "dec"};#{@netlist.get_inputs.length}"

            vec_list.each do |vec|
                if !vec.nil? 
                    if bin_stim_vec 
                        src << vec
                    else
                        src << vec.to_i(2)
                    end
                else 
                    raise "Error : nil test vector encountered."
                end
            end 

            src.save_as path
        end

        def get_printable_last_decision
            @transitions.last.get_printable_events
        end 
    end
end