#! /usr/env/bin ruby    

require_relative "../lib/enoslist.rb"

generator = Netlist::RandomGenSeq.new 150, 30, 40
rand_circ = generator.getRandomNetlist "test"

Netlist::DotGen.new.dot generator.netlist, "./rand_circ.dot"

inf = generator.getNetlistInformations
puts "Input number : #{inf[0]}"
puts "Output number : #{inf[1]}"
puts "Component number : #{inf[2]}"
puts "Critical path length : #{inf[3]}"
pp "Terminated."