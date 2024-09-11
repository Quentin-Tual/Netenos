# ! Check if necessary to use hash as forbidden_transitions associating a fixed event as the key and banned events as the value.
# ! We could need to set the key manually after a reaching inputs and going back to another branch of the circuit/tree.

module Converter

    # Transition = Struct.new(:timestamp, :value)
    Event = Struct.new(:signal, :timestamp, :value, :parent)# do 
    #     def pretty_print(pp)
    #         pp.text "#<Converter::Event signal=#{signal.name}, timestamp=#{timestamp}, value=#{value}, parent=#{parent.nil? nil : parent.signal.name}>"
    #     end
    # end
    # Choice = Struct.new(:events, :step)
    # Decision = Struct.new(:events, :step)

    class ComputeStim
        attr_accessor :decisions, :transitions
        attr_reader :side_inputs

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

        # def backpropagate_side_inputs
        #     until @side_inputs.empty?
        #         si = @side_inputs.shift
        #         res = backpropagate(si)
        #         if res == :dead_end
        #             # TODO : Appeler revise_decision
        #         end
        #     end

        #     # TODO : Si res == :dead_end
        # end

        # def revise_decision
        #     # TODO : Tant que res = :dead_end 
        #     # ! Boucle infinie possible 
        #         # TODO : "Clean" -> ajouter le dernier choix aux décisions interdites de l'avant dernier choix, supprimer les transitions fixées jusqu'au dernier choix effectué et supprimer les forbidden_decisions associées au dernier choix
        #         # TODO : Faire
        #             # TODO : "Retry" -> res = set_target_path ou res = backpropagate sur l'avant dernier choix (dépend du tag de son signal), backpropagate étant à modifier en premier
        #         # TODO : Tant que res = :retry
            
        #     # TODO : Retourner :success 
        # end

        def get_insertion_points payload_delay
            # * Returns a list of gate which outputs has a slack greater than the payload delay 
            slack_h = @netlist.get_slack_hash @delay_model
            return slack_h.select{|slack, gate| slack >= payload_delay}.values.flatten
        end

        # ! When insertion point is a global input -> no get_sink_gates method for Netlist::Port
        def get_cone_outputs insertion_point
            # * search the output from the given insertion_point (last gate of the path)
            # * Tag each gate encountered as "target_path" 
            
            insertion_point.partof.tag = :target_path
            if insertion_point.get_source.is_global?
                insertion_point.get_source.tag = :target_path
            else
                insertion_point.get_source_comp.tag = :target_path
            end
            next_gates = insertion_point.partof.get_sink_gates
            cone_outputs = []

            until next_gates.empty?
                current_gate = next_gates.shift
                if current_gate.instance_of? Netlist::Port and current_gate.is_global? # ! If insertion point is the last gate before a primary output
                    cone_outputs << current_gate
                    next
                end
                current_gate.tag = :target_path

                primary_outputs, current_gate_sinks = current_gate.get_sink_gates.partition{|g| g.is_a? Netlist::Port and g.is_global?}
                current_gate_sinks = current_gate_sinks.select{|g| g.tag != :target_path}
                
                cone_outputs << current_gate unless primary_outputs.empty?
                next_gates += current_gate_sinks unless next_gates.include? current_gate
            end

            return cone_outputs # ! last gate of the path is considered the output, in the end we will need a table to convert a gate to the output connected 
        end

        def start event, insertion_point
            
            @transitions << [event]

            backpropagate2([event])

            if @forbidden_transitions.length == 1 and @forbidden_transitions.last == event
                return :impossible
            else
                return :success
            end
        end

        def recursive_transitions_deletion parent_to_be_deleted
            @transitions.each do |e|
                if e.any?{|x| x.parent == parent_to_be_deleted}
                    e.map{|x| recursive_transitions_deletion(x)}
                    @forbidden_transitions.each do |e|
                        if e.parent == parent_to_be_deleted
                            @forbidden_transitions.delete(e)
                        end
                    end
                    @transitions.delete(e)
                end
            end
        end

        # def recursive_forbidden_transitions_deletion parent_to_be_deleted
        #     @forbidden_transitions.each do |e|
        #         if e.parent == parent_to_be_deleted
        #             recursive_forbidden_transitions_deletion(e)
        #             @forbidden_transitions.delete(e)
        #         end
        #     end
        # end

        def backtrack wrong_transition
            
            wrong_event = @transitions.select{|e| e.include?wrong_transition}[0]
            wrong_event.each{|e| recursive_transitions_deletion(e)}
            @transitions.delete(wrong_event)
            @forbidden_transitions.delete_if do |e|
                wrong_event.include? e.parent
            end

            @events_to_process.delete_if do |e|
                e.parent == wrong_transition.parent
            end
            
            # print "Backtracking :" #!DEBUG
            # pp wrong_transition.signal

            # TODO : Supprimer les forbidden decisions pour cette décision
            # ! See notes at the top of the file
            # recursive_forbidden_transitions_deletion(wrong_transition)
            
            # TODO : Ajouter la décision responsable du backtrack aux décisions interdites
            @forbidden_transitions << wrong_transition

            # TODO : Retourner la dernière transition
            @events_to_process << wrong_transition.parent
        end

        def backpropagate2 event
            
            if @events_to_process.empty? # ! might not be the first iteration and become true during the process, check if it is a problem
                @events_to_process = [event].flatten
            else
                @events_to_process << event
                @events_to_process.flatten!
            end
            
            while !@events_to_process.empty? and @events_to_process != [nil]
                # last_choice = get_last_choice
                e = @events_to_process.pop # ! also shifts the corresponding object in @transitions leading to an empty @transitions element and errors -> Should be fixed !!! 
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
                    backtrack(e)
                    next
                end
             
                if !(@transitions.include? e_inputs) 
                    @events_to_process << e_inputs
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
            # TODO : Vérifier que la transition n'entre pas en contradiction avec d'autres transitions dans les fixed_transitions

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
                    if e.timestamp < event.timestamp and e.timestamp > previous_event.timestamp
                        previous_event = e
                    elsif e.timestamp > event.timestamp
                        next_event = e
                        break
                    end
                end

                values = Set.new([event.value, previous_event.value])
                case values
                when Set["R"], Set["F"]
                    return false
                when Set["R","1"]
                    return false
                when Set["F", "0"]
                    return false
                else 
                    
                end
                 # ! Should we accept a "0" transition directly followed by a "1" transition without a "R" in between ? same for "1" followed by "0" without a "F" -> Solution in Inertial Delay Incompatibility ? A priori not a problem, stable-0/1 are used to define a value already transitionned when one appears on the other input. Adding a "R" or a "F" a posteriori should not necessary lead to errors or incompatibilities (depends on the timestamp we use, which should be computed accordingly)

                # Inertial Delay Incompatibility : An existing transition is too close from the proposed one, impossible according to inertial delay model

                # TODO : Pour chaque sink gate de 'event.signal'
                    # TODO : Si le délai inertiel de la sink gate entre la transition précédente et la transition proposée ou entre la transition proposée et la transition suivante
                        # TODO : retourner False
                    # TODO : Sinon
                        # TODO : retouner True
                        
                event.signal.get_sink_gates.each do |sink|
                    if sink.instance_of? Netlist::Port and sink.is_global?
                        next
                    else 
                        if (event.timestamp - previous_event.timestamp) < sink.propag_time[@delay_model]
                            return false
                        elsif !next_event.nil? and (next_event.timestamp - event.timestamp) < sink.propag_time[@delay_model]
                            return false
                        end
                    end
                end
            end

            return true
        end
        
        def verify_transition *events
            # TODO : Vérifier que la transition est valide compte tenu des décisions précédentes
            return (!(@forbidden_transitions.flatten(1).any?{|decision| events.include? decision}) and self.is_fixed_transitions_compatible?(events))
        end

        def compute_transitions event, input_transition = nil
            # * : Compute the expected transition at the output and the deducted transition at the inputs
            # * : Optionnally an input transition is given, then the computation is easier
            # * : Decision is made regarding registered forbidden values

            # ? : Utiliser des tables déjà précalculées contenant tous les cas possibles ? Utilisant une arithmétique particulière avec des R et F, ce serait peut-être préférable. Sinon lambda calcul ou en dur en conditionnel dans une fonction

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

            possible_inputs_transitions = gate.get_input_transition event.value # !!! Value nil parfois, car le point d'insertion n'a aucune décision dans sa stack... ???
            input_transition_time = event.timestamp - gate.propag_time[@delay_model]

            # if possible_inputs_transitions.nil? or possible_inputs_transitions.include? nil
            #     raise "HERE" #!DEBUG
            # end

            # TODO : Evincer les transitions possibles qui ne permettent pas de conserver la controlling value sur le target path s'il y en a un.
            # if (gate.get_source_gates[0].is_a? Netlist::Gate and gate.get_source_gates[1].is_a? Netlist::Gate)
            if gate.instance_of? Netlist::Not
                possible_inputs_transitions.select! do |inputs_transition|
                    (gate.get_source_gates[0].tag == :target_path and (["R","F"].include? inputs_transition[0])) or (gate.get_source_gates[0].tag != :target_path)
                end
            else
                possible_inputs_transitions.select! do |inputs_transition|
                    (gate.get_source_gates[0].tag == :target_path and (["R","F"].include? inputs_transition[0])) or (gate.get_source_gates[1].tag == :target_path and (["R","F"].include? inputs_transition[1])) or (gate.get_source_gates[0].tag != :target_path and gate.get_source_gates[1].tag != :target_path)
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

        def compute_output_transitions gate, source_gates
            # TODO : Reprendre la fonction pour transmettre non plus toutes les transitions des portes aux entrées en sortie mais une transition donnée à une entrée à la porte suivante. Il faudra donc récupérer l'état du deuxième signal en entrée de la porte 'gate' à l'instant de la transition donnée.

            ret = nil
            
            if source_gates.length == 1
                events = source_gates[0].transitions.sort_by{|transi| transi.timestamp}
                transition_list =events.collect do |event|
                    Transition.new(event.timestamp + gate.propag_time[@delay_model], gate.get_output_transition(event.value))
                end 
                transition_list.each do |t|
                    gate.transitions << t unless gate.transitions.include? t
                end  
            else
                events = source_gates.collect do |source_g|
                    source_g.transitions.collect do |transi|
                        [source_g,transi]
                    end
                end.flatten(1)
                events.sort_by!{|e| e[1].timestamp}

                # TODO : keep track of each source value  
                state_h = source_gates.each_with_object(Hash.new){|source_g,h| h[source_g]="X"} # * "X" as a wildcard, it could be any value

                events_h = {}

                events.collect{|e| e[1].timestamp}.uniq.each do |current_timestamp| # For each different timestamps in events
                    same_time_events = events.partition do |e|
                        e[1].timestamp == current_timestamp
                    end[0]

                    # if same_time_events.length > 2 #!DEBUG
                    #     pp "Here"
                    # end
                    
                    # TODO : associer l'état en mémoire et une transition ou deux transition à un timestamp dans events_h
                    if same_time_events.length < source_gates.length 
                        # ! Only thought with 2 inputs gates  
                        gate_without_transition = source_gates.select{|g| g != same_time_events[0][0]}[0]
                        if state_h[gate_without_transition] == "X"
                            next
                        end
                        tmp = [state_h[gate_without_transition], same_time_events[0][1].value]
                        events_h[current_timestamp] = tmp
                    else
                        tmp = same_time_events.collect{|e| e[1].value}
                        if tmp.include? "X"
                            next
                        else
                            events_h[current_timestamp] = same_time_events.collect{|e| e[1].value}
                        end
                    end

                    # update state_h
                    same_time_events.each do |source_g, transition|
                        case transition.value
                        when "R","1"
                            state_h[source_g] = "1" 
                        when "F","0"
                            state_h[source_g] = "0"
                        else
                            raise "Error: Unknown transition value uncountered"
                        end
                    end
                end

                events_h.each do |timestamp, inputs_transitions|
                    t = Transition.new(
                        timestamp+gate.propag_time[@delay_model], 
                        gate.get_output_transition(inputs_transitions)
                    )

                    if verify_transition(gate,t)
                        gate.transitions << t unless gate.transitions.include? t 
                    else
                        ret = :retry
                    end
                    # gate.transitions.uniq! # same as the if include? t
                end

                # TODO : Clean the unexpected transition with inertial propagation delay
                # ! Question importante : Est-il possible que la propagation puisse mettre à jour une incompatibilité qui imposerait un backtracking ?
            end

            if ret == :retry
                return ret
            else
                return :success
            end 
        end

        def propagate gate
            # * : Le signal devrait disposer de transitions fixées à ses deux entrées si ce n'est pas le cas, il faudra réitérer après d'autres propagation

            # TODO : Condition d'arrêt -> Sortie primaire, Porte qui possède déjà une transition identique, Transition invalide (enfreint les contraintes de l'algo)
            # if gate.instance_of? Netlist::Port and gate.is_global?
            #     return :success
            # end

            res = compute_output_transitions(gate, gate.get_source_gates)

            gate.get_sink_gates.each do |sink_gate|
                if sink_gate.instance_of? Netlist::Port and sink_gate.is_global?
                    next
                else
                    propagate sink_gate
                end
            end

            return :success
        end

        # def get_last_choice
        #     n=1
        #     last_choice = @transitions[-n]
        #     while (!last_choice[0].choice) and (n < @transitions.length)
        #         n+=1
        #         last_choice = @transitions[-n]
        #     end

        #     if n==@transitions.length
        #         return nil
        #     else
        #         return last_choice
        #     end 
        # end

        def get_inputs_events
            return @transitions.flatten.select{|e| e.signal.instance_of? Netlist::Port}
        end

        def colorFixedGates
            @transitions.flatten.each do |t|
                t.signal.tag = :ht
            end
        end
    end

end