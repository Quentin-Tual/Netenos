# frozen_string_literal: true

module Converter
  # Generates a VHDl description of a given circuit
  class CircDescriptor 
    VHDL_IN_NAME_SEP='_'
    
    def initialize(netlist, delay_model, opts={})
      @netlist = netlist
      @delay_model = delay_model
      @src_parts = {}
      @opts = opts
    end

    def vhdl_full_name p
      p.get_full_name.tr($FULL_PORT_NAME_SEP,VHDL_IN_NAME_SEP)
    end

    def gen_description
      gen_src_parts
      src = @engine.result(binding)
      File.write("#{@src_parts[:entity_name]}.vhd", src)
      puts " |--[+] generated '#{filename}'" if $VERBOSE
    end

    def gen_src_parts
      @src_parts[:entity_name] = @netlist.name
      @src_parts[:inputs_decl] = inputs_decl
      @src_parts[:outputs_decl] = outputs_decl
      @src_parts[:signals_decl] = signals_decl
      @src_parts[:comp_interconnect] = components_interconnect
      @src_parts[:outputs_wiring] = outputs_wiring
    end

    def inputs_decl
      @netlist.get_inputs.collect do |input|
        "\t\t#{input.name} : in  std_logic;"
      end.join("\n")
    end

    def outputs_decl
      @netlist.get_outputs.collect do |output|
        "\t\t#{output.name} : out  std_logic;"
      end.join("\n")
    end

    def signals_decl
      txt = []
      wires = @netlist.wires.collect{|wire| wire.get_full_name}
      wires.each do |wire_name|
          txt << "\tsignal #{wire_name} : std_logic;"
      end
      signals = @netlist.components.collect{|comp| comp.get_outputs}.flatten
      signals.each do |sig|
          txt << "\tsignal #{vhdl_full_name(sig)} : std_logic;"
      end
      txt.join("\n")
    end

    def components_interconnect
      raise("Error: gtechGenerator is not supposed to be instantiated, use one of its subclasses instead.")
    end

    def outputs_wiring 
      txt = []
      @netlist.get_outputs.each do |output|
          if output.get_source.is_a? Netlist::Constant
              txt << "#{output.name} <= #{output.get_source.is_a?(Netlist::Zero) ? "'0'" : "'1'"};"
          else
              txt << "#{output.name} <= #{vhdl_full_name(output.get_source)};"
          end
      end
      txt.join("\n\t")
    end
  end
end