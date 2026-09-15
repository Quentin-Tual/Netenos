module Converter
  class DotGen
    attr_accessor :code

    def dot(circuit, path = nil, delay_model = :int_multi)
      @code = Code.new
      @sym_tab = {}
      head circuit.name
      comp circuit.components, delay_model
      const circuit.constants
      ios circuit.ports
      wiring circuit
      circuit.components.each { |comp| comp_wiring(comp) }
      foot circuit.name, path
    end

    def head(name)
      # @code << "# Test"
      @code << "digraph #{name} {"
      @code.indent = 2
      @code << 'graph [rankdir = LR];'
    end

    def ios(ports)
      ports.each do |_dir, ports|
        ports.each do |port|
          @code << "#{port.name}[shape=cds,xlabel=\"#{port.name}\"]"
          @sym_tab[port.name] = Netlist::Port
        end
      end
    end

    def const(constants)
      constants.each do |const|
        @code << "#{const.name}[shape=cds,xlabel=\"#{const.name}\"]"
        @sym_tab[const.name] = Netlist::Constant
      end
    end

    def comp(components, delay_model)
      components.each do |comp|
        inputs = comp.get_inputs.map { |port| "<#{port.name}>#{port.name}" }.join('|')
        outputs = comp.get_outputs.map { |port| "<#{port.name}>#{port.name}" }.join('|')
        fanin = "{#{inputs}}"
        fanout = "{#{outputs}}"
        label = "{#{fanin}|{#{comp.name}|{#{comp.propag_time[delay_model]}|#{comp.cumulated_propag_time}}}|#{fanout}}"
        color = if comp.tag == :ht
                  'orange1'
                elsif comp.tag == :target_path
                  'red'
                else
                  'cadetblue'
                end
        code << "#{comp.name}[shape=record; style=\"rounded,filled\"; fillcolor=#{color}; label=\"#{label}\"]"
        @sym_tab[comp.name] = Netlist::Circuit
      end
    end

    def wiring(circuit)
      source_list = circuit.get_inputs + circuit.constants
      source_list.each do |source|
        source.get_sinks.each do |sink|
          if sink.class == Netlist::Wire
            wire sink, source
          else
            write_wiring source, sink
          end
        end
      end
    end

    def comp_wiring(comp)
      comp.get_outputs.each do |source|
        source.get_sinks.each do |sink|
          if sink.class == Netlist::Wire
            wire sink, source
          else
            write_wiring source, sink
          end
        end
      end
    end

    def wire(w, source)
      # wireName = "w#{source.get_dot_name}"
      @code << "#{w.get_dot_name}[shape=point];"
      @code << "#{source.get_dot_name} -> #{w.get_dot_name}[arrowhead=none,label=#{w.name}]"

      raise "Error: empty fanout for wire #{w.name}" if w.get_sinks.empty?

      w.get_sinks.each do |sink|
        write_wiring w, sink
      end
    end

    def write_wiring(source, sink)
      @code << "#{source.get_dot_name} -> #{sink.get_dot_name};"
    end

    def foot(circuit_name, path)
      code.indent = 0
      code << '}'
      # puts code.finalize # Debug print
      if !path.nil?
        code.save_as "#{path}", false, true
        puts "[+] Schematic generated : \'#{path}\'" if $VERBOSE
        "#{path}"
      else
        code.save_as "#{circuit_name}.dot", false, true
        puts "[+] Schematic generated : \'#{circuit_name}.dot\'" if $VERBOSE
        "#{circuit_name}.dot"
      end
    end
  end
end
