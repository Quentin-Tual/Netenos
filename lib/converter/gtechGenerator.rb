# frozen_string_literal: true

module Converter
  # generate the vhdl description for each component/gate of the gtech
  class GtechGenerator
    def initialize
      @gtech = Netlist::get_gtech
      @src_parts = {}
    end

    def gen_gtech
      puts '[+] generating VHDL gtech' if $VERBOSE

      @gtech.each do |klass|
        gen_src_parts(klass)
        src = @engine.result(binding)
        File.write("#{@src_parts[:entity_name]}.vhd", src)
        puts " |--[+] generated '#{filename}'" if $VERBOSE
      end
    end

    def gen_src_parts(klass)
      klass_instance = klass.new
      @src_parts[:entity_name] = klass_name(klass)
      @src_parts[:inputs_decl] = inputs_decl(klass_instance)
      @src_parts[:outputs_decl] = outputs_decl(klass_instance)
      @src_parts[:func_code] = func_code(klass, klass_instance)
    end

    def klass_name(klass)
      klass.name.split('::').last.downcase.concat('_d')
    end

    def inputs_decl(klass_instance)
      klass_instance.get_inputs.collect do |input|
        "\t\t#{input.name} : in  std_logic;"
      end.join("\n")
    end

    def outputs_decl(klass_instance)
      klass_instance.get_outputs.collect do |output|
        "\t\t#{output.name} : out  std_logic;"
      end.join("\n")
    end

    def func_code(klass, klass_instance)
      raise("Error: gtechGenerator is not supposed to be instantiated, use one of its subclasses instead.")
    end
  end
end
