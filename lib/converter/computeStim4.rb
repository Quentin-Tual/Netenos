# ! NO recursivity version 

# ! Ajouter une gestion de @side_inputs identique à @forbidden_transitions avec un hash pour pouvoir retirer toutes les side_inputs relative à une décision que l'on souhaite supprimer

# ! Ajouter les update de main sur cette branch (merge main ?) et revenir sur l'utilisation de la slack avec la nouvelle gestion par input port.   

module Converter

    Transition = Struct.new(:timestamp, :value)
    Event = Struct.new(:signal, :timestamp, :value)
    Decision = Struct.new(:events, :step)

    class ComputeStim
        attr_accessor :decisions, :transitions
        attr_reader :side_inputs

        def initialize netlist, delay_model
            @netlist = netlist
            @delay_model = delay_model
            @netlist.getNetlistInformations delay_model
            @side_inputs = []
            @transitions = []
            @decisions = []
            @forbidden_transitions = Hash.new([]) # Associates a stack of gate/transition pairs to one gate/decision pair, one key for each decision
            @decisions_steps = Hash.new([])
            @events_to_process = []
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
            
            insertion_point.tag = :target_path
            # une file de portes à traiter que l'on actualise à chaque itération "next_gates"
            # if insertion_point.is_a? Netlist::Port and insertion_point.is_global?
            #     next_gates = insertion_point.fanin.partof
            # else
            next_gates = insertion_point.get_sink_gates
            # end
    
            # une liste de sorties primaires "cone_outputs"
            cone_outputs = []
            # une file de porte déjà traitée (évite les régressions et les doublons) "encountered_gates"
            # encountered_gates = []

            until next_gates.empty?
                current_gate = next_gates.shift
                current_gate.tag = :target_path

                primary_outputs, current_gate_sinks = current_gate.get_sink_gates.partition{|g| g.is_a? Netlist::Port and g.is_global?}
                current_gate_sinks = current_gate_sinks.select{|g| g.tag != :target_path}
                
                cone_outputs << current_gate unless primary_outputs.empty?
                next_gates += current_gate_sinks unless next_gates.include? current_gate
            end

            return cone_outputs # ! last gate of the path is considered the output, in the end we will need a table to convert a gate to the output connected 
        end

        def start event, insertion_point
            
            @decisions << Decision.new([event], :initial_condition)
            @transitions << [event]
            # @decisions_steps[[event]] |= [:initial_condition]

            step = :set_target_path2
            res = nil

            loop do
                case step
                when :set_target_path2
                    res = send step, event, insertion_point    
                when :backpropagate2
                    res = send step, event
                else
                    raise "Error: Unexpected method name encountered."
                end

                if @transitions.include? [] #!DEBUG
                    raise "AH"
                end

                # res = set_target_path2 event, insertion_point
                # TODO : Si 'res' vaut ':dead_end' alors lancer 'backtrack' et recommencer
                if res == :dead_end
                    if @decisions.last.step == :initial_condition # ! @decisions.length should be 1
                        return :impossible
                    else
                        event, step = backtrack # Only set context back to just before the last decision
                        if step == :set_target_path2
                            @side_inputs.insert(0, event.select{|e| e.signal.tag != :target_path})
                            event.select!{|e| e.signal.tag == :target_path}    
                        end

                        if event == [] #!DEBUG
                            raise "AH"
                        end
                        if @transitions.include? [] #!DEBUG
                            raise "AH"
                        end

                        next
                    end
                elsif res == :success
                    case step
                    when :set_target_path2
                        step = :backpropagate2
                        event = @side_inputs.shift
                    when :backpropagate2
                        if @side_inputs.empty?
                            break #!DEBUG
                            # TODO : Plus tard remplacer par le passage à l'étape de propagation
                        else
                            # * step keeps the same value ':backpropagate2'
                            event = @side_inputs.shift
                        end
                    when :propagate
                        raise "WIP"
                    else
                        raise "Error: Unknown 'step' value."
                    end

                    if event == [] #!DEBUG
                        raise "AH"
                    end
                end
            end
            
            return res
        end

        def backtrack
            # ! : Add another step -> delete side_inputs or events_to_process from earlier decisions that are retrieved (put in forbidden). 
            # ! : Que faire si c'était un NOT

            # TODO : Identifier la dernière décision 
            wrong_decision = @decisions.pop
            
            print "Backtracking :" #!DEBUG
            pp wrong_decision

            # TODO : Supprimer toutes les transitions jusqu'à cette décision (incluse)
            loop do
                tmp = @transitions.pop
                # TODO Supprimer les @events_to_process ajouté depuis et avec la mauvaise décision
                if tmp.include? @events_to_process.last
                    @events_to_process.pop
                end
                break if tmp == wrong_decision.events
            end
            # TODO : Supprimer les forbidden decisions pour cette décision
            @forbidden_transitions.delete(wrong_decision) unless !@forbidden_transitions.include?(wrong_decision)
            # TODO : Ajouter la décision responsable du backtrack aux décisions interdites
            @forbidden_transitions[@decisions.last] |= [wrong_decision]

            # TODO : Retourner la dernière transition 
            return @transitions.last.dup, wrong_decision.step
        end

        def set_target_path2 event, insertion_point

            @events_to_process.insert(0, event) 
            if event.instance_of? Array
                @events_to_process.flatten!
            end

            while !@events_to_process.empty?
                
                e = @events_to_process.shift

                g = e.signal
                if g.instance_of? Netlist::Port and g.is_global?
                    next
                else
                    inputs = g.get_source_gates
                end

                is_a_decision, e_inputs = compute_transitions(e, target_path: true)
                
                if e_inputs.nil?
                    return :dead_end
                end
                
                if @transitions.include? e_inputs
                    next
                else

                    @transitions << e_inputs

                    if is_a_decision
                        @decisions << Decision.new(e_inputs, __method__) 
                        # @decisions_steps[e_inputs] |= [:set_target_path2]
                    end
    
                    target_path, side_inputs = inputs.partition{|inp| inp.tag == :target_path}
                    e_target_path, e_side_input = e_inputs.partition{|e| target_path.include? e.signal}
    
                    if !e_target_path.empty?
                        @events_to_process << e_target_path
                        @events_to_process.flatten!
                    end
                    if !e_side_input.empty?
                        @side_inputs << e_side_input
                        @side_inputs.flatten!
                    end
                end
            end 

            return :success
        end

        def backpropagate2 event

            @events_to_process.insert(0, event) 
            if event.instance_of? Array
                @events_to_process.flatten!
            end
            
            while !@events_to_process.empty?
                
                e = @events_to_process.shift # ! also shifts the corresponding object in @transitions leading to an empty @transitions element and errors -> Should be fixed !!! 

                g = e.signal

                if g.instance_of? Netlist::Port and g.is_global?
                    next
                else
                    inputs = g.get_source_gates
                end

                is_a_decision, e_inputs = compute_transitions(e)
                
                if e_inputs.nil?
                    # @side_inputs.insert(0,@events_to_process).flatten! 
                    return :dead_end
                end
                
                if @transitions.include? e_inputs
                    next
                else
                    @transitions << e_inputs
                    
                    if is_a_decision
                        @decisions << Decision.new(e_inputs, __method__) 
                    end
                end

                @events_to_process << e_inputs
                @events_to_process.flatten!
            end

            return :success
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
                previous_event = Event.new(nil,0.0,nil)
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
            return (!(@forbidden_transitions.values.flatten(1).any?{|decision| decision.events == events}) and self.is_fixed_transitions_compatible?(events))
        end

        def compute_transitions event, input_transition = nil, target_path: false
            # * : Compute the expected transition at the output and the deducted transition at the inputs
            # * : Optionnally an input transition is given, then the computation is easier
            # * : Decision is made regarding registered forbidden values

            # ? : Utiliser des tables déjà précalculées contenant tous les cas possibles ? Utilisant une arithmétique particulière avec des R et F, ce serait peut-être préférable. Sinon lambda calcul ou en dur en conditionnel dans une fonction

            # TODO : récupérer les transitions applicable aux entrées de la porte pour obtenir cette transition en sortie
            gate = event.signal
            possible_inputs_transitions = gate.get_input_transition event.value # !!! Value nil parfois, car le point d'insertion n'a aucune décision dans sa stack... ???
            input_transition_time = event.timestamp - gate.propag_time[@delay_model]

            if possible_inputs_transitions.nil? or possible_inputs_transitions.include? nil
                raise "HERE" #!DEBUG
            end

            # TODO : Evincer les transitions possibles qui ne permettent pas de conserver la controlling value sur le target path s'il y en a un.
            if target_path and (gate.get_source_gates[0].is_a? Netlist::Gate and gate.get_source_gates[1].is_a? Netlist::Gate)
                possible_inputs_transitions.select! do |inputs_transition|
                    (gate.get_source_gates[0].tag == :target_path and (["R","F"].include? inputs_transition[0])) or (gate.get_source_gates[1].tag == :target_path and (["R","F"].include? inputs_transition[1])) or (gate.get_source_gates[0].tag != :target_path and gate.get_source_gates[1].tag != :target_path)
                end
            end

            if possible_inputs_transitions.nil? or possible_inputs_transitions.include? nil
                raise "HERE" #!DEBUG
            end

            # TODO : Si inputs_transitions est nil faire un choix pour les deux entrées
            if input_transition.nil?
                
                possible_inputs_transitions.each do |trans_pair|
                    i0_trans = Event.new(gate.get_source_gates[0], input_transition_time, trans_pair[0])
                    if !(gate.is_a? Netlist::Not) and !(gate.is_a? Netlist::Buffer)
                        i1_trans = Event.new(gate.get_source_gates[1],input_transition_time, trans_pair[1])
                    end
                    
                    if !(gate.is_a? Netlist::Not) and !(gate.is_a? Netlist::Buffer) 
                        if verify_transition(i0_trans, i1_trans) 
                            is_a_decision = possible_inputs_transitions.length > 1
                            return is_a_decision,[i0_trans, i1_trans]
                        end
                    else
                        if verify_transition(i0_trans) 
                            is_a_decision = possible_inputs_transitions.length > 1
                            return is_a_decision,[i0_trans]
                        end 
                    end
                end

                # TODO : la boucle est terminée et aucune transition n'a été validée -> lancer un backtracking 
                return [nil]
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

                    if same_time_events.length > 2 #!DEBUG
                        pp "Here"
                    end
                    
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

        def colorFixedGates
            @transitions.flatten.each do |t|
                t.signal.tag = :ht
            end
        end
    end

end