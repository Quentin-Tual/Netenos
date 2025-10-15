require_relative '../lib/netenos'

require_relative '../lib/netenos.rb'
require_relative '../lib/converter/genStim2.rb'
# require 'ruby-prof'


# pp "Started"

Dir.chdir("tests/tmp") do 

    circ = Converter::ConvBlif2Netlist.new.convert("../C17.blif")

    foo = Converter::GenStim.new(circ)

    # profiler = RubyProf::Profile.new
    # profiler.start

    stim_seq = foo.gen_atpg(circ)
    # # pp stim_seq
    # foo.save_as_txt("test.txt")

    # puts "Test sequence length : #{stim_seq.values[0].length}"

    # foo = Converter::GenStim.new(rand_circ)
    test_vec = foo.load_txt("stim.txt")

    pp test_vec
    # test_vec.slice!(0)
    # pp test_vec 

    # puts test_vec.include? nil

    # foo.extend_exh_trans_in_file(test_vec, "filtered_stim.txt")
    # extended_test_vec = foo.extend_exhaustive_all_trans(test_vec)

    # puts test_vec.include? nil

    # pp extended_test_vec
    # result = profiler.stop
    # print a flat profile to text
    # printer = RubyProf::FlatPrinter.new(result)
    # printer.print(STDOUT)

end

pp "Terminated"