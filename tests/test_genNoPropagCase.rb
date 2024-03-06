require '../lib/netenos.rb'


require_relative '../lib/netenos.rb'
# require_relative '../lib/converter/convNetlist2Vhdl.rb'

FREQ = 20

# TODO : Replace these variables by arguments passed
path = "./tmp"

test_frequencies = [FREQ]
nb_trig = 2
nb_netlist = 1
result_csv = "name, freq, nb_sig_diff, nb_diff\n"
nb_sim_cycle = 20
keep_curr_circ = false

margin = 0
margin_first_sim = margin
margin_second_sim = margin

continue = true

while continue
    results = []
    # * : Create a directory for the experience at the specified path 
    Dir.mkdir(path) unless File.exists?(path)
    Dir.chdir(path) do

        if keep_curr_circ
            circ_init = Marshal.load(IO.read("rand_tmp.enl"))
            circ_init.name = "rand_tmp"
            circ_test = Marshal.load(IO.read("rand_tmp_altered.enl"))
            circ_test.name = "rand_tmp_altered"

            # * : (optionnal) Generate a .dot file
            viewer = Converter::DotGen.new
            viewer.dot(circ_init, nil, :int_multi)
            viewer.dot(circ_test, nil, :int_multi)

            vhdl_converter = Converter::ConvNetlist2Vhdl.new
            stim_generator = Converter::GenStim.new(circ_init)
            # tb_gen = Converter::GenTestbench.new(circ_test)
            vhdl_CS_script = Converter::VhdlCompiler.new 

            # * Correct code !
            # * : Generate testbench for nominal frequency 
            tb_gen = Converter::GenTestbench.new(circ_test, margin_first_sim)
            # tb_gen.stimuli = stim_seq
            tb_test = tb_gen.gen_testbench "stim.txt", test_frequencies.first, circ_test.name

            tb_gen.netlist_data[:entity_name] = circ_init.name
            # tb_gen_test = Netlist::GenTestbench.new(circ_test)
            # tb_gen.stimuli = stim_seq
            tb_init = tb_gen.gen_testbench "stim.txt", test_frequencies.first, circ_init.name

            # # ! Error generating, just to reproduce an unwanted behavior
            # # * : Generate testbench for nominal frequency 
            # tb_gen = Converter::GenTestbench.new(circ_init)
            # # tb_gen.stimuli = stim_seq
            # tb_init = tb_gen.gen_testbench "stim.txt", test_frequencies.first, circ_init.name

            # tb_gen.netlist_data[:entity_name] = circ_test.name
            # # tb_gen_test = Netlist::GenTestbench.new(circ_test)
            # # tb_gen.stimuli = stim_seq
            # tb_test = tb_gen.gen_testbench "stim.txt", test_frequencies.first, circ_test.name

            if !File.exists? "stim.txt" 
                stim_generator = Converter::GenStim.new(circ_init)
                stim_seq = stim_generator.gen_exhaustive_trans_stim#, trig_cond)
                stim_generator.save_as_txt "stim.txt"
            end

            # * : Compile and simulate using the script
            system("./compile.sh")
        else
            # * : Generate GTECH  
            vhdl_converter = Converter::ConvNetlist2Vhdl.new
            vhdl_converter.gen_gtech

            # * : Generate a netlist
            netlistGenerator = Netlist::RandomGenComb.new(4, 1, 2)
            circ_init = netlistGenerator.getRandomNetlist("rand_tmp")

            # * : Generate the VHD files of the generated circuits
            vhdl_converter.generate circ_init

            # * : (optionnal) Generate a .dot file
            viewer = Converter::DotGen.new
            viewer.dot circ_init, nil, :int_multi

            # * : Generate a second netlist, half chance to be an altered version of the first, else it is the same one 
            # * : Alter it or just copy it
            if [1].sample == 1  # ! TEST add a 0 in the list, removed for tests
                # * : alter it
                suffix = "altered"
                inserter = Inserter::Tamperer.new(circ_init.clone, netlistGenerator.grid)
                # inserter.select_ht("og_s38417", nb_trig)
                inserter.select_ht("xor_and", nb_trig)
                circ_test = inserter.insert("random")
                # trig_cond =  inserter.get_trigger_conditions
                # pp trig_cond # TEST
                circ_test.name = "#{circ_test.name}_#{suffix}" 
            else 
                # * : only copy, modify the name without modifying the circ_init one !
                suffix = "copied"
                circ_test = circ_init.clone 
                circ_test.name = "#{circ_test.name}_#{suffix}" 
            end

            circ_init.getNetlistInformations :int_multi 
            circ_test.getNetlistInformations :int_multi

            # * : (optionnal) Generate a .dot file
            viewer.dot circ_test, nil, :int_multi

            stim_generator = Converter::GenStim.new(circ_init)
            stim_seq = stim_generator.gen_exhaustive_trans_stim#, trig_cond)
            stim_generator.save_as_txt "stim.txt"
            
            # * : Generate testbench for nominal frequency 
            tb_gen = Converter::GenTestbench.new(circ_test, margin_first_sim)
            tb_gen.stimuli = stim_seq
            tb_test = tb_gen.gen_testbench "stim.txt", test_frequencies.first, circ_test.name

            tb_gen.netlist_data[:entity_name] = circ_init.name
            # tb_gen_test = Netlist::GenTestbench.new(circ_test)
            tb_gen.stimuli = stim_seq
            tb_init = tb_gen.gen_testbench "stim.txt", test_frequencies.first, circ_init.name

            # * : Generate the VHD files of the generated circuits
            vhdl_converter.generate circ_test

            # * : Generate the compile and simulate script (convNetlist2Vhdl copy)
            vhdl_CS_script = Converter::VhdlCompiler.new 
            vhdl_CS_script.gtech_makefile ".", :ghdl
            `make`
            # * : Only for nominal frequency at first
            vhdl_CS_script.circ_compile_script ".", circ_init.name, [test_frequencies.first]
            vhdl_CS_script.circ_compile_script ".", circ_test.name, [test_frequencies.first], [:ghdl, :minimal_sig], true

            # * : Compile and simulate using the script
            system("./compile.sh")
            # system("./compile_#{circ_test.name}.x")

            circ_init.save_as "./"
            circ_test.save_as "./"
        end

        # * : Analyse the VCD for nominal freq
        extractor_init = VCD::Vcd_Signal_Extractor.new
        extractor_test = VCD::Vcd_Signal_Extractor.new
        comparer = VCD::Vcd_Comparer.new

        extractor_init.load_vcd "#{circ_init.name}_#{test_frequencies.first.to_s}_tb.vcd" # init circ traces PATH
        clk_period = extractor_init.get_clock_period
        last_timestamp_init = extractor_init.get_last_timestamp
        tmp_init = extractor_init.extract(:ghdl)
        traces_init = comparer.trace_to_list(tmp_init, clk_period, last_timestamp_init)

        extractor_test.load_vcd  "#{circ_test.name}_#{test_frequencies.first.to_s}_tb.vcd" # test circ traces PATH
        clk_period_test = extractor_test.get_clock_period
        last_timestamp_test = extractor_test.get_last_timestamp
        if clk_period != clk_period_test 
            raise "Error : Different clock for the same targeted frequency."
        end
        tmp_test = extractor_test.extract(:ghdl)
        traces_test = comparer.trace_to_list( tmp_test, clk_period_test, last_timestamp_test)

        results << comparer.compare_lists_detailed(traces_test, traces_init)

        # * : Get the cycles index different between the two traces
        cycles_to_delete = comparer.get_diff_cycle_num(traces_test, traces_init)

        # # * : Delete stimulis at those cycles to avoid HT Triggering
        # stim_seq = stim_generator.convert_vec_list_2_stim(stim_generator.load_txt("stim.txt"))

        # stim_seq = comparer.delete_cycle_list(stim_seq, cycles_to_delete)

        # stim_seq = stim_generator.conv_stim_2_vec_list(stim_seq)

        # # # * : Extend the exhaustive stimulus with exhaustive transitions
        
        # test_vec = stim_generator.extend_exhaustive_all_trans(stim_seq)

        # stim_generator.save_vec_list("stim_extended.txt", test_vec)

        # # stim_generator.convert_vec_list_2_stim(stim_seq)
        # # stim_generator.stim = stim_seq
        # # stim_generator.save_as_txt("stim.txt")

        # # * : Generate testbench for nominal frequency 
        # tb_gen = Converter::GenTestbench.new(circ_test, margin_second_sim)
        # tb_gen.stimuli = stim_seq
        # tb_test = tb_gen.gen_testbench "stim_extended.txt", test_frequencies.first

        # tb_gen.netlist_data[:entity_name] = circ_init.name
        # # tb_gen_test = Netlist::GenTestbench.new(circ_test)
        # tb_gen.stimuli = stim_seq
        # tb_init = tb_gen.gen_testbench "stim_extended.txt", test_frequencies.first

        # # * : Write the tb file
        # File.write("./#{circ_init.name}_#{test_frequencies.first.to_s.split('.').join}_tb.vhd", tb_init)
        # File.write("./#{circ_test.name}_#{test_frequencies.first.to_s.split('.').join}_tb.vhd", tb_test)


        # # * : Generate the compile and simulate script (convNetlist2Vhdl copy)
        # vhdl_CS_script = Converter::VhdlCompiler.new 

        # vhdl_CS_script.circ_compile_script ".", circ_init.name, [test_frequencies.first]
        # vhdl_CS_script.circ_compile_script ".", circ_test.name, [test_frequencies.first], [:ghdl, :minimal_sig], true

        # # * : Compile and simulate using the script
        # `./compile.sh`

        # # * : Analyse the VCD for nominal freq
        # extractor_init = VCD::Vcd_Signal_Extractor.new
        # extractor_test = VCD::Vcd_Signal_Extractor.new
        # comparer = VCD::Vcd_Comparer.new

        # extractor_init.load_vcd "#{circ_init.name}_#{test_frequencies.first.to_s}_tb.vcd" # init circ traces PATH
        # clk_period = extractor_init.get_clock_period
        # last_timestamp_init = extractor_init.get_last_timestamp
        # traces_init = comparer.trace_to_list(extractor_init.extract(:ghdl), clk_period,  last_timestamp_init)

        # extractor_test.load_vcd  "#{circ_test.name}_#{test_frequencies.first.to_s}_tb.vcd" # test circ traces PATH
        # clk_period_test = extractor_test.get_clock_period
        # last_timestamp_test = extractor_test.get_last_timestamp
        # if clk_period != clk_period_test 
        #     raise "Error : Different clock for the same targeted frequency."
        # end
        # traces_test = comparer.trace_to_list(extractor_test.extract(:ghdl), clk_period, last_timestamp_test)
        
        # results << comparer.compare_lists_detailed(traces_test, traces_init)

        # results.each do |res|
        #     result_csv << "#{circ_test.name}, #{res}\n"
        # end

        if results[0].empty?
            continue = false
        end

        # File.write('result.csv', result_csv)

        # pp cycles_to_delete
        pp cycles_to_delete.size
    end

    # continue = false
end

