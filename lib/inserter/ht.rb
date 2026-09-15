module Inserter
  class HT
    attr_reader :netlist, :triggers, :propag_time, :payload_in, :components

    # * : An HT netlist is considered as the reference pointing on its payload instance
    def initialize(_netlist = nil) # , triggers, payload_out, payload_in=nil
      @netlist = nil
      @triggers = []
      @payload_out = nil
      @payload_in = nil
      @components = []
      @propag_time = {}
    end

    def is_inserted?
      # TODO : For each trigger port and payload port, check if links are valid (in both direction, so check if source has the port itself in fanout)

      # * : Returns a boolean value, being true if all ports of the HT are correctly connected
      @triggers.each do |trig|
        return false unless trig.check_link?
      end

      return false if !@payload_in.check_link? or !@payload_out.check_link?

      true
    end

    def get_exact_crit_path(delay_model)
      @components.each { |comp| comp.cumulated_propag_time = 0.0 }
      trig_comps = @triggers.collect { |in_p| in_p.partof }.uniq
      trig_comps.each { |comp| comp.update_path_delay 0, delay_model }

      @payload_out.partof.cumulated_propag_time
    end

    def get_triggers_nb
      @triggers.length
    end

    def get_payload_out
      @payload_out
    end

    def get_payload_in
      @payload_in
    end

    def get_triggers
      @triggers
    end

    def get_trigger_transition_proba(proba_input_sig = Array.new(@triggers.length, 0.5))
      @trigger_sigs_proba = @triggers.each_with_object({}).with_index do |(trig, h), i|
        h[trig] = proba_input_sig[i]
      end

      get_transition_probability(@payload_in.partof.get_inputs[1].get_source.partof)
    end

    def get_transition_probability(curr_gate = @payload_in.partof.get_inputs[1].get_source.partof)
      return 0.5 unless @components.include? curr_gate

      sources = []
      transi_proba = []
      curr_gate.get_inputs.each { |ip| sources << ip.get_source }
      sources.each_with_index do |source, i|
        transi_proba << if source.nil?
                          @trigger_sigs_proba[curr_gate.get_inputs[i]]
                        else
                          get_transition_probability(source.partof)
                        end
      end

      compute_transit_proba(transi_proba, curr_gate)
    end

    def compute_transit_proba(transi_proba, gate)
      output_transit_proba = 0.0
      proba_ix = transi_proba[0]
      proba_iy = transi_proba[1]

      case gate
      when Netlist::And2
        output_transit_proba = (1.0 - proba_ix * proba_iy) * (proba_ix * proba_iy)
      when Netlist::Or2
        output_transit_proba = (1.0 - proba_ix) * (1.0 - proba_iy) * (1.0 - ((1.0 - proba_ix) * (1.0 - proba_iy)))
      when Netlist::Not
        output_transit_proba = (1.0 - proba_ix) * proba_ix
      when Netlist::Nand2
        output_transit_proba = (proba_ix * proba_iy) * (1.0 - (proba_ix * proba_iy))
      when Netlist::Nor2
        output_transit_proba = (1.0 - (1.0 - proba_ix) * (1.0 - proba_iy)) * (1.0 - proba_ix) * (1.0 - proba_iy)
      when Netlist::Xor2
        output_transit_proba = (1.0 - (proba_ix + proba_iy - 2.0 * proba_ix * proba_iy)) * (proba_ix + proba_iy - 2.0 * proba_ix * proba_iy)
      else
        puts "Error : Gate type #{gate.class} encountered not handled for transition probability computing."
      end

      output_transit_proba
    end

    def get_components
      @components
    end
  end
end
