require_relative './netlist/circuit'
require_relative './netlist/gate'
require_relative './netlist/port'
require_relative './netlist/wire'
require_relative './netlist/register'
require_relative './netlist/randomGenComb'
require_relative './netlist/randomGenSeq'
require_relative './netlist/addon_deep_copy'

require_relative 'netlist/circuitVisitor'
require_relative 'netlist/backwardUniqDFS'
require_relative 'netlist/forwardDFS'
require_relative 'netlist/path_lister'

# TESTS, lib adds
# require_relative "../tests/test_lib.rb"
