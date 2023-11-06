require_relative '../lib/converter/genTestbench.rb'
require_relative '../lib/netenos.rb'
require_relative '../lib/converter/convNetlist2Vhdl copy.rb'
require_relative '../lib/converter/vhdlCompileScript.rb'

name = "rand_circ"
path = "./#{name}"

generator = Netlist::RandomGenComb.new #100, 20, 20, 25
rand_circ = generator.getRandomNetlist name


Converter::DotGen.new.dot generator.netlist, "#{path}.dot"

tb_generator = Converter::GenTestbench.new(rand_circ)
File.write("#{path}_tb.vhd", tb_generator.gen_testbench)


vhdl_converter = Converter::ConvNetlist2Vhdl_refactor.new
vhdl_converter.gen_gtech
vhdl_converter.generate rand_circ
# rev_source_code = vhdl_converter.get_timed_vhdl rand_circ
# File.write("#{path}.vhd",rev_source_code)s

Converter::VhdlCompiler.new.generate_compile_script rand_circ
Converter::VhdlCompiler.new.run_compile_script rand_circ