require_relative '../lib/netlist/circuit'
require_relative '../lib/netlist/gate2'
require_relative '../lib/converter/gtechGenerator'
require_relative '../lib/converter/gtech_generators/classicGtechGenerator'
require_relative '../lib/converter/circDescriptor'
require_relative '../lib/converter/circ_descriptors/classicCircDescriptor'
require_relative '../lib/netlist'

Dir.chdir('tests/tmp') do
  Netlist::generate_gtech
  
  Dir.mkdir('gtech') unless File.exist?('gtech')
  Dir.chdir('gtech') do
    gtech_generator = Converter::ClassicGtechGenerator.new
    gtech_generator.gen_gtech

    Converter::VhdlCompiler.new.gtech_makefile(".", :ghdl)
    `make`
  end

  # Générer ou charge un circuit 
  circ_generator = Netlist::RandomGenComb.new(8, 4, 6, [:custom, 0.75])
  circ = circ_generator.getRandomNetlist "test"

  # Créer un objet de classe ClassicCircDescriptor
  descriptor = Converter::ClassicCircDescriptor.new(circ, :int_multi)
  # Générer une description du circuit 
  descriptor.gen_description

  `ghdl -a --std=08 -P=gtech test.vhd`
  `ghdl -e --std=08 -P=gtech test`
end