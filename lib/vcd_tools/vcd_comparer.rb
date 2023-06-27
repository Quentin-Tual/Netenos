module VCD

    class Vcd_Comparer
        
        def initialize
            @output_traces_a = {}
            @output_traces_b = {}
            @id_tab_a = {}
            @id_tab_b = {}
        end

        def compare 
            differences = {} 

            @output_traces_a.keys.each do |timestamp|
                @output_traces_a[timestamp].keys.collect do |sig|
                    if @output_traces_b[timestamp].nil? or @output_traces_a[timestamp][sig] != @output_traces_b[timestamp][sig]
                        puts "Difference detected in traces."
                        if differences[@id_tab_a[sig]].nil?
                            differences[@id_tab_a[sig]] = 1
                        else
                            differences[@id_tab_a[sig]] += 1
                        end
                    end
                end
            end

            if differences.empty?
                puts "Nothing abnormal detected in traces."
                return "none"
            else 
                return differences
            end
        end

        def compare_lists_detailed list_a, list_b
            differences = {}

            list_a.keys.each do |sig|
                differences[sig] = []
                list_a[sig].length.times do |i|
                    if list_a[sig][i] != list_b[sig][i]
                        differences[sig] << i
                    end
                end
            end

            differences.keys.each do |sig|
                if differences[sig].empty?
                    differences.delete sig
                end
            end

            return differences
        end

        def compare_lists list_a, list_b
            differences = {}
            

            list_a.keys.each do |sig|
                xor_list = []

                # TEST
                # if list_a[sig] != list_b[sig]
                #     pp sig
                # end
                
                list_a[sig].zip list_b[sig] do |a, b|
                    if a != 'U' and b != 'U' 
                        xor_list << (a.to_i ^ b.to_i).to_s(2)
                    # elsif a != b 
                    #     xor_list << "1"
                    # elsif a == b
                    #     xor_list << "0"
                    end
                    
                end
                nb_diff = xor_list.count("1")
                
                if nb_diff > 0
                    differences[sig] = nb_diff
                end
            end

            nb_sig_diff = differences.keys.length
            nb_differences = differences.values.inject(:+)

            if differences.empty?
                # puts "Nothing abnormal detected in traces."
                return "none, none"
            else 
                return "#{nb_sig_diff}, #{nb_differences}"
                # return differences
            end
        end 

        def jaccard_sim list_a, list_b
            
        end

        def hamming_distance a, b
            (a^b).to_s(2).count("1")
        end

        def get_diff_cycle_num trace_a, trace_b
            res = []

            trace_a.keys.each do |sig|
                trace_a[sig].length.times do |i|
                    if trace_a[sig][i] != trace_b[sig][i]
                        res << (i-2) # outputs sampled by a register so the stimuli at previous cycle are responsible of the seen output
                    end
                end
            end
            
            return res
        end

        def delete_cycle_list trace_a, list
            trace_a.keys.each do |sig|
                removed = 0 # Should be 0
                list.sort.each do |i|
                    trace_a[sig].delete_at(i - removed)
                    removed += 1
                end
            end

            return trace_a
        end

        def trace_to_list trace, clk_period
            # * : Return a list of values for each cycle in the trace and for each signal observed (outputs)
            list_trace = {}
            last_timestamp = {}
            timestamp_sorted_list = trace["output_traces"].keys.collect{|timestamp| timestamp.to_i}.sort

            timestamp_sorted_list.each do |timestamp|
                trace["output_traces"][timestamp.to_s].keys.each do |sig|
                    if last_timestamp[sig].nil?
                        last_timestamp[sig] = 0
                    end

                    if timestamp == 0
                        next
                    end
                    
                    nb_cycles = ((timestamp - last_timestamp[sig])/clk_period).floor.to_i   

                    if list_trace[sig].nil?
                        list_trace[sig] = Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig].to_s][sig])
                    else
                        list_trace[sig].concat Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig].to_s][sig])
                    end

                    if trace['output_traces'][last_timestamp[sig].to_s][sig].nil?
                        raise "Error : Corresponding value not found in traces"
                    end

                    last_timestamp[sig] = timestamp
                end
            end 

            # Récupérer le dernier timestamp de toute la 
            trace_end = last_timestamp.values.max
            list_trace.keys.each do |sig|
                nb_cycles = (trace_end - last_timestamp[sig]) / clk_period
                if list_trace[sig].nil?
                    list_trace[sig] = Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig].to_s][sig])
                else
                    list_trace[sig].concat Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig].to_s][sig])
                end
            end

            # Remove the first result cause it is not necessary
            # list_trace.each do |sig|
            #     if !list_trace[sig].nil?
            #         list_trace[sig].delete_at 0
            #     end
            # end

            return list_trace
        end

        def set_traces a, b
            @output_traces_a = a["output_traces"]
            @output_traces_b = b["output_traces"]
            @id_tab_a = a["id_tab"]
            @id_tab_b = b["id_tab"]
        end

        def load_traces path_a, path_b
            
            a = Marshal.load(IO.read(path_a))
            b = Marshal.load(IO.read(path_b))

            @output_traces_a = a["output_traces"]
            @output_traces_b = b["output_traces"]
            @id_tab_a = a["id_tab"]
            @id_tab_b = b["id_tab"]
        end

        # def aggreg_traces *traces_path
        #     # * : Return one trace formed with the multiples traces passed as args. 
        #     extractor = VCD::Vcd_Signal_Extractor
        #     traces = []
        #     res = {}
        #     clk_period = extractor.get_clock_period
        #     traces_path.each do |path|
        #         extractor.load_vcd path
        #         traces << trace_to_list(extractor.extract, clk_period)
        #     end

        #     [0..traces[0][traces.keys[0]].length] do |j|
        #         [0..traces.length] do |i|
        #             traces[i].each do |sig|
        #                 traces[i][sig][j] xor # ??? xor cumulé sur toutes les traces à cet instant
        #             end
        #         end
        #     end

            # ! Semble complexe
            # traces[0].keys.each do |sig|
            #     # TODO : xor chaque valeur de chaque trace
            #     tmp = nil
            #     res[sig] = traces.select{|t| t[sig]}
            #     res[sig] = res.transpose.inject(:xor)

            # end
            
        # end
    end

end