# frozen_string_literal: true

module AtetaAddOn
  # Inheriting HTPG class, allows to use HTPG in a Librelane environment.
  class HtpgLibrelane < AtetaAddOn::Htpg
    def initialize(lblane_env, *args, smt_format: :rec, inserted_std_cell: nil, risky_signals: [])
      @lblane_env = lblane_env
      @inserted_std_cell = inserted_std_cell
      super(*args, smt_format: smt_format)
      @insertionPoints = risky_signals unless risky_signals.empty?
    end

    def get_pdk_name(netName)
      if netName.include? $FULL_PORT_NAME_SEP
        compName, portName = netName.split($FULL_PORT_NAME_SEP)
        raise "Error: 'nil' value encountered for insert point #{netName}." if compName.nil? or portName.nil?

        comp = @initCirc.get_component_named(compName)
        pdk_portname = comp.scl_ios[portName]
        netName = "#{compName}#{$FULL_PORT_NAME_SEP}#{pdk_portname}"
      end
      netName
    end

    def getAlteredCircuit(insertPointName)
      # Obtenir le nom sky130 du point d'insertion
      insertPointName = get_pdk_name(insertPointName)

      # Faire une insertion dans l'environnement LibreLane
      @lblane_env.insert_buf_and_finalize(insertPointName, @inserted_std_cell)

      # Charger le .v altéré
      @altCirc = Verilog.load_netlist(@lblane_env.get_last_run_v)

      # Charger le .sdf
      @alt_dly_db = SDF.generate_dly_db(@altCirc, @lblane_env.get_last_run_sdf)

      @altCirc.name = @altCirc.name + '_alt'
      # Supprimer le dossier du dernier run (altération)
      @lblane_env.delete_last_run
    end
  end
end
