require_relative '../lib/netenos.rb'
require_relative '../lib/converter/convNetlist2Vhdl copy.rb'


# TODO : Replace these variables by arguments passed
path = "./tmp"

test_frequencies = [1]
nb_trig = 4
nb_netlist = 1
result_csv = "name, freq, nb_sig_diff, nb_diff\n"
nb_sim_cycle = 100
results = []

# TODO : Create a directory for the experience at the specified path 
Dir.mkdir(path) unless File.exists?(path)
Dir.chdir(path) do

    # TODO : Generate GTECH  
    vhdl_converter = Netlist::ConvNetlist2Vhdl_refactor.new
    vhdl_converter.gen_gtech

    # TODO : Generate a netlist
    netlistGenerator = Netlist::RandomGenComb.new(20, 10, 10, 5)
    circ_init = netlistGenerator.getRandomNetlist("rand_tmp")

    # TODO : Generate the VHD files of the generated circuits
    vhdl_converter.generate circ_init

    # TODO : (optionnal) Generate a .dot file
    viewer = Netlist::DotGen.new
    viewer.dot circ_init

    # TODO : Generate a second netlist, half chance to be an altered version of the first, else it is the same one 
        # TODO : Alter it or just copy it
        if [1].sample == 1  # ! TEST add a 0 in the list, removed for tests
            # todo : alter it
            suffix = "altered"
            inserter = Netlist::Tamperer. new(circ_init.clone)
            inserter.select_ht("xor_and", nb_trig)
            circ_test = inserter.insert
            # trig_cond =  inserter.get_trigger_conditions
            # pp trig_cond # TEST
            circ_test.name = "#{circ_test.name}_#{suffix}" 
        else 
            # todo : only copy, modify the name without modifying the circ_init one !
            suffix = "copied"
            circ_test = circ_init.clone # ! verify if it works for the following steps 
            circ_test.name = "#{circ_test.name}_#{suffix}" 
        end

    # TODO : (optionnal) Generate a .dot file
    viewer.dot circ_test
        
    # # TODO : Get data/caracteristics from the netlist
    # netlistGenerator.netlist = circ_test
    # carac_test = netlistGenerator.getNetlistInformations

    stim_seq = Netlist::GenStim.new(circ_init).gen_random_stim(nb_sim_cycle)#, trig_cond)
    
    # TODO : Generate testbench for nominal frequency 
    tb_gen = Netlist::GenTestbench.new(circ_init)
    tb_gen.stimuli = stim_seq
    tb_init = tb_gen.gen_testbench :passed, test_frequencies.first

    tb_gen.netlist_data[:entity_name] = circ_test.name
    # tb_gen_test = Netlist::GenTestbench.new(circ_test)
    tb_gen.stimuli = stim_seq
    tb_test = tb_gen.gen_testbench :passed, test_frequencies.first

    # TODO : Write the tb file
    File.write("./#{circ_init.name}_#{test_frequencies.first.to_s}_tb.vhd", tb_init)
    File.write("./#{circ_test.name}_#{test_frequencies.first.to_s}_tb.vhd", tb_test)

    # TODO : Generate the VHD files of the generated circuits
    vhdl_converter.generate circ_test

    # TODO : Generate the compile and simulate script (convNetlist2Vhdl copy)
    vhdl_CS_script = Netlist::VhdlCompiler.new 
    # TODO : Only for nominal frequency at first
    vhdl_CS_script.generate_compile_script circ_init, [test_frequencies.first]
    vhdl_CS_script.generate_compile_script circ_test, [test_frequencies.first]

    # TODO : Compile and simulate using the script
    system("./compile_#{circ_init.name}.x")
    system("./compile_#{circ_test.name}.x")

    # TODO : Analyse the VCD for nominal freq
    extractor_init = VCD::Vcd_Signal_Extractor.new
    extractor_test = VCD::Vcd_Signal_Extractor.new
    comparer = VCD::Vcd_Comparer.new

    extractor_init.load_vcd "#{circ_init.name}_#{test_frequencies.first.to_s}_tb.vcd" # init circ traces PATH
    clk_period = extractor_init.get_clock_period
    traces_init = comparer.trace_to_list(extractor_init.extract, clk_period)

    extractor_test.load_vcd  "#{circ_test.name}_#{test_frequencies.first.to_s}_tb.vcd" # test circ traces PATH
    clk_period_test = extractor_test.get_clock_period
    if clk_period != clk_period_test 
        raise "Error : Different clock for the same targeted frequency."
    end
    traces_test = comparer.trace_to_list(extractor_test.extract, clk_period)

    # TODO : Get the cycles index different between the two traces
    cycles_to_delete = comparer.get_diff_cycle_num(traces_init, traces_test)
    
    # TODO : Delete stimulis at those cycles to avoid HT Triggering
    stim_seq = comparer.delete_cycle_list stim_seq, cycles_to_delete
    # pp stim_seq

    results << comparer.compare_lists_detailed(traces_test, traces_init)

    # TODO : Generate testbench for nominal frequency 
    tb_gen = Netlist::GenTestbench.new(circ_init)
    tb_gen.stimuli = stim_seq
    tb_init = tb_gen.gen_testbench :passed, test_frequencies.first

    tb_gen.netlist_data[:entity_name] = circ_test.name
    # tb_gen_test = Netlist::GenTestbench.new(circ_test)
    tb_gen.stimuli = stim_seq
    tb_test = tb_gen.gen_testbench :passed, test_frequencies.first

    # TODO : Write the tb file
    File.write("./#{circ_init.name}_#{test_frequencies.first.to_s}_tb.vhd", tb_init)
    File.write("./#{circ_test.name}_#{test_frequencies.first.to_s}_tb.vhd", tb_test)

    # TODO : Generate the VHD files of the generated circuits
    vhdl_converter.generate circ_test

    # TODO : Generate the compile and simulate script (convNetlist2Vhdl copy)
    vhdl_CS_script = Netlist::VhdlCompiler.new 
    # TODO : Only for nominal frequency at first
    vhdl_CS_script.generate_compile_script circ_init, [test_frequencies.first]
    vhdl_CS_script.generate_compile_script circ_test, [test_frequencies.first]

    # TODO : Compile and simulate using the script
    system("./compile_#{circ_init.name}.x")
    system("./compile_#{circ_test.name}.x")

    # TODO : Analyse the VCD for nominal freq
    extractor_init = VCD::Vcd_Signal_Extractor.new
    extractor_test = VCD::Vcd_Signal_Extractor.new
    comparer = VCD::Vcd_Comparer.new

    extractor_init.load_vcd "#{circ_init.name}_#{test_frequencies.first.to_s}_tb.vcd" # init circ traces PATH
    clk_period = extractor_init.get_clock_period
    traces_init = comparer.trace_to_list(extractor_init.extract, clk_period)

    extractor_test.load_vcd  "#{circ_test.name}_#{test_frequencies.first.to_s}_tb.vcd" # test circ traces PATH
    clk_period_test = extractor_test.get_clock_period
    if clk_period != clk_period_test 
        raise "Error : Different clock for the same targeted frequency."
    end
    traces_test = comparer.trace_to_list(extractor_test.extract, clk_period)
    
    results << comparer.compare_lists_detailed(traces_test, traces_init)

    results.each do |res|
        result_csv << "#{circ_test.name}, #{res}\n"
    end
    File.write('result.csv', result_csv)

    pp cycles_to_delete
end

