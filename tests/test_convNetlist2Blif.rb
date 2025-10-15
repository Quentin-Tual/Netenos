require 'fileutils'

require_relative '../lib/netenos'
require_relative '../lib/converter/convNetlist2Blif'

c = Converter::ConvBlif2Netlist.new.convert("circ.blif", truth_table_format: false)

uut = Converter::ConvNetlist2Blif.new
uut.print(c, "test_convNetlist2Blif.blif")

# ! Names of the ports are lost duringthe process, not possible to just compare the files, prefer a structural comparison, as a matrix for example
# same_content = FileUtils.compare_file("circ.blif", "test_convNetlist2Blif.blif")

# if same_content
#   puts "Test passed !"
# else 
#   puts "Error: Test failed !"
# end

