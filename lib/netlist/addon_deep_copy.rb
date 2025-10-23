module Netlist
  class Circuit
    def deep_copy(new_name = "#{@name}_copy")
      @deep_copy_cache = {}
      new_circuit = Circuit.new(new_name)
      @deep_copy_cache[self.object_id] = new_circuit
      new_circuit.crit_path_length = @crit_path_length

      # Copy ports and cache them immediately
      new_circuit.ports = @ports.each_with_object({}) do |(direction, ports), h|
        h[direction] = ports.map do |port|
          new_port = port.dup
          new_port.partof = new_circuit
          cache_port_and_connections(port, new_port)
          new_port
        end
      end

      new_circuit.constants = @constants.map do |const|
        new_const = const.dup
        new_const.partof = new_circuit
        cache_port_and_connections(const, new_const)
        new_const
      end

      # Copy components and their ports
      new_circuit.components = @components.map do |comp|
        new_comp = comp.is_a?(Gate) ? comp.dup : comp.deep_copy
        new_comp.partof = new_circuit
        @deep_copy_cache[comp.object_id] = new_comp

        # Cache component ports
        comp.get_inputs.each_with_index do |input, i|
          new_input = new_comp.get_inputs[i]
          cache_port_and_connections(input, new_input)
        end
        comp.get_outputs.each_with_index do |output, i|
          new_output = new_comp.get_outputs[i]
          cache_port_and_connections(output, new_output)
        end

        new_comp
      end

      # Copy wires
      new_circuit.wires = @wires.map do |wire|
        new_wire = wire.dup
        new_wire.partof = new_circuit
        @deep_copy_cache[wire.object_id] = new_wire
      end

      reconnect_all(new_circuit)
      new_circuit
    ensure
      @deep_copy_cache = nil
    end

    private

    def cache_port_and_connections(old_port, new_port)
      @deep_copy_cache[old_port.object_id] = new_port
      # Cache any existing connections
      if old_port.fanin
        @deep_copy_cache[old_port.fanin.object_id] ||= new_port.fanin if new_port.fanin
      end
      old_port.fanout.each_with_index do |sink, i|
        @deep_copy_cache[sink.object_id] ||= new_port.fanout[i] if new_port.fanout[i]
      end
    end

    def reconnect_all(new_circuit)
      # Reconnect using cache
      reconnect_elements = @constants + @ports.values.flatten + @components.flat_map{|c| c.get_ports} + @wires
      reconnect_elements.each do |obj|
        new_obj = @deep_copy_cache[obj.object_id]
        # next unless new_obj # can happen ?
        raise "Error: No copied object cached for #{obj}" if new_obj.nil?

        # Reconnect fanin
        if obj.fanin && (new_source = @deep_copy_cache[obj.fanin.object_id])
          new_obj.instance_variable_set(:@fanin, new_source)
        end

        # Reconnect fanout
        if obj.fanout.any?
          new_fanout = obj.fanout.map { |sink| @deep_copy_cache[sink.object_id] }.compact
          new_obj.instance_variable_set(:@fanout, new_fanout)
        end
      end
    end
  end

  class Gate
    def dup
      new_gate = self.class.new(@name.dup)
      new_gate.instance_variable_set(:@propag_time, @propag_time)
      new_gate.instance_variable_set(:@cumulated_propag_time, @cumulated_propag_time)
      
      # Copy ports immediately and maintain connections
      new_inputs = @ports[:in].map { |p| p.dup.tap { |np| np.partof = new_gate } }
      new_outputs = @ports[:out].map { |p| p.dup.tap { |np| np.partof = new_gate } }
      new_gate.instance_variable_set(:@ports, { in: new_inputs, out: new_outputs })
      
      new_gate
    end
  end

  class Wire
    def dup
      new_wire = self.class.new(@name.dup)
      new_wire.instance_variable_set(:@propag_time, @propag_time)
      new_wire.instance_variable_set(:@cumulated_propag_time, @cumulated_propag_time)

      new_wire
    end
  end

  class Port
    def dup
      self.class.new(@name.dup, @direction.dup)
    end
  end
end