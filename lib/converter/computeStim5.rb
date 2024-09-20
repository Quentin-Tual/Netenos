# ! Check if necessary to use hash as forbidden_transitions associating a fixed event as the key and banned events as the value.
# ! We could need to set the key manually after a reaching inputs and going back to another branch of the circuit/tree.

module Converter

    # Transition = Struct.new(:timestamp, :value)
    Event = Struct.new(:signal, :timestamp, :value, :parent) do 
        def match? event
           return ((event.signal == signal) and (event.timestamp == timestamp) and (event.value == value))
        end

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

        def get_insertion_points payload_delay
            # * Returns a list of gate which outputs has a slack greater than the payload delay 
            slack_h = @netlist.get_slack_hash @delay_model
            return slack_h.select{|slack, gate| slack >= payload_delay}.values.flatten
        end

        # ! When insertion point is a global input -> no get_sink_gates method for Netlist::Port
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

        def analyse_netlist 
            @insert_points = get_insertion_points 2.5 # ! hard value as it is the maximum delay in delay model :int_multi, check if possible to write a clean version
            @target_paths_outputs = {}
            @downstream_outputs = {}
            @insert_points.each do |signal|
                @downstream_outputs[signal] = get_cone_outputs(signal) 
            end
        end

        def clean_data
            @side_inputs = []
            @transitions = []
            # @decisions = []
            @forbidden_transitions = [] #Hash.new([]) # Associates a stack of gate/transition pairs to one gate/decision pair, one key for each decision
            # @decisions_steps = Hash.new([])
            @events_to_process = []
            @netlist.components.each{|comp| comp.tag = nil}
        end

        def generate_stim netlist=nil
            if @netlist.nil? and netlist.nil?
                raise "Error : No netlist provided."
            elsif !netlist.nil?
                @netlist = netlist
            end
            
            analyse_netlist
            
            @events_computed = {}

            @insert_points.each do |insert_point|
                @events_computed[insert_point] = {}
                @downstream_outputs[insert_point].each do |targeted_output|
                    res = []
                    # @events_computed[insert_point][targeted_output] = {}
                    tmp = []
                    ["R","F"].each do |transition|
                        targeted_transition = Converter::Event.new(targeted_output, @netlist.crit_path_length , transition, nil)
                        res << compute(targeted_transition, @insert_points[0])
                        # ! : Modifier la fonction 'compute' pour empêcher les cas solutions de sensibilisation uniquement dynamique (stimulation asynchrone).
                        tmp << get_inputs_events
                        clean_data # Nettoyer @transitions, @forbidden_transitions, ...
                    end

                    if res.include? :impossible
                        next
                    else
                        @events_computed[insert_point][targeted_output] ={"R" => tmp[0], "F" => tmp[1]}
                        break
                    end
                end
                if @events_computed[insert_point].empty?
                    raise "Error : Insertion point #{insert_point.name} not observable on any output."
                end
            end

            @events_computed.delete_if{|insert_point, solution| solution.empty?}

            # TODO : Déterminer les vecteurs synchrones pour chaque cas(feuille de l'arbre) de @events_computed. Possible de le faire au cas par cas.
            # pp "test" #!DEBUG
            return @events_computed
        end

        def compute event, insertion_point
            
            @transitions << [event]

            backpropagate2([event])

            if @forbidden_transitions.last == event
                if @forbidden_transitions.length > 1 #!DEBUG
                    pp "unexpected"
                end
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
                    if e.timestamp <= event.timestamp and e.timestamp > previous_event.timestamp # ! e.timestamp <= event.timestamp, see if modification cause troubles
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