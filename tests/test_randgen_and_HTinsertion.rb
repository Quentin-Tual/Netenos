
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
    include Netlist


    generator = Netlist::RandomGenComb.new 50, 25, 15, 10
    generator.getRandomNetlist "test"
    # generator = nil

    viewer = Converter::DotGen.new
    viewer.dot generator.netlist, "./rand_circ.dot"

    modifier = Inserter::Tamperer.new(generator.netlist)
    modifier.select_ht("cotd_s38417")
    modified = modifier.insert 

    viewer.dot(modified, 'rand_circ_mod.dot')
# end
    puts modified.name
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)