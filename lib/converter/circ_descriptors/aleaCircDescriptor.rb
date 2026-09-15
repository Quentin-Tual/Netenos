# frozen_string_literal: true

module Converter
  
  class AleaCircDescriptor < ClassicCircDescriptor

    def initialize(*args)
      super(*args)
      raise "Error: expecting :noise_rate option for initialization" unless @opts[:noise_rate]
      raise "Error: expecting real value associated to :noise_rate option" unless @opts[:noise_rate].is_a? Float
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
          delay_min = (delay * (1.0 - @opts[:noise_rate])).to_i
          delay_max = (delay * (1.0 + @opts[:noise_rate])).to_i
          code << "generic map(#{delay_min} fs, #{delay_max} fs, #{rand(1..100000)}, #{rand(1..100000)})"
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