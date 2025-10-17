require 'fileutils'

require_relative '../lib/netenos'
require_relative '../lib/converter/convNetlist2Bench'

c = Converter::ConvBlif2Netlist.new.convert("circ.blif", truth_table_format: false)

uut = Converter::ConvNetlist2Bench.new
uut.print(c, "test_convNetlist2Bench.bench")

# ! Names of the ports are lost duringthe process, not possible to just compare the files, prefer a structural comparison, as a matrix for example
