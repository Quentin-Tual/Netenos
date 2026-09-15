#
# gate_asp.rb
#
# Generates ASP causal rules (in the event/steady style used throughout this
# conversation) for a logic gate, given:
#   - its boolean function (as a block: Array[0/1] -> 0/1)
#   - the number/names of its inputs
#   - the name of its output
#   - the R/F propagation delays
#
# The generated rules follow the pattern we built by hand for OR and AND:
#   event(out, r, T) :- event(in1, r, T-DR), steady(in2, s0, T-DR).
#   event(out, r, T) :- event(in1, r, T-DR), event(in2, r, T-DR).
#   ... etc, one rule per minimal causal condition found in the truth table.
#
# Method: for every nonempty subset S of inputs simultaneously transitioning
# (from_val -> to_val) and every 0/1 assignment of the remaining ("steady")
# inputs, check whether the function actually flips output from from_val to
# to_val under that scenario. If so, emit the corresponding ASP rule.

module ASP
  class GateASP
    def initialize(inputs, output, fun_proc, delay_r: 2, delay_f: 1)
      @inputs  = inputs
      @output  = output
      @delay_r = delay_r
      @delay_f = delay_f
      @fn      = fun_proc
      @n       = inputs.size
    end

    def to_asp
      lines = []
      lines << "% Gate: #{@output} = f(#{@inputs.join(', ')})"

      exh_values, exh_transitions = stim_set

      lines.concat(init_state_rules(exh_values))
      lines.concat(bhv_rules(exh_transitions))
      lines.join("\n")
    end

    private

    def init_state_rules(exh_values)
      exh_values.map do |combo|
        val = @fn.call(combo) ? 1 : 0
        body = @inputs.each_with_index.map do |name, idx|
          "level0(#{name}, #{combo[idx] ? 1 : 0})"
        end.join(', ')
        "level0(#{@output}, #{val}) :- #{body}."
      end
    end

    def bhv_rules(exh_transitions)
      bhv_h = precompute_bhv(exh_transitions)
      bhv_h.select! { |_, output_bhv| %w[r f].include? output_bhv }
      bhv_h.sort_by { |_, bhv| bhv }.collect do |before_after, output_bhv|
        before, after = before_after
        inputs_bhv = (0...before.length).collect do |idx|
          boolean_to_event([before[idx], after[idx]])
        end
        build_rule(inputs_bhv, output_bhv)
      end
    end

    def build_rule(inputs_bhv, output_bhv)
      head = "event(#{@output}, #{output_bhv}, T)"

      delay = if output_bhv == 'r'
                @delay_r
              else
                @delay_f
              end

      # Pour chaque input_bhv avec son indice
      #   Si le comportement est "steady" (commence par un s)
      #     alors écrire "steady..."
      #   Sinon
      #     alors écrire "event..."
      #   FinSi

      trans_atoms = []
      steady_atoms = []

      inputs_bhv.each_with_index do |bhv, idx|
        if bhv[0] == 's'
          steady_atoms << "steady(#{@inputs[idx]}, #{bhv}, T-#{delay})"
        else
          trans_atoms << "event(#{@inputs[idx]}, #{bhv}, T-#{delay})"
        end
      end

      body = (trans_atoms + steady_atoms + ['time(T)']).join(', ')
      "#{head} :- #{body}."
    end

    def precompute_bhv(exh_transitions)
      exh_transitions.each_with_object({}) do |before_after, bhv_h|
        bool_eval = evaluate(*before_after)
        bhv_h[before_after] = boolean_to_event(bool_eval)
      end
    end

    def stim_set
      exh_values = [true, false].repeated_permutation(@inputs.length)
      exh_transitions = exh_values.to_a.repeated_permutation(2)
      [exh_values, exh_transitions]
    end

    def evaluate(before, after)
      from_val = @fn.call(before)
      to_val = @fn.call(after)

      [from_val, to_val]
    end

    def boolean_to_event(before_after)
      case before_after
      when [false, false]
        's0'
      when [true, true]
        's1'
      when [true, false]
        'f'
      when [false, true]
        'r'
      else
        raise 'Unexpected state encountered, internal error.'
      end
    end
  end
end

# ---------------------------------------------------------------------------
# Example: reproduce the y = (a + b) . c circuit from this conversation
# ---------------------------------------------------------------------------
# if __FILE__ == $0
#   or_gate = GateASP.new(inputs: ["a", "b"], output: "w", delay_r: 2, delay_f: 1) do |v|
#     v[0] | v[1]
#   end

#   and_gate = GateASP.new(inputs: ["w", "c"], output: "y", delay_r: 2, delay_f: 1) do |v|
#     v[0] & v[1]
#   end

#   puts or_gate.to_asp
#   puts
#   puts and_gate.to_asp
# end
