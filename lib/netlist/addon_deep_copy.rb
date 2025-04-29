  # In circuit.rb
  module Netlist
    class Circuit
      def deep_copy(new_name = "#{@name}_copy")
        # Create new circuit instance
        new_circuit = Circuit.new(new_name)
        new_circuit.crit_path_length = @crit_path_length
        
        # Copy ports (inputs and outputs)
        @ports.each do |direction, ports|
          ports.each do |port|
            new_port = port.dup
            new_port.partof = new_circuit
            new_circuit.ports[direction] << new_port
          end
        end
        
        # Copy components (gates and subcircuits)
        @components.each do |comp|
          if comp.is_a?(Gate)
            new_comp = comp.dup
            new_comp.partof = new_circuit
            new_circuit.components << new_comp
          else
            # Handle subcircuits if needed
            new_comp = comp.deep_copy
            new_comp.partof = new_circuit
            new_circuit.components << new_comp
          end
        end
        
        # Copy wires and reconnect everything
        @wires.each do |wire|
          new_wire = wire.dup
          new_wire.partof = new_circuit
          new_circuit.wires << new_wire
        end
        
        # Reconnect all ports and wires
        reconnect_ports_and_wires(new_circuit)
        
        new_circuit
      end
      
      private
      
      def reconnect_ports_and_wires(new_circuit)
        # Reconnect all ports and wires based on names
        @ports.each do |direction, ports|
          ports.each do |port|
            new_port = new_circuit.get_port_named(port.name)
            reconnect_wires(port, new_port, new_circuit)
          end
        end
        
        @components.each do |comp|
          new_comp = new_circuit.get_component_named(comp.name)
          comp.get_inputs.each do |input|
            new_input = new_comp.get_inputs.find { |i| i.name == input.name }
            reconnect_wires(input, new_input, new_circuit)
          end
          comp.get_outputs.each do |output|
            new_output = new_comp.get_outputs.find { |o| o.name == output.name }
            reconnect_wires(output, new_output, new_circuit)
          end
        end
      end
      
      def reconnect_wires(old_interface, new_interface, new_circuit)
        # Reconnect fanin
        if old_interface.fanin
          source_name = old_interface.fanin.get_full_name
          if old_interface.fanin.is_a?(Port)
            new_source = new_circuit.get_port_named(source_name) || 
                        new_circuit.components.flat_map(&:get_ports).find { |p| p.get_full_name == source_name }
          else # Wire
            new_source = new_circuit.wires.find { |w| w.name == source_name }
          end
          new_interface <= new_source if new_source
        end
        
        # Reconnect fanout
        old_interface.fanout.each do |sink|
          sink_name = sink.get_full_name
          if sink.is_a?(Port)
            new_sink = new_circuit.get_port_named(sink_name) || 
                      new_circuit.components.flat_map(&:get_ports).find { |p| p.get_full_name == sink_name }
          else # Wire
            new_sink = new_circuit.wires.find { |w| w.name == sink_name }
          end
          new_sink <= new_interface if new_sink
        end
      end
    end
  end
  
  # In gate.rb and port.rb, add dup methods:
  module Netlist
    class Gate
      def dup
        new_gate = self.class.new(@name.dup)
        new_gate.propag_time = @propag_time.dup
        new_gate.cumulated_propag_time = @cumulated_propag_time
        new_gate
      end
    end
  
    class Port
      def dup
        new_port = self.class.new(@name.dup, @direction)
        new_port.slack = @slack
        new_port.cumulated_propag_time = @cumulated_propag_time
        new_port
      end
    end
  
    class Wire
      def dup
        new_wire = self.class.new(@name.dup)
        new_wire.cumulated_propag_time = @cumulated_propag_time
        new_wire
      end
    end
  end