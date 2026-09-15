module AtetaAddOn
  # ! One object for one circuit
  # ! Allows to :
  # !     - Identify all insertion points for a given payload delay
  # !     - Insert a Buffer on an insertion point, returning a netlist
  # !     - Apply Ateta_sat on each insertion point, aggregating test vector couples

  class Htpg
    attr_reader :unobservables, :observables

    def initialize(initCirc, payloadDelay, dly_db, smt_format: :rec, asp: false)
      @initCirc = initCirc
      @payloadDelay = payloadDelay
      @init_dly_db = dly_db

      # initCirc.get_exact_crit_path_length(delayModel)
      timings_db = Delays::TimingAnalyzer.new(initCirc, dly_db).analyze
      @crit_path = timings_db.max_by { |sig, val| val }.last
      slack_db = Delays::SlackAnalyzer.new(initCirc, timings_db).analyze
      @insertionPoints = initCirc.get_insertion_points(payloadDelay, slack_db)
      @insertionPoints.collect! { |ip| ip.get_full_name }
      @altCirc = nil
      @alt_dly_db = nil
      @unobservables = []
      @observables = []
      @smt_format = smt_format
      @asp = asp
    end

    def generate_stim(forbiddenVectors = [], path_constraints: false)
      puts "[+] Generating stim for #{@initCirc.name}, #{@insertionPoints.length} insertion points to go." if $VERBOSE
      count = 0 if $VERBOSE
      cumulated_altering_time = 0.0
      cumulated_solving_time = 0.0

      @solutions = Hash.new { |h, k| h[k] = {} }
      # Pour chaque point d'insertion dans le circuit initial
      @insertionPoints.each do |insertPointName|
        raise "Error: 'nil' insert point name encountered." if insertPointName.nil?
        next if @observables.include? insertPointName

        puts " |-- #{count += 1}/#{@insertionPoints.length} insert point." if $VERBOSE
        # Créer une version altérée du circuit initial
        downstreamOuputs = get_cone_outputs(insertPointName)
        altering_start_time = Time.now
        getAlteredCircuit(insertPointName)
        altering_finish_time = Time.now
        cumulated_altering_time += altering_finish_time - altering_start_time
        solution_found = false
        # Pour chaque sortie du cone de sortie, jusqu'à ce qu'une solution soit trouvée
        downstreamOuputs.each do |targetedOutputName|
          # Déterminer le chemin entre le point d'insertion et la sortie qui contient le plus de signaux à risque
          path = (most_covering_path(insertPointName, targetedOutputName) if path_constraints)
          # Appliquer Ateta_sat
          solver = if @asp
                     AtetaAddOn::HtpgAsp.new(
                       @initCirc, @init_dly_db, @crit_path,
                       @altCirc, @alt_dly_db,
                       insertPointName, targetedOutputName
                     )
                   else
                     AtetaAddOn::HtpgSat.new(
                       @initCirc, @init_dly_db, @crit_path,
                       @altCirc, @alt_dly_db,
                       insertPointName, targetedOutputName,
                       path_to_constraint: path,
                       smt_format: @smt_format
                     )
                   end
          solving_start_time = Time.now
          result = solver.run
          solving_finish_time = Time.now
          cumulated_solving_time += solving_finish_time - solving_start_time
          # Stocker les couples de test générés dans un tableau
          next if result.nil?

          solution_found = true
          # ! Stocker le nom et non l'objet (insertPoint ET targetedOutput)
          if path_constraints
            path.collect do |obj|
              obj_name = obj.is_a?(Netlist::Gate) ? obj.name : obj.get_full_name
              if @insertionPoints.include? obj_name
                @solutions[obj_name][targetedOutputName] = result
                @observables << obj_name
              end
            end
          end
          @solutions[insertPointName][targetedOutputName] = result
          @observables << insertPointName # ! Stocker le nom et non l'objet
          break
        end

        @unobservables << insertPointName unless solution_found
      end

      # Renvoyer les vecteurs de test générés

      res = @solutions.values.collect { |h| h.values }.flatten

      fvSet = Set.new(forbiddenVectors)
      res.each do |v|
        raise 'Error: Forbidden Vector generated.' if fvSet.include? v
      end

      reporting = "Cumulated altering time : #{cumulated_altering_time}\nCumulated solving time : #{cumulated_solving_time}\nTotal : #{cumulated_altering_time + cumulated_solving_time}"
      File.write('htpg_time_report.txt', reporting)

      res
    end

    def getAlteredCircuit(insertPointName)
      @altCirc = @initCirc.deep_copy

      if insertPointName.include? $FULL_PORT_NAME_SEP
        compName, portName = insertPointName.split($FULL_PORT_NAME_SEP)
        raise "Error: 'nil' value encountered for insert point #{insertPointName}." if compName.nil? or portName.nil?

        insertPoint = @altCirc.get_component_named(compName).get_port_named(portName)
      else
        insertPoint = @altCirc.get_port_named(insertPointName)
      end

      # precedenceGrid = @altCirc.get_netlist_precedence_grid
      # timings_h = @altCirc.get_timings_hash(@delayModel)
      tamperer = Inserter::Tamperer.new(@altCirc, nil, nil, @delayModel, dly_db: @init_dly_db)
      if @altCirc.components.all? { |g| g.is_a? Netlist::STDCell }
        tamperer.insert_sky130_buffer_at(insertPoint, @payloadDelay)

        # TODO : Add a new objects in dly_db for delays of the inserted buffer, do it in the initialize ? earlier ? here ?
        added_buf = @altCirc.components.last
        added_wire = @altCirc.add_wire_between(
          added_buf.get_output,
          added_buf.get_output.get_sinks
        )

        @altCirc.name.delete_suffix!('_copy')
        @alt_dly_db = SDF.generate_dly_db(@altCirc, @init_dly_db.sdf_filepath, inserted_gates: [added_buf])
        @altCirc.name = @altCirc.name + '_copy'

        unless added_wire.instance_of? Netlist::Wire
          raise "Error: Sink of the added buffer #{added_buf.name} should be a wire, got #{added_wire}"
        end

        @alt_dly_db.create_add(added_buf, @payloadDelay)
        @alt_dly_db.create_add(added_wire, 0)

      elsif @altCirc.components.none? { |g| g.is_a? Netlist::STDCell }
        raise 'Error: Expecting a sky130 gate-level netlist, encountered non sky130 components.'
      else
        raise 'Error: Non homogeneous circuit encountered, expected all components to be STDCell class objects or GTECH Gate class objects.'
      end
    end

    def get_cone_outputs(insertPointName)
      # * search the output from the given insertPoint (last gate of the path)

      if insertPointName.include? $FULL_PORT_NAME_SEP
        compName, portName = insertPointName.split($FULL_PORT_NAME_SEP)
        raise "Error: 'nil' value encountered for insert point #{insertPointName}." if compName.nil? or portName.nil?

        insertPoint = @initCirc.get_component_named(compName).get_port_named(portName)
      else
        insertPoint = @initCirc.get_port_named(insertPointName)
      end

      next_gates = nil

      if insertPoint.instance_of? Netlist::Port and insertPoint.is_global?
        if insertPoint.is_input?
          next_gates = insertPoint.get_sink_gates
        elsif insertPoint.is_output?
          return [insertPoint.get_full_name]
        else
          raise 'Error: Internal error, unexpected state reached'
        end
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

        primary_outputs, current_gate_sinks = current_gate.get_sink_gates.partition { |g| g.is_a? Netlist::Port and g.is_global? }

        cone_outputs << primary_outputs unless primary_outputs.empty?
        cone_outputs.flatten!
        next_gates += current_gate_sinks unless next_gates.include? current_gate
      end

      # * Filter primary outputs plugged to a constant
      cone_outputs = cone_outputs.to_a.flatten.select { |g| !g.get_source.instance_of?(Netlist::Constant) }
      cone_outputs.map!(&:get_full_name)

      cone_outputs
    end

    def most_covering_path(insertPointName, targetedOutputName)
      targetedOutput = @initCirc.get_port_named(targetedOutputName)
      compName, portName = insertPointName.split($FULL_PORT_NAME_SEP)

      pathLister = Netlist::PathLister.new(@initCirc, targetedOutput)

      insertPoint = @initCirc.get_component_named(compName).get_port_named(portName)

      paths = insertPoint.accept(pathLister)

      insertionPointsSet = Set.new(@insertionPoints)
      paths.max_by do |path|
        namePath = path.collect { |obj| obj.is_a?(Netlist::Gate) ? obj.name : obj.get_full_name }
        (insertionPointsSet & namePath).length
      end
    end

    def save_explicit_add_headers(src, binStimVec)
      src << "# Stimuli sequence;#{binStimVec ? 'bin' : 'dec'};#{@initCirc.get_inputs.length};explicit"
      src << "# Unobservables : #{@unobservables.length}"
    end

    def save_explicit_util(binStimVec, s, path, repetition)
      src = Code.new
      save_explicit_add_headers(src, binStimVec)
      # src << "# Stimuli sequence;#{binStimVec ? "bin" : "dec"};#{@initCirc.get_inputs.length};explicit"
      # src << "# Unobservables : #{@unobservables.length}"

      s.each do |vecCouple, target|
        src << '# ' + target.collect { |insert_point, output| "s=#{insert_point}, o=#{output}" }.join('; ')

        repetition.times do |i|
          vecCouple.each do |v|
            src << if binStimVec
                     v
                   else
                     v.reverse.to_i(2)
                   end
          end
        end
      end

      src.save_as path
    end

    def save_explicit(path, binStimVec: false, repetition: 1)
      path.concat '.txt' if path[-4..-1] != '.txt' and path[-5..-1] != '.stim'

      s = @solutions.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(insertPoint, solution), result_h|
        solution.each do |targetedOutput, vecCouple|
          result_h[vecCouple] << [insertPoint, targetedOutput]
        end
      end

      save_explicit_util(binStimVec, s, path, repetition)
    end

    # def generate_maximized_stim forbiddenVectors = [], targeted_duration = @initCirc.get_comp_max_delay(@delayModel)
    #     puts "[+] Generating stim for #{@initCirc.name}, #{@insertionPoints.length} insertion points to go." if $VERBOSE
    #     count = 0 if $VERBOSE

    #     @solutions = Hash.new { |h, k| h[k] = Hash.new}
    #     # @vec_list = []
    #     # Pour chaque point d'insertion dans le circuit initial
    #     @insertionPoints.each do |insertPointName|
    #         if insertPointName.nil?
    #             raise "Error: 'nil' insert point name encountered."
    #         end
    #         puts " |-- #{count += 1}/#{@insertionPoints.length} insert point." if $VERBOSE
    #         # Créer une version altérée du circuit initial
    #         downstreamOuputs = get_cone_outputs(insertPointName)
    #         getAlteredCircuit(insertPointName)
    #         solution_found = false
    #         # Pour chaque sortie du cone de sortie, jusqu'à ce qu'une solution soit trouvée
    #         downstreamOuputs.each do |targetedOutputName|
    #             # Appliquer Ateta_sat
    #             solver = AtetaAddOn::AtetaSat.new(@initCirc, @altCirc, insertPointName, targetedOutputName, @delayModel, forbiddenVectors, @memoizer, @payload_delay)
    #             result = solver.runMaximize(targeted_duration)
    #             # Stocker les couples de test générés dans un tableau
    #             if result.nil?
    #                 next
    #             else
    #                 solution_found = true
    #                 # ! Stocker le nom et non l'objet (insertPoint ET targetedOutput)
    #                 @solutions[insertPointName][targetedOutputName] = result
    #                 @observables << insertPointName # ! Stocker le nom et non l'objet
    #                 break
    #             end
    #         end

    #         unless solution_found
    #             @unobservables << insertPointName
    #         end
    #     end

    #     # Renvoyer les vecteurs de test générés

    #     res = @solutions.values.collect{|h| h.values}.flatten

    #     fvSet = Set.new(forbiddenVectors)
    #     res.each do |v|
    #         if fvSet.include? v
    #             raise "Error: Forbidden Vector generated."
    #         end
    #     end

    #     return res
    # end

    # def generate_glitch_stim forbiddenVectors = []
    #     puts "[+] Generating stim for #{@initCirc.name}, #{@insertionPoints.length} insertion points to go." if $VERBOSE
    #     count = 0 if $VERBOSE

    #     @solutions = Hash.new { |h, k| h[k] = Hash.new}
    #     # @vec_list = []
    #     # Pour chaque point d'insertion dans le circuit initial
    #     @insertionPoints.each do |insertPointName|
    #         if insertPointName.nil?
    #             raise "Error: 'nil' insert point name encountered."
    #         end
    #         puts " |-- #{count += 1}/#{@insertionPoints.length} insert point." if $VERBOSE
    #         # Créer une version altérée du circuit initial
    #         downstreamOuputs = get_cone_outputs(insertPointName)
    #         getAlteredCircuit(insertPointName)
    #         solution_found = false
    #         # Pour chaque sortie du cone de sortie, jusqu'à ce qu'une solution soit trouvée
    #         downstreamOuputs.each do |targetedOutputName|
    #             # Appliquer Ateta_sat
    #             solver = AtetaAddOn::AtetaSat.new(@initCirc, @altCirc, insertPointName, targetedOutputName, @delayModel, forbiddenVectors, @memoizer, @payloadDelay)
    #             result = solver.runGlitch
    #             # Stocker les couples de test générés dans un tableau
    #             if result.nil?
    #                 next
    #             else
    #                 solution_found = true
    #                 # ! Stocker le nom et non l'objet (insertPoint ET targetedOutput)
    #                 @solutions[insertPointName][targetedOutputName] = result
    #                 @observables << insertPointName # ! Stocker le nom et non l'objet
    #                 break
    #             end
    #         end

    #         unless solution_found
    #             @unobservables << insertPointName
    #         end
    #     end

    #     # Renvoyer les vecteurs de test générés

    #     res = @solutions.values.collect{|h| h.values}.flatten

    #     fvSet = Set.new(forbiddenVectors)
    #     res.each do |v|
    #         if fvSet.include? v
    #             raise "Error: Forbidden Vector generated."
    #         end
    #     end

    #     return res
    # end
  end
end
