require_relative '../lib/converter/genStim.rb'
require_relative '../lib/netenos.rb'

pp "Started"

generator = Netlist::RandomGenComb.new #100, 20, 20, 25
rand_circ = generator.getRandomNetlist "test"

Converter::DotGen.new.dot generator.netlist, "./rand_circ.dot"

foo = Converter::GenStim.new(rand_circ)
pp foo.gen_random_stim(20)
pp foo.save_csv_stim_as("test.csv")

pp "Terminated"