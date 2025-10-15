# frozen_string_literal: true

module Converter
  
  class AleaCircDescriptor < ClassicCircDescriptor

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
          delay = comp.propag_time[@delay_model]*1000
          delay_min = (delay * (1 - @opts[:noise_rate])).to_i
          # delay_max = (delay * (1 + @opts[:noise_rate])).to_i
          delay_max = delay
          code << "generic map(#{delay_min} fs, #{delay_max} fs)"
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

  end
end