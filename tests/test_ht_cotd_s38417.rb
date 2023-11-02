require '../lib/netenos.rb'

include Netlist

# ! Need to uncomment the DEBUG commented line in lib/inserter/og_s38417_T100.rb

ht = Cotd_s38417.new 

wrapper = Circuit.new "test"
ht.components.each {|comp| wrapper << comp}

viewer = DotGen.new
viewer.dot wrapper



