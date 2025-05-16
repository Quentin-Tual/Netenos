require_relative '../lib/netlist/circuit'
require_relative '../lib/netlist/gate2'
require_relative '../lib/converter/gtechGenerator'
require_relative '../lib/converter/gtechGenerators/classicGtechGenerator'

Dir.chdir('tests/tmp') do 
  # générer la gtech 
  Netlist::generate_gtech
  
  Dir.mkdir('gtech') unless File.exist?('gtech')
  Dir.chdir('gtech') do
    gtech_generator = Converter::ClassicGtechGenerator.new
    gtech_generator.gen_gtech
  end
end