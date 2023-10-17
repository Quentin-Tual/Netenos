require 'matrix'

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

        def jaccard_similarity list_a, list_b
            simi_by_sig = {}

            list_a.keys.each do |sig|
                m = [0,0]
                n = list_a[sig].length

                list_a[sig].zip list_b[sig] do |ea, eb|
                    if ea == "1" and eb == "1"
                        m[1] += 1
                    elsif ea == "0" and eb == "0"
                        m[0] += 1
                    end
                end

                simi_by_sig[sig] = ((m[1].to_f) / (n-m[0])).round(3)
            end

            return (simi_by_sig.values.sum / simi_by_sig.values.size).round(3)
        end

        def modified_jaccard list_a, list_b
            simi_by_sig = {}

            list_a.keys.each do |sig|
                m = [0,0]
                mU = 0
                n = list_b[sig].length

                list_a[sig].zip list_b[sig] do |ea, eb|
                    if ea == "1" and eb == "1"
                        m[1] += 1
                    elsif ea == "0" and eb == "0"
                        m[0] += 1
                    elsif ea == "U" and eb == "U"
                        mU += 1
                    end
                end

                simi_by_sig[sig] = ((m[1].to_f + m[0].to_f + mU.to_f) / (n)).round(3)
            end

            return (simi_by_sig.values.sum / simi_by_sig.values.size).round(3)
        end

        def tanimoto_coefficient list_a, list_b
            simi_by_sig = {}
            
            list_a.keys.each do |sig|
                scal_prod = 0

                norm_a = list_a.length
                norm_b = list_b.length

                list_a[sig].zip list_b[sig] do |ea,eb|
                    if ea == "U" or eb == "U"
                        norm_a = norm_a - 1
                        norm_b = norm_b - 1
                    else
                        scal_prod += ea.to_i * eb.to_i 
                    end
                end

                simi_by_sig[sig] = scal_prod.to_f / (norm_a**2 + norm_b**2 - scal_prod)
                # pp simi_by_sig[sig]
            end

            return (simi_by_sig.values.sum / simi_by_sig.values.size).round(3)
        end

        def levenshtein_distance(s, t)
            dist_by_sig = {}

            s.keys.each do |sig|
                m = s[sig].length
                n = t[sig].length
                return m if n == 0
                return n if m == 0
                d = Array.new(m+1) {Array.new(n+1)}
        
                (0..m).each {|i| d[i][0] = i}
                (0..n).each {|j| d[0][j] = j}
                (1..n).each do |j|
                    (1..m).each do |i|
                        d[i][j] = if s[sig][i-1] == t[sig][j-1] # adjust index into string
                                    d[i-1][j-1]       # no operation required
                                else
                                    [ d[i-1][j]+1,    # deletion
                                    d[i][j-1]+1,    # insertion
                                    d[i-1][j-1]+1,  # substitution
                                    ].min
                                end
                    end
                end
                dist_by_sig[sig] = d[m][n].to_f
            end

            return (dist_by_sig.values.sum / dist_by_sig.values.size).round(3)
        end

        def hamming_distance a, b
            (a^b).to_s(2).count("1")
        end

        def intercorrelation a, b
            corr_by_sig = {}

            a.values.first.length.times do |tau|
                corr_by_sig[tau] = {}
                a.keys.length.times do |sig_index|
                    sig = a.keys[sig_index]
                    a.values.first.length.times do |i|
                        val_a = a[sig][i] 
                        # if val_a == "0"
                        #     val_a = -1
                        # else
                        #     val_a = 1
                        # end

                        val_b = b[sig][i - tau]
                        # if val_b == "0"
                        #     val_b = -1
                        # else
                        #     val_b = 1
                        # end

                        # corr_by_sig[sig][tau] += val_a * val_b

                        if corr_by_sig[tau][sig].nil?
                            corr_by_sig[tau][sig] = 0
                        end
                        
                        if val_a == val_b
                            corr_by_sig[tau][sig] += 1
                        else
                            corr_by_sig[tau][sig] += -1
                        end
                    end
                end
            end


            # * : Get the 'tau' value with most of the signals are similar 
            mean = {}
            variance = {}
            
            corr_by_sig.keys.each do |tau|
                acc = 0
                nb_val = 0

                # Calcul de la moyenne
                corr_by_sig[tau].keys.each do |sig|
                # * : Compute the mean cross correlation of signals for a fixes 'tau' value 
                    acc += corr_by_sig[tau][sig] 
                    nb_val += 1
                # * : Compute variance of these cross correlations (for every signals) with a fixed 'tau' value 
                # * : Compute the "inverted" dispersion (density ?) of these values (mean/variance)  and associate it to corresponding 'tau' value in a hash structure.
                end
                mean[tau] = acc / nb_val

                # Calcul de la variance
                acc = 0
                nb_val = 0
                corr_by_sig[tau].keys.each do |sig|
                    # * : Compute the mean cross correlation of signals for a fixed 'tau' value  
                        acc += (corr_by_sig[tau][sig] - mean[tau])**2
                        nb_val += 1
                    # * : Compute variance of these correlations (for every signals) with a fixed 'tau'
                    # * : Compute the inverted dispersion (density ?) of these values (mean/variance)  and associate it to corresponding 'tau' value in a hash structure.
                end
                variance[tau] = acc.to_f / nb_val
            end

            disp_index = {}
            mean.keys.each do |tau|
                disp_index[tau] = variance[tau] / mean[tau]
            end

            # * : Selected best 'tau' value is the one which has the highest disp_index  
            # ! : comparison of Float wit NaN sometimes, Infinity values appears, check for another measurement instead of dispersion index (problem to have mean over variance is wide spreading values, sometimes really high ones)
            best_tau = closest(disp_index, 0).last
            # best_tau = disp_index.key(disp_index.values.min)

            # * Return a correlation score, here it is the mean of cross_correlation of each signal 
            corr_score = 0
            corr_by_sig[best_tau].keys.each do |sig|
                corr_score += corr_by_sig[best_tau][sig]
            end
            corr_score = ((corr_score / corr_by_sig[best_tau].keys.length) / a.values.first.length.to_f).floor(4)

            return corr_score
        end 

        def closest h, target
            # * : Return the minimum value with the index associated
            dist = []
            h.values.each do |e|
                dist << (e - target).abs    
            end
            min_dist_index = dist.each_with_index.min.last
            return h.values[min_dist_index], h.keys[min_dist_index]
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

        def replace_cycle_list trace_a, list
            trace_a.keys.each do |sig|
                list.sort.each do |i|
                    if trace_a[sig][i] == "0"
                        trace_a[sig][i] = "1"
                    elsif trace_a[sig][i] == "1"  
                        trace_a[sig][i] = "0"
                    end
                end
            end

            return trace_a
        end

        def trace_to_list trace, clk_period, freq_mult
            # * : Return a list of values for each cycle in the trace and for each signal observed (outputs)
            list_trace = {}
            last_timestamp = {}
            timestamp_sorted_list = trace["output_traces"].keys.collect{|timestamp| timestamp.to_i}.sort

            # * Iterate over event list
            timestamp_sorted_list.each do |timestamp|
                # * Iterate over different primary outputs
                trace["output_traces"][timestamp.to_s].keys.each do |sig|
                    # * First event on this output
                    # if last_timestamp[sig].nil?
                    #     last_timestamp[sig] = 0
                    # end

                    # * Initial state then nothing to do
                    if timestamp == 0
                        last_timestamp[sig] = timestamp
                        next
                    end
                    
                    # * Compute the number of cycles the value last on primary output 
                    nb_cycles = ((timestamp - last_timestamp[sig])/clk_period).floor.to_i

                    # * : If first values then store in a new array
                    if list_trace[sig].nil?
                        list_trace[sig] = Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig].to_s][sig])
                    else # * : Else store in the array already created
                        list_trace[sig].concat Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig].to_s][sig])
                    end

                    # * : Value verification
                    if trace['output_traces'][last_timestamp[sig].to_s][sig].nil?
                        raise "Error : Corresponding value not found in traces"
                    end

                    # * : Go to next event
                    last_timestamp[sig] = timestamp
                end
            end 

            # Récupérer le dernier timestamp de toute la trace
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

    end

end