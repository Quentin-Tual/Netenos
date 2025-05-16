# frozen_string_literal: true

module Converter
  # generates the vhdl description for each component/gate of the gtech for a integer intertial delay model with "noised" delay for each gate
  class AleaGtechGenerator < GtechGenerator
    def initialize
      super
      @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/../gtech_templates/alea_gtech.erb"))
    end

    # ! adapt to alea
    def func_code(klass, klass_instance)
      case @src_parts[:entity_name]
      when 'not_d'
        klass.new
        'o0 <= not i0 after rand_time(delay_min, delay_max, 1000 fs);'
      when 'buffer_d'
        klass.new
        'o0 <= i0 after rand_time(delay_min, delay_max, 1000 fs);'
      else
        func_code_util(klass, klass_instance)
      end
    end

    # ! adapt to alea
    def func_code_util(klass, klass_instance)
      gate_type_class = klass.superclass
      vhdl_op = gate_type_class::VHDL_OP
      vhdl_prefix = gate_type_class::VHDL_PREFIX
      assign_lhs = klass_instance.get_outputs.first.name
      assign_rhs = klass_instance.get_inputs.map(&:name).join(" #{vhdl_op} ")
      assign_rhs = "#{vhdl_prefix} #{assign_rhs}" if vhdl_prefix != ''
      "#{assign_lhs} <= #{assign_rhs} after rand_time(delay_min, delay_max, 1000 fs);"
    end
  end


end