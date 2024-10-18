
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
include Netlist

def gen_case 
    @generator = Netlist::RandomGenComb.new 7, 7, 8, [:even, 0.75]
    @circ = @generator.getRandomNetlist "test"
    puts "Original circuit has combinational loop: #{@circ.has_combinational_loop?}"
    pp @circ.getNetlistInformations :int_multi
    @timings_h = @circ.get_timings_hash
    @slack_h = @circ.get_slack_hash
    # generator = nil

    @viewer = Converter::DotGen.new
    @viewer.dot @circ, "./rand_circ.dot"

    @modifier = Inserter::Tamperer.new(@circ.clone, @generator.grid, @timings_h)
    @modifier.select_ht("og_s38417")
end

gen_case 

begin
    attempts ||= 0
    @modified = @modifier.insert2 
    puts "Modified circuit has combinational loop: #{@modified.has_combinational_loop?}"
rescue Inserter::ImpossibleInsertion, Inserter::ImpossibleResolution
    if $VERBOSE
        puts "Insertion attempt number #{attempts}"
    end

    if (attempts += 1) < 5
        gen_case
        retry
    else 
        raise "Error : Unable to insert with given netlist generation parameters"
    end
end

puts @modifier.get_ht_stage

pp @circ.getNetlistInformations :int_multi
pp @modified.getNetlistInformations :int_multi
@viewer.dot(@modified, 'rand_circ_mod.dot')
# end
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)