#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
include Netlist

CRIT_PATH_LENGTH = 15
ITERATIONS = 2000

lengths_occ = Hash.new(0)


ITERATIONS.times do |i|
    generator = Netlist::RandomGenComb.new 8, 4, CRIT_PATH_LENGTH, [:even, 0.50]
    circ = generator.getRandomNetlist "test"
    crit_path = circ.get_exact_crit_path_length :one
    lengths_occ[crit_path] += 1
end

pp lengths_occ