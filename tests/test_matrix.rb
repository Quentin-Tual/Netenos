require_relative '../lib/enoslist.rb'
require_relative '../lib/converter/matrix.rb'

runner = Netlist::Wrapper.new
runner.randgen(['test_matrix'])

matrix_converter = Netlist::ConvNetlist2Matrix.new runner.netlist
adj_mat = matrix_converter.start

pp matrix_converter.id_tab
