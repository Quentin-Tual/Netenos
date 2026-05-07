require_relative '../lib/netenos'
require_relative '../lib/netlist/forwardDFS'
require_relative '../lib/netlist/path_lister'

$DEBUG = true

# nl_path = 'tests/verilog/xor5_prepnr.nl.v' 
nl_path = 'tests/verilog/f51m.nl.v'
nl = Verilog.load_netlist(nl_path)
nl.get_dot_graph
`mv #{nl.name}.dot tests/tmp`

uut = Netlist::PathLister.new(nl, nl.get_outputs.first)
# start_point = nl.get_outputs.first.get_source.get_source
start_point = nl.get_inputs[2]
res = start_point.accept(uut)

# res.map! do |path|
#   ['test'] + path
# end
# res = ['test'] + res

puts "Profondeur : #{res.depth}  Attendue : 2" 
puts "Nb paths : #{res.length}"
# res.each do |path|
#   path.each do |obj|
#     name = obj.is_a?(Netlist::Gate) ? obj.name : obj.get_full_name
#     pp name
#   end
#   puts
# end