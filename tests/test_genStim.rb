require_relative '../lib/netenos.rb'
require_relative '../lib/converter/genStim2.rb'
require 'ruby-prof'


# pp "Started"

Dir.chdir("tmp") do 

    generator = Netlist::RandomGenComb.new 15, 4, 15 # Mini ---> 36 gates
    rand_circ = generator.getRandomNetlist "test"

    # Converter::DotGen.new.dot generator.netlist, "./rand_circ2.dot"

    foo = Converter::GenStim.new(rand_circ)
    # # pp foo.gen_random_stim(20)

    # profiler = RubyProf::Profile.new
    # profiler.start

    stim_seq = foo.gen_exhaustive_incr_stim
    # # pp stim_seq
    foo.save_as_txt("test.txt")

    # puts "Test sequence length : #{stim_seq.values[0].length}"

    # foo = Converter::GenStim.new(rand_circ)
    test_vec = foo.load_txt("test.txt")

    # pp test_vec
    # test_vec.slice!(0)
    # pp test_vec 

    # puts test_vec.include? nil

    foo.extend_exh_trans_in_file(test_vec, "filtered_stim.txt")
    # extended_test_vec = foo.extend_exhaustive_all_trans(test_vec)

    # puts test_vec.include? nil

    # pp extended_test_vec
    # result = profiler.stop
    # print a flat profile to text
    # printer = RubyProf::FlatPrinter.new(result)
    # printer.print(STDOUT)

end

# pp "Terminated"