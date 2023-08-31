require_relative '../lib/netenos.rb'
require_relative '../lib/converter/convNetlist2Matrix.rb'

runner = Netlist::Wrapper.new
runner.randgen(['test_matrix'])

circ_generator = Netlist::RandomGenComb.new 20, 10, 10, 5
circ =  circ_generator.getRandomNetlist

matrix_converter = Netlist::ConvNetlist2Matrix.new circ
adj_mat = matrix_converter.start
# pp matrix_converter.id_tab
pp adj_mat