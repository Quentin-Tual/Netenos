module AtetaAddOn
  class AtetaLibrelane < AtetaAddOn::Ateta
    def initialize lblane_env, *args, inserted_std_cell: nil
      @lblane_env = lblane_env
      @inserted_std_cell = inserted_std_cell
      super(*args)
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
      @lblane_env.insert_buf_and_finalize(insertPointName, @inserted_std_cell)
      
      # Charger le .v altéré
      @altCirc = Verilog.load_netlist(@lblane_env.get_last_run_v)
      
      # L'annoter par le .sdf altéré
      SDF.annotate(@altCirc, @lblane_env.get_last_run_sdf)
      
      # Supprimer le dossier du dernier run (altération)
      @lblane_env.delete_last_run

    end
  end
end