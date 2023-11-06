
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
    include Netlist


    # generator = Netlist::RandomGenComb.new 50, 20, 10 # 98 gates
    generator = Netlist::RandomGenComb.new 100, 30, 20 # 258 gates
    generator.getRandomNetlist "test"
    # generator = nil

    viewer = Converter::DotGen.new
    viewer.dot generator.netlist, "./rand_circ.dot"

    modifier = Inserter::Tamperer.new(generator.netlist, generator.grid)
    modifier.select_ht("og_s38417")
    modified = modifier.insert("near_output")

    viewer.dot(modified, 'rand_circ_mod.dot')
# end
    # puts modified.name
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)