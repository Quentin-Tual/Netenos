module AtetaAddOn
    # ! One object for one circuit
    # ! Allows to : 
    # !     - Identify all insertion points for a given payload delay
    # !     - Insert a Buffer on an insertion point, returning a netlist
    # !     - Apply Ateta_sat on each insertion point, aggregating test vector couples
    # !     - 

    class Ateta 
        attr_reader :unobservables, :observables

        def initialize initCirc, payloadDelay, delayModel, netlist_format: "sexp"
            @initCirc = initCirc.dup
            # @initCirc.get_exact_crit_path_length(delayModel)
            # @initCirc.get_slack_hashi
            # if netlist_format == "sexp"
                if !File.exist?("#{@initCirc.name}.sexp") and !File.exist?("#{@initCirc.name}.enl")
                    @initCirc.save_as(".", netlist_format)
                end
            # else
                # if !File.exist?("#{@initCirc.name}.enl")
                #     @initCirc.save_as("."n)
                # end
            # end

            @payloadDelay = payloadDelay
            @delayModel = delayModel

            initCirc.get_exact_crit_path_length(delayModel)
            @insertionPoints = initCirc.get_insertion_points(payloadDelay)
            @insertionPoints.collect!{|ip| ip.get_full_name}
            @altCirc = nil

            @unobservables = []
            @observables = []
            @netlist_format = netlist_format
        end

        def generate_stim forbiddenVectors = []
            puts "[+] Generating stim for #{@initCirc.name}, #{@insertionPoints.length} insertion points to go." if $VERBOSE
            count = 0 if $VERBOSE

            @solutions = Hash.new { |h, k| h[k] = Hash.new}
            # @vec_list = []
            # Pour chaque point d'insertion dans le circuit initial
            @insertionPoints.each do |insertPointName|
                if insertPointName.nil?
                    raise "Error: 'nil' insert point name encountered."
                end
                puts " |-- #{count += 1}/#{@insertionPoints.length} insert point." if $VERBOSE
                insertPoint = nil
                if insertPointName.include? "_" 
                    compName, portName = insertPointName.split("_")
                    if compName.nil? or portName.nil?
                        raise "Error: 'nil' value encountered for insert point #{insertPointName}."
                    end
                    insertPoint = @initCirc.get_component_named(compName).get_port_named(portName)
                else
                    insertPoint = @initCirc.get_port_named(insertPointName)
                end
                # Créer une version altérée du circuit initial
                downstreamOuputs = get_cone_outputs(insertPoint)
                getAlteredCircuit(insertPoint)
                solution_found = false
                # Pour chaque sortie du cone de sortie, jusqu'à ce qu'une solution soit trouvée
                downstreamOuputs.each do |targetedOutput|
                    # Appliquer Ateta_sat
                    solver = AtetaAddOn::AtetaSat.new(@initCirc, @altCirc, insertPoint, targetedOutput, @delayModel, forbiddenVectors)
                    result = solver.run
                    # Stocker les couples de test générés dans un tableau
                    if result.nil? 
                        next
                    else
                        solution_found = true
                        # ! Stocker le nom et non l'objet (insertPoint ET targetedOutput)
                        @solutions[insertPointName][targetedOutput.name] = result
                        @observables << insertPointName # ! Stocker le nom et non l'objet
                        break
                    end
                end

                unless solution_found
                    @unobservables << insertPointName
                end
            end
            
            # Renvoyer les vecteurs de test générés

            res = @solutions.values.collect{|h| h.values}.flatten

            fvSet = Set.new(forbiddenVectors)
            res.each do |v|
                if fvSet.include? v
                    raise "Error: Forbidden Vector generated."
                end
            end

            return res
        end

        def getAlteredCircuit insertPoint
            precedenceGrid = @initCirc.get_netlist_precedence_grid
            timings_h = @initCirc.get_timings_hash(@delayModel)
            tamperer = Inserter::Tamperer.new(@initCirc,precedenceGrid, timings_h)
            @altCirc = tamperer.insert_buffer_at(insertPoint, @payloadDelay)

            if @netlist_format == "sexp"
                @initCirc = Deserializer.new.deserialize("./#{@initCirc.name}.sexp")
                @altCirc.name = "#{@altCirc.name}_altered"
            else
                @initCirc = Marshal.load(File.read("./#{@initCirc.name}.enl"))
            end
        end

        def get_cone_outputs insertPoint
            # * search the output from the given insertPoint (last gate of the path) 
            next_gates = nil

            if insertPoint.instance_of? Netlist::Port and insertPoint.is_global?
                next_gates = insertPoint.get_sink_gates
            else
                next_gates = insertPoint.partof.get_sink_gates
            end

            cone_outputs = Set.new

            until next_gates.empty?
                current_gate = next_gates.shift
                if current_gate.instance_of? Netlist::Port and current_gate.is_global? # * If insertion point is the last gate before a primary output
                    cone_outputs << current_gate
                    next
                end

                primary_outputs, current_gate_sinks = current_gate.get_sink_gates.partition{|g| g.is_a? Netlist::Port and g.is_global?}
                
                cone_outputs << primary_outputs unless primary_outputs.empty?
                cone_outputs.flatten!
                next_gates += current_gate_sinks unless next_gates.include? current_gate
            end

            # * Filter primary outputs plugged to a constant
            cone_outputs = cone_outputs.to_a.flatten.select{|g| !g.get_source.instance_of?(Netlist::Constant)}

            return cone_outputs 
        end

        def save_explicit path, binStimVec: false, repetition: 1
            if path[-4..-1]!=".txt" and path[-5..-1]!=".stim"
                path.concat ".txt"
            end

            s = @solutions.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(insertPoint, solution), result_h|
                solution.each do |targetedOutput, vecCouple|
                    result_h[vecCouple] << [insertPoint, targetedOutput]
                end
            end

            src = Code.new
            src << "# Stimuli sequence;#{binStimVec ? "bin" : "dec"};#{@initCirc.get_inputs.length};explicit"
            src << "# Unobservables : #{@unobservables.length}" 

            s.each do |vecCouple, target|
                src << "# " + (target.collect{|insert_point, output| "s=#{insert_point}, o=#{output}"}.join("; "))
                
                repetition.times do |i|
                    vecCouple.each do |v|
                        if binStimVec
                            src << v.reverse
                        else
                            src << v.reverse.to_i(2)
                        end
                    end
                end
            end

            src.save_as path
        end

    end
end