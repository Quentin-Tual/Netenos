module Converter

    # Transition = Struct.new(:timestamp, :value)
    Event = Struct.new(:signal, :timestamp, :value, :parent) do 
        def match? event
           return ((event.signal == signal) and (event.timestamp == timestamp) and (event.value == value))
        end

        # def pretty_print q
        #     puts "#<Event: signal=#{signal.name}, timestamp=#{timestamp}, value=#{value}}>"
        # end

        def closest_inferior_timestamp events
            events.select{|e| e.timestamp <= timestamp}.min_by{|e| (e.timestamp - timestamp).abs}
        end

        def boolean_value
            case value
            when "R", "1"
                "1"
            when "F", "0"
                "0"
            else
                raise "Error : Unknown transition value encountered. Cannot obtain boolean equivalence."
            end
        end
    end

    class ComputeStim
        attr_accessor :decisions, :transitions
        attr_reader :side_inputs, :stim_vec, :events_computed

        def initialize netlist, delay_model
            @netlist = netlist
            @delay_model = delay_model
            @netlist.getNetlistInformations delay_model
            @side_inputs = []
            @transitions = []
            # @decisions = []
            @forbidden_transitions = [] #Hash.new([]) # Associates a stack of gate/transition pairs to one gate/decision pair, one key for each decision
            # @decisions_steps = Hash.new([])
            @events_to_process = []#Hash.new { |hash, key| hash[key]=[] }
        end

        def get_insertion_points payload_delay
            # * Returns a list of gate which outputs has a slack greater than the payload delay 
            slack_h = @netlist.get_slack_hash @delay_model
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
            @side_inputs = []
            @transitions = []
            # @decisions = []
            @forbidden_transitions = [] #Hash.new([]) # Associates a stack of gate/transition pairs to one gate/decision pair, one key for each decision
            # @decisions_steps = Hash.new([])
            @events_to_process = []
            # @netlist.components.each{|comp| comp.tag = nil}
        end

        def generate_stim netlist=nil, ht="og_s38417"
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
                    ["R","F"].each do |transition|
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
                            next
                        end
                    end

                    if res == :success
                        @events_computed[insert_point][targeted_transition] = tmp
                        break
                    else
                        next
                    end
                end

                if @events_computed[insert_point].empty?
                    # raise "Error : Insertion point #{insert_point.name} not observable on any output."
                    pp "Insertion point #{insert_point.get_full_name} not observable on any output."
                end
                @netlist.components.each{|comp| comp.tag = nil}
                @netlist.get_inputs.each{|in_p| in_p.tag = nil}
            end

            @events_computed.delete_if{|insert_point, solution| solution.empty?}

            # TODO : Déterminer les vecteurs synchrones pour chaque cas(feuille de l'arbre) de @events_computed. Possible de le faire au cas par cas.
            stim_pair = []
            # TODO : Pour chaque signal à risque calculer un couple de vecteurs 
            @events_computed.each do |insert_point, solution|
                stim_pair << convert_events2vectors(solution.values[0])
            end

            # TODO : Transformer les couples de vecteurs en une suite de vecteurs unique 
            # @stim_vec = stim_pair.uniq.flatten 
            @stim_vec = stim_pair.flatten#!DEBUG
            # pp "test" #!DEBUG
            return @stim_vec
        end

        def compute event, insertion_point
            @transitions << [event]
            backpropagate2([event])
            if @forbidden_transitions.last == event
                # if @forbidden_transitions.length > 1 #!DEBUG
                #     pp "unexpected"
                # end
                return :impossible
            else
                return :success
            end
        end

        def recursive_transitions_deletion parent_to_be_deleted
            transitions_to_delete = []

            @transitions.each do |t|
                # if t.any?{|e| (!e.parent.nil?) and (e.signal.name == "Not8780" or e.parent.signal.name == "Or29280")} #!DEBUG
                #     pp "here"
                # end
                if t.any?{|e| e.parent == parent_to_be_deleted}
                    t.map{|e| recursive_transitions_deletion(e)}
                    # @forbidden_transitions.each do |e|
                    #     # if e.signal.name == "Not8780" #!DEBUG
                    #     #     pp "here"
                    #     # end
                    #     if e.parent.match? parent_to_be_deleted
                    #         @forbidden_transitions.delete(e)
                    #     end
                    # end
                    transitions_to_delete << t
                end
                @forbidden_transitions.each do |e|
                    # if e.signal.name == "Not8780" #!DEBUG
                    #     pp "here"
                    # end
                    if e.parent.match? parent_to_be_deleted
                        @forbidden_transitions.delete(e)
                    end
                end
            end

            transitions_to_delete.each{|t| @transitions.delete(t)}
        end

        def backtrack wrong_transition
            # if wrong_transition.signal.name == "Xor29380"  #!DEBUG
            #     pp "here"
            # end
            wrong_event = @transitions.select{|e| e.include? wrong_transition}[0]
            wrong_event.each{|e| recursive_transitions_deletion(e)}
            @transitions.delete(wrong_event)
            # TODO : Supprimer les forbidden decisions pour cette décision
            @forbidden_transitions.delete_if do |e|
                wrong_event.any?{|x| x.match? e.parent}
            end

            @events_to_process.delete_if do |e|
                e.parent == wrong_transition.parent
            end
            
            # print "Backtracking :" #!DEBUG
            # pp wrong_transition.signal

            # TODO : Ajouter la décision responsable du backtrack aux décisions interdites
            @forbidden_transitions << wrong_transition

            # TODO : Retourner la dernière transition
            @events_to_process << wrong_transition.parent
        end

        def backpropagate2 event
            
            if @events_to_process.empty?
                @events_to_process = [event].flatten
            else
                @events_to_process << event
                @events_to_process.flatten!
            end
            
            while !@events_to_process.empty? and @events_to_process != [nil]
                # last_choice = get_last_choice
                e = @events_to_process.pop 
                if e.nil?
                    raise "Error : nil event encountered"
                end 

                # print "Backpropagate :" #!DEBUG
                # pp e.signal

                g = e.signal

                # * If g is a primary INPUT
                if g.instance_of? Netlist::Port and g.is_global? and g.is_input?
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
             
                if !(@transitions.include? e_inputs) 
                    # * Push in order to process at first the target path 
                    @events_to_process << e_inputs.sort_by{|e| e.signal.tag.to_s}
                    @events_to_process.flatten!
                    
                    @transitions << e_inputs
                end
            end

        end 

        # def is_forbidden? transition
        #     # TODO : Vérifier que la transition ne se trouve pas dans les forbidden transitions
        #     @forbidden_transitions >= transition 
        # end

        def is_fixed_transitions_compatible? events
            # TODO : Vérifier que les events n'entrent pas en contradiction entre eux
            if events.permutation(2).any?{|x,y| x.signal == y.signal and x.timestamp == y.timestamp and x.value != y.value}
                return false
            end

            # TODO : Vérifier que le signal concerné ne possède pas de transitions incompatibles
            # Same timestamp and different value
            events.each do |event|
                event_list = @transitions.flatten.select{|fixed_event| fixed_event.signal == event.signal}

                # Value incompatibility : Same timestamp different value
                event_list.each do |fixed_event|
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
                    if e.timestamp <= event.timestamp and e.timestamp > previous_event.timestamp
                        previous_event = e
                    end
                    if e.timestamp > event.timestamp
                        next_event = e
                        break
                    end
                end

                if !previous_event.signal.nil?
                    values = [previous_event.value, event.value]
                    case values
                    when ["R","R"], ["F","F"]
                        return false
                    when ["1","R"]
                        return false
                    when ["0", "F"]
                        return false
                    when ["R", "0"]
                        return false
                    when ["F", "1"]
                        return false
                    end
                end

                if !next_event.nil?
                    values = [event.value, next_event.value]
                    case values
                    when ["R","R"], ["F","F"]
                        return false
                    when ["1","R"]
                        return false
                    when ["0", "F"]
                        return false
                    when ["R", "0"]
                        return false
                    when ["F", "1"]
                        return false
                    end
                end
                 
                # Inertial Delay Incompatibility : An existing transition is too close from the proposed one, impossible according to inertial delay model

                # TODO : Pour chaque sink gate de 'event.signal'
                    # TODO : Si le délai inertiel de la sink gate entre la transition précédente et la transition proposée ou entre la transition proposée et la transition suivante est trop faible
                        # TODO : retourner False
                    # TODO : Sinon
                        # TODO : retouner True
                        
                event.signal.get_sink_gates.each do |sink|
                    if sink.instance_of? Netlist::Port and sink.is_global?
                        next
                    else 
                        if !previous_event.signal.nil? and (event.timestamp - previous_event.timestamp) < sink.propag_time[@delay_model] and !previous_event.match? event
                            return false
                        end
                        if !next_event.nil? and (next_event.timestamp - event.timestamp) < sink.propag_time[@delay_model] and !next_event.match? event
                            return false
                        end
                    end
                end
            end

            return true
        end
        
        def verify_transition *events
            # TODO : Vérifier que la transition est valide compte tenu des décisions précédentes
            new_input_events = events.select{|e| e.signal.instance_of? Netlist::Port and e.signal.is_global? and e.signal.is_input?}
            if !new_input_events.empty?
                convertible = is_convertible?(get_inputs_events + new_input_events)
            else 
                convertible = true
            end
            return (!(@forbidden_transitions.flatten(1).any?{|decision| events.include? decision}) and is_fixed_transitions_compatible?(events) and convertible)
            # if !new_input_events.empty?
            #     return (tmp and is_convertible?(get_inputs_events + new_input_events))
            # else
            #     return tmp 
            # end
        end

        def compute_transitions event, input_transition = nil
            # * : Compute the expected transition at the output and the deducted transition at the inputs
            # * : Optionnally an input transition is given, then the computation is easier
            # * : Decision is made regarding registered forbidden values

            # TODO : récupérer les transitions applicable aux entrées de la porte pour obtenir cette transition en sortie
            gate = event.signal

            if gate.instance_of? Netlist::Port and gate.is_global? and gate.is_output? 
                wire_event = Event.new(gate.get_source_comp, event.timestamp, event.value, event)
                if @forbidden_transitions.include? wire_event
                    return nil
                else
                    return [wire_event]
                end
            end

            possible_inputs_transitions = gate.get_input_transition event.value
            input_transition_time = event.timestamp - gate.propag_time[@delay_model]

            # if possible_inputs_transitions.nil? or possible_inputs_transitions.include? nil
            #     raise "HERE" #!DEBUG
            # end

            if gate.instance_of? Netlist::Not
                possible_inputs_transitions.select! do |inputs_transition|
                    (gate.get_source_gates[0].tag == :target_path and (["R","F"].include? inputs_transition[0] or non_stable_transition_on? gate.get_source_gates[0])) or (gate.get_source_gates[0].tag != :target_path)
                end
            else
                possible_inputs_transitions.select! do |inputs_transition|
                    (gate.get_source_gates[0].tag == :target_path and (["R","F"].include? inputs_transition[0] or non_stable_transition_on? gate.get_source_gates[0])) or (gate.get_source_gates[1].tag == :target_path and (["R","F"].include? inputs_transition[1] or non_stable_transition_on? gate.get_source_gates[1])) or (gate.get_source_gates[0].tag != :target_path and gate.get_source_gates[1].tag != :target_path)
                end
            end

            # if possible_inputs_transitions.nil? or possible_inputs_transitions.include? nil
            #     raise "HERE" #!DEBUG
            # end

            # TODO : Si inputs_transitions est nil faire un choix pour les deux entrées
            if input_transition.nil?
                
                possible_inputs_transitions.each do |trans_pair|
                    i0_trans = Event.new(gate.get_source_gates[0], input_transition_time, trans_pair[0], event)
                    if !(gate.is_a? Netlist::Not) and !(gate.is_a? Netlist::Buffer)
                        i1_trans = Event.new(gate.get_source_gates[1],input_transition_time, trans_pair[1], event)
                    end
                    
                    if !(gate.is_a? Netlist::Not) and !(gate.is_a? Netlist::Buffer) 
                        if verify_transition(i0_trans, i1_trans) 
                            return [i0_trans, i1_trans]
                        end
                    else
                        if verify_transition(i0_trans) 
                            return [i0_trans]
                        end 
                    end
                end

                # TODO : la boucle est terminée et aucune transition n'a été validée -> lancer un backtracking 
                return nil
            else
            # TODO : Sinon il est au format {"i0" => {t => trans.}} et on évince les cas non compatibles (val ET timing !)
                raise "WIP"
                # TODO : S'il ne reste aucun cas -> raise une erreur
                # TODO : Sinon choisir une transition et renvoyer les transitions des deux entrées
            end
        end

        def non_stable_transition_on? signal
            @transitions.flatten.any? do |e|
                e.signal == signal and ["R","F"].include?(e.value)
            end
        end

        def is_convertible? event_list
            event_list = event_list.select{|e| ["R","F"].include? e.value}
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
                if (e.value == "R" or e.value == "F") 
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
                    when "R"
                        origin_vector[e.signal] = "0"
                        arrival_vector[e.signal] = "1"
                    when "F"
                        origin_vector[e.signal] = "1"
                        arrival_vector[e.signal] = "0"
                    when "1"
                        origin_vector[e.signal] = "1"
                        arrival_vector[e.signal] = "1"
                    when "0"
                        origin_vector[e.signal] = "0"
                        arrival_vector[e.signal] = "0"
                    else
                        raise "Error : Unknown transition value"
                    end
                elsif e.timestamp < transition_instant
                    origin_vector[e.signal] = e.value
                else
                    arrival_vector[e.signal] = e.value
                end
            end

            @netlist.get_inputs.each do |in_p|
                if (!origin_vector.include?(in_p) and !arrival_vector.include?(in_p))
                    origin_vector[in_p] = "1" # ! Default value, can be changed to "X" if necessary
                    arrival_vector[in_p] = "1" # ! Default value, can be changed to "X" if necessary
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
            return @transitions.flatten.select{|e| e.signal.instance_of? Netlist::Port and e.signal.is_input?}
        end

        def colorFixedGates
            @transitions.flatten.each do |t|
                t.signal.tag = :ht
            end
        end

        def save_vec_list path, vec_list, bin_stim_vec: false 
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