require_relative '../lib/netenos'
require_relative '../lib/netlist/forwardDFS'

$DEBUG = true

nl_path = 'tests/verilog/xor5_prepnr.nl.v' 
nl = Verilog.load_netlist(nl_path)
nl.get_dot_graph
`mv #{nl.name}.dot tests/tmp`

uut = Netlist::ForwardDFS.new(nl)
nl.get_inputs.last.accept(uut)
