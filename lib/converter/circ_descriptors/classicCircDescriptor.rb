# frozen_string_literal: true

module Converter
  
  class ClassicCircDescriptor < CircDescriptor

    def initialize(*args)
      super(*args)
      @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/circ_template.erb"))
    end

    def components_interconnect
      code = Code.new
      @netlist.components.each do |comp|
        comp_entity=comp.class.to_s.split("::").last.downcase
        code << "#{comp.name} : entity gtech_lib.#{comp_entity}_d"
        code.indent=2
        if comp.is_a? Netlist::Gate
          code << "generic map(#{(comp.propag_time[@delay_model]*1000).to_i} fs)" # * Conversion from nanoseconds into picoseconds to avoid float in vhdl source code
        end
        code << "port map("
        code.indent=3
        components_interconnect_inputs(code,comp)
        components_interconnect_outputs(code,comp)
        code.indent=2
        code << ");"
      end
      code.finalize
    end

    def components_interconnect_inputs(code, comp)
      comp.get_inputs.each do |input|
        if input.get_source.is_a?(Netlist::Constant)
            if input.get_source.instance_of?(Netlist::Zero)
                code << "#{input.name} => '0',"
            else
                code << "#{input.name} => '1',"
            end 
        else    
            code << "#{input.name} => #{input.get_source.get_full_name},"
        end
      end
    end

    def components_interconnect_outputs(code,comp)
      comp.get_outputs.each do |output|
        if output.get_sinks[0].class == Netlist::Wire
          code << "#{output.name} => #{output.get_sinks[0].get_full_name},"
        else
          code << "#{output.name} => #{output.get_full_name},"
        end
      end
      code.lines[-1].delete_suffix!(",")
    end

  end
end