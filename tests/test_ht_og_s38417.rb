require '../lib/netenos.rb'

include Netlist
include Inserter

# ! Need to uncomment the DEBUG commented line in lib/inserter/og_s38417_T100.rb

ht = Og_s38417.new 8

wrapper = Circuit.new "test"
ht.components.map {|comp| wrapper << comp}

viewer = Converter::DotGen.new
viewer.dot wrapper



