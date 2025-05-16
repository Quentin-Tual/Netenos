# frozen_string_literal: true

module Converter
  # generates the vhdl description for each component/gate of the gtech for a integer intertial delay model with fixed delay for each gate
  class ClassicGtechGenerator < GtechGenerator
    def initialize
      super
      @engine = ERB.new(IO.read("#{File.dirname(__FILE__)}/../gtech_templates/classic_gtech.erb"))
    end

    def func_code(klass, klass_instance)
      case @src_parts[:entity_name]
      when 'not_d'
        klass.new
        'o0 <= not i0 after delay;'
      when 'buffer_d'
        klass.new
        'o0 <= i0 after delay;'
      else
        func_code_util(klass, klass_instance)
      end
    end

    def func_code_util(klass, klass_instance)
      gate_type_class = klass.superclass
      vhdl_op = gate_type_class::VHDL_OP
      vhdl_prefix = gate_type_class::VHDL_PREFIX
      assign_lhs = klass_instance.get_outputs.first.name
      assign_rhs = klass_instance.get_inputs.map(&:name).join(" #{vhdl_op} ")
      assign_rhs = "#{vhdl_prefix}(#{assign_rhs})" if vhdl_prefix != ''
      "#{assign_lhs} <= #{assign_rhs} after delay;"
    end
  end


end