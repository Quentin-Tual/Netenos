module Delays
  
  class SlackAnalyzer < Netlist::BackwardUniqDFS
    attr_reader :slack

    def initialize nl, timings
      super(nl)
      @timings = timings
      @slack = Hash.new(Float::INFINITY)

      # @nl.get_outputs.each do |ip|
      #   @slack[ip] = Float::INFINITY
      # end
    end
    
    def [] sig
      @slack[sig]
    end

    def analyze
      @nl.get_outputs.each do |op|
        op.accept(self)
      end
      @slack
    end

    def visit_Wire w
      update_slack(w.get_source, @slack[w])
      super
    end

    def visit_Port p
      super
    end

    def visit_Gate g
      inputs = g.get_inputs
      ip_timings = inputs.collect{|ip| @timings[ip]}
      max = ip_timings.max
      inputs.each do |ip|
        slack = (max - @timings[ip]) + @slack[g]
        update_slack(ip, slack)
        update_slack(ip.get_source, slack)
      end
      super
    end

    private 

    def update_slack obj, val
      if @slack[obj] > val 
        @slack[obj] = obj.slack = val
      end
    end

    # def get_all_inputs
    #   @nl.get_inputs + @nl.components.collect{|g| g.get_inputs}
    # end

    def visit_prim_output op
      update_slack(op, 0)
      update_slack(op.get_source, 0)
      super
    end

    def visit_gate_output op
      update_slack(op.partof, @slack[op])
      super
    end

    def visit_prim_input op
      # do nothing
    end
  end
end
