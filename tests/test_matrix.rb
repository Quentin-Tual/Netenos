require_relative '../lib/netenos.rb'

runner = Netlist::Wrapper.new
runner.randgen(['test_matrix'])

circ_generator = Netlist::RandomGenComb.new 5, 2, 3
circ =  circ_generator.getRandomNetlist

visualizer = Netlist::DotGen.new
path = visualizer.dot circ
system("xdot #{path} &")

matrix_converter = Netlist::ConvNetlist2Matrix.new circ
adj_mat = matrix_converter.start
# pp matrix_converter.id_tab
# pp adj_mat

adj_mat.each do |row|
    print row
    puts
end

pp matrix_converter.getAdjList

pp matrix_converter.id_tab