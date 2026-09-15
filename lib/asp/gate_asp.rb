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
      lines.concat(rules_for(rising: true))
      lines << '%'
      lines.concat(rules_for(rising: false))
      lines.join("\n")
    end

    private

    def nonempty_subsets(arr)
      (1...(1 << arr.size)).map { |mask| arr.select.with_index { |_, i| mask[i] == 1 } }
    end

    def rules_for(rising:)
      delay = rising ? @delay_r : @delay_f
      edge  = rising ? 'r' : 'f'
      from_val, to_val = rising ? [false, true] : [true, false]
      idxs = (0...@n).to_a # input ID list

      rules = []
      # Pour chaque sous-ensemble d'entrées
      nonempty_subsets(idxs).each do |subset|
        others = idxs - subset # autres entrées ne faisant pas partie de la sélection
        # Enumerate every 0/1 combination for the "steady" (non-transitioning)
        # inputs in `others`, using an integer `m` as a bitmask/counter:
        #   - `1 << others.size` = 2^(number of steady inputs) = total combos.
        #   - each value of `m`, read in binary, IS one combination: bit k of
        #     `m` gives the value (0 or 1) assigned to the k-th input in `others`.
        # Example: others = [1, 3] (2 steady inputs) => m ranges 0..3:
        #   m=0 (00) -> vals[1]=0, vals[3]=0
        #   m=1 (01) -> vals[1]=1, vals[3]=0
        #   m=2 (10) -> vals[1]=0, vals[3]=1
        #   m=3 (11) -> vals[1]=1, vals[3]=1
        (0...(1 << others.size)).each do |m|
          vals = Array.new(@n)
          others.each_with_index do |idx, k|
            # (m >> k): shift m right by k bits, so bit k becomes the lowest bit.
            # & 1: keep only that lowest bit (isolates bit k of m).
            vals[idx] = (m >> k) & 1
          end

          before = vals.collect { |v| v == 1 }
          after  = vals.collect { |v| v == 1 }
          subset.each do |idx|
            before[idx] = from_val
            after[idx] = to_val
          end

          puts "before (#{before}) : #{@fn.call(before)}"
          puts "from_val : #{from_val}"
          puts "after (#{after}) : #{@fn.call(after)}"
          puts "to_val : #{to_val}"

          next unless @fn.call(before) == from_val && @fn.call(after) == to_val

          rules << build_rule(subset, others, vals, edge, delay)
        end
      end
      rules.uniq
    end

    def build_rule(subset, others, vals, edge, delay)
      head = "event(#{@output}, #{edge}, T)"

      trans_atoms  = subset.map { |idx| "event(#{@inputs[idx]}, #{edge}, T-#{delay})" }
      steady_atoms = others.map do |idx|
        lvl = vals[idx] == 1 ? 's1' : 's0'
        "steady(#{@inputs[idx]}, #{lvl}, T-#{delay})"
      end

      body = (trans_atoms + steady_atoms + ['time(T)']).join(', ')
      "#{head} :- #{body}."
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
