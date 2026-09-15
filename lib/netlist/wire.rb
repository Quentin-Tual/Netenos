module Netlist
  class Wire
    attr_accessor :name, :fanin, :fanout, :partof, :propag_time, :cumulated_propag_time, :slack

    def initialize(name)
      @name = name
      @fanin = nil # Always only one source to the input
      @fanout = []
      @partof = nil
      @propag_time = { one: 0, int: 0.0, int_multi: 0, int_rand: 0.0, fract: 0.0, sdf: 0 }
      @cumulated_propag_time = 0
      @slack = nil
    end

    def accept(visitor)
      visitor.visit_Wire(self)
    end

    def <=(other)
      raise 'Error: nil source given.' if other.nil?

      if other.is_a?(Port) && !other.is_global? and other.is_input?
        raise "Error : This port #{other.get_full_name} is a non global input and can't be used as a source."
      end

      if is_a?(Port) && !is_global? and is_output?
        raise "Error : This port #{get_full_name} is a non global output and can't be used as a sink."
      end

      if other.is_a? Port or other.is_a? Wire
        other.fanout << self
      # elsif source.is_a? Reverse::InvertedGate
      #     source.source << self
      #     @fanin = source
      else
        # pp source.class #!DEBUG
        other.get_free_input << self
      end

      if @fanin.nil?
        @fanin = other
      else
        unless @fanin == other
          raise "Error : Interface #{get_full_name} of #{partof.name} already has #{@fanin.get_full_name} as a source, please verify."
        end
      end
    end

    def pretty_print(pp)
      pp.text get_full_name
    end

    def get_source
      @fanin
    end

    def get_sinks
      @fanout
    end

    def get_source_comp
      get_source.class.name == 'Netlist::Wire' ? @fanin : @fanin.partof
    end

    def get_sinks_comp
      get_sinks.collect do |sink|
        if sink.class.name == 'Netlist::Wire'
          sink
        else
          sink.partof
        end
      end
    end

    def get_sink_gates
      get_sinks.collect do |sink|
        if sink.instance_of? Netlist::Port and sink.is_global?
          sink
        elsif sink.instance_of? Netlist::Wire
          sink.fanout.collect { |in_p| in_p.partof }
        else
          sink.partof
        end
      end.flatten
    end

    def get_source_gates
      source = get_source
      if source.is_a? Netlist::Port and source.is_global?
        source
      elsif source.instance_of? Netlist::Wire
        source.get_source_gates
      else
        source.partof
      end
    end

    def get_source_cumul_propag_time
      return @fanin.cumulated_propag_time if @fanin.class.name == 'Netlist::Wire' or @fanin.is_global?

      @fanin.partof.cumulated_propag_time
    end

    def get_full_name
      @name
    end

    def get_dot_name
      "w#{@name}"
    end

    def get_asp_name
      "#{@partof.name}_#{name}"
    end

    def is_global?
      true
    end

    def is_wire?
      true
    end

    def unplug(interface_name) # * : Apply only to sinks, won't work well on sources
      if @fanin.get_full_name == interface_name
        @fanin.fanout.delete(@fanin.get_sink_named(@name))
        @fanin = nil
      else
        get_sink_named(interface_name).fanin = nil
        fanout.select! { |sink| sink.get_full_name == interface_name }
      end
    end

    def unplug2(interface_full_name)
      if has_source? # then self is a sink
        source = get_source
        if source.get_full_name != interface_full_name
          raise "Error : Impossible to unplug source #{interface_full_name} from sink #{get_full_name} because they does not seem connected."
        end

        source.fanout.delete self
        self.fanin = nil
        # In case we still need it later, return a reference
        source
      else # then self is a source
        sink = get_sink_named(interface_full_name.split($FULL_PORT_NAME_SEP)[1])
        if sink.nil?
          raise "Error : Impossible to unplug sink #{interface_full_name} from source #{get_full_name} because they does not seem connected."
        end

        sink.fanin = nil
        fanout.delete sink
        # In case we still need it later, return a reference
        sink
      end
    end

    def get_sink_named(name)
      fanout.find { |i| i.get_full_name == name }
    end

    def has_source?
      !fanin.nil?
    end

    def update_path_delay(elapsed, delay_model)
      @cumulated_propag_time = [elapsed + @propag_time[delay_model], @cumulated_propag_time].max
      get_sinks.each do |sink|
        if !sink.is_global?
          sink.partof.update_path_delay @cumulated_propag_time, delay_model
        else # sink.class.name == "Netlist::Wire" or sink.is_global?
          sink.update_path_delay @cumulated_propag_time, delay_model
        end
      end
    end

    def update_path_slack(slack)
      # @slack = [slack, @slack].min

      # * Only one "input" for a Wire
      # crit_node = [get_inputs.group_by{|in_p| in_p.get_source_cum_propag_time}.sort.last].to_h

      @slack = slack if @slack.nil? or slack < @slack

      source = get_source

      if source.nil?
        return if is_a? Netlist::Constant

        raise "nil source encountered for #{get_full_name} of class #{self.class}"

      end

      if source.is_a? Netlist::Constant
        source.slack = @slack
      elsif source.instance_of? Netlist::Wire
        source.update_path_slack(@slack)
      elsif source.instance_of? Netlist::Port
        if source.is_global?
          source.slack = @slack
        elsif !source.is_global?
          get_source_comp.update_path_slack(@slack)
        end
      end
      # end

      # * Thus if there is only one input there is no critical "node" regarding another
      # crit_node.values.each do |in_p|
      #     in_p.get_source_comp.update_path_slack(0.0 + @slack, delay_model)
      # end
    end

    def inside?(circ)
      if @partof.nil?
        false
      elsif @partof == circ or @partof.partof == circ
        true
      end
    end

    def to_hash
      {
        wire: {
          name: @name,
          fanin: @fanin.nil? ? nil : @fanin.name,
          fanout: @fanout == [] ? nil : @fanout.collect { |sink| sink.name }
        }
      }
    end
  end
end
