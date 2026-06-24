module AtetaAddOn
  class HtpgLibrelane < AtetaAddOn::Htpg
    def initialize lblane_env, *args, smt_format: :rec, inserted_std_cell: nil, risky_signals: []
      @lblane_env = lblane_env
      @inserted_std_cell = inserted_std_cell
      super(*args, smt_format: smt_format)
      @insertionPoints = risky_signals unless risky_signals.empty?
    end

    def generate_stim forbiddenVectors = []
        puts "[+] Generating stim for #{@initCirc.name}, #{@insertionPoints.length} insertion points to go." if $VERBOSE
        count = 0 if $VERBOSE

        @solutions = Hash.new { |h, k| h[k] = Hash.new }
        # Pour chaque point d'insertion dans le circuit initial
        @insertionPoints.each do |insertPointName|
            if insertPointName.nil?
                raise "Error: 'nil' insert point name encountered."
            end
            # next if @observables.include? insertPointName
            puts " |-- #{count += 1}/#{@insertionPoints.length} insert point." if $VERBOSE
            # Créer une version altérée du circuit initial
            downstreamOuputs = get_cone_outputs(insertPointName)
            getAlteredCircuit(insertPointName)
            solution_found = false
            # Pour chaque sortie du cone de sortie, jusqu'à ce qu'une solution soit trouvée
            downstreamOuputs.each do |targetedOutputName|
                # Déterminer le chemin entre le point d'insertion et la sortie qui contient le plus de signaux à risque
                # path = most_covering_path(insertPointName, targetedOutputName)
                # Appliquer Ateta_sat
                solver = AtetaAddOn::HtpgSat.new(
                    @initCirc, @init_dly_db, @crit_path,
                    @altCirc, @alt_dly_db, 
                    insertPointName, targetedOutputName, 
                    #path_to_constraint: path, 
                    smt_format: @smt_format)
                result = solver.run
                # Stocker les couples de test générés dans un tableau
                if result.nil? 
                    next
                else
                    solution_found = true
                    # ! Stocker le nom et non l'objet (insertPoint ET targetedOutput)
                    # path.collect do |obj|
                    #   obj_name = obj.is_a?(Netlist::Gate) ? obj.name : obj.get_full_name
                    #   if @insertionPoints.include? obj_name
                    #     @solutions[obj_name][targetedOutputName] = result
                    #     @observables << obj_name
                    #   end
                    # end
                    @solutions[insertPointName][targetedOutputName] = result
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

    def get_pdk_name netName
      if netName.include? $FULL_PORT_NAME_SEP 
        compName, portName = netName.split($FULL_PORT_NAME_SEP)
        if compName.nil? or portName.nil?
          raise "Error: 'nil' value encountered for insert point #{netName}."
        end
        comp = @initCirc.get_component_named(compName)
        pdk_portname = comp.scl_ios[portName]
        netName = "#{compName}#{$FULL_PORT_NAME_SEP}#{pdk_portname}"
      end
      netName
    end

    def getAlteredCircuit insertPointName
      # Obtenir le nom sky130 du point d'insertion
      insertPointName = get_pdk_name(insertPointName)

      # Faire une insertion dans l'environnement LibreLane  
      @lblane_env.insert_buf_and_finalize(insertPointName)
      
      # Charger le .v altéré
      @altCirc = Verilog.load_netlist(@lblane_env.get_last_run_v)
      
      # Charger le .sdf 
      @alt_dly_db = SDF.generate_dly_db(@altCirc, @lblane_env.get_last_run_sdf)
      
      @altCirc.name = @altCirc + "_alt"
      # Supprimer le dossier du dernier run (altération)
      @lblane_env.delete_last_run
    end
  end
end