module ASP
  class ASPDomainExtractor
    attr_reader :rules

    def initialize(nl, delays, crit_path_delay, sdf_col: :typ)
      @nl = nl
      @delays = delays
      @gate_min_dly = @nl.get_comp_min_delay(:sdf, dly_db: @delays)
      @sdf_col = sdf_col
      @src = []
      @domains = []
      @signals = []
      @primaries = []
      @crit_path_delay = crit_path_delay
    end

    def print
      declare_signals
      declare_primaries
      declare_edges
      declare_vals
      declare_time
      @src.join("\n")
    end

    private

    def declare_signals
      @src << declare_inputs
      @src << declare_outputs
      @src << declare_wires
      @src << declare_gate_outputs
    end

    def declare_inputs
      @nl.get_inputs.collect do |i|
        "signal(#{i.get_asp_name})."
      end.join(' ')
    end

    def declare_outputs
      @nl.get_output.collect do |o|
        "signal(#{o.get_asp_name})."
      end.join(' ')
    end

    def declare_wires
      @nl.wires.collect do |w|
        "signal(#{w.get_asp_name})."
      end.join(' ')
    end

    def declare_gate_outputs
      @nl.components.collect do |g|
        "signal(#{g.get_output.get_asp_name})."
      end.join(' ')
    end

    def declare_primaries
      @src << @nl.get_inputs.collect do |i|
        "primary(#{i.get_asp_name})."
      end.join(' ')
    end

    def declare_edges
      @src << 'edge(r). edge(f).'
    end

    def declare_vals
      @src << 'val(0). val(1).'
    end

    def declare_time
      @src << "time(0..#{@crit_path_delay})."
    end
  end
end
