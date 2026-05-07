require_relative "./netlist/circuit.rb"
require_relative "./netlist/gate.rb"
require_relative "./netlist/port.rb"
require_relative "./netlist/wire.rb"
require_relative "./netlist/register.rb"
require_relative "./netlist/randomGenComb.rb"
require_relative "./netlist/randomGenSeq.rb"
require_relative "./netlist/addon_deep_copy.rb"

require_relative 'netlist/circuitVisitor'
require_relative 'netlist/backwardUniqDFS'
require_relative 'netlist/forwardDFS'
require_relative 'netlist/path_lister'

# TESTS, lib adds
# require_relative "../tests/test_lib.rb"