
#! /usr/env/bin ruby    
require_relative "../lib/enoslist.rb"
require 'ruby-prof'

result = RubyProf.profile do
    include Netlist


    generator = Netlist::RandomGenComb.new 100, 60, 40, 20
    generator.getRandomNetlist "test"
    # generator = nil

    viewer = Netlist::DotGen.new
    viewer.dot generator.netlist, "./rand_circ.dot"

    modifier = Netlist::Tamperer.new(generator.netlist)
    modifier.select_ht("xor_and", 8)
    modified = modifier.insert 

    viewer.dot(modified, 'rand_circ_mod.dot')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)