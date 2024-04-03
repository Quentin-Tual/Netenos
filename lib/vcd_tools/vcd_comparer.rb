require 'matrix'

module VCD

    class Vcd_Comparer
        
        def initialize
            @output_traces_a = {}
            @output_traces_b = {}
            @id_tab_a = {}
            @id_tab_b = {}
        end

        # def compare_comparative_tb_traces trace, monitored_signals, clk_period
        #     # * Initialization of cycle_diff
        #     cycle_diff = monitored_signals.each_with_object({}) {|sig, h| h[sig] = []}

        #     # * Filling cycle_diff, associating each sig to all timestamps when diff signal is raised (all timestamps of an anomaly)
        #     monitored_signals.each do |sig|
        #         trace.keys.each do |t|
        #             if trace[t][sig] == '1'
        #                 cycle_diff[sig] << (t / (clk_period)).to_i
        #             end
        #         end
        #     end

        #     cycle_diff.delete_if{|sig,list| list.empty?}

        #     return cycle_diff
        # end

        # ! obs_clk synchronous analysis 
        def compare_comparative_tb_traces trace, monitored_signals,nom_clk_period, obs_clk_period 
            # * Initialization of cycle_diff
            cycle_diff = monitored_signals.each_with_object({}) {|sig, h| h[sig] = []}

            sig_curr_state = monitored_signals.each_with_object(Hash.new()){|sig, h| h[sig] = 'U'}

            # * Filling cycle_diff, associating each sig to all timestamps when diff signal is raised (all timestamps of an anomaly)

            last_obs_cycle = 0
            trace.each do |t, sig_transition|
                obs_cycle = (t / obs_clk_period).to_i
                nom_cycle = (t / nom_clk_period).to_i
                
                # sig_transition.each do |sig, arrival_state| #! DEBUG should fix synchronous mode, make it improper for asynchronous mode
                #     sig_curr_state[sig] = arrival_state
                # end

                # Si modification de cycle obs 
                if last_obs_cycle != obs_cycle
                    # Pour chaque signaux 
                    sig_transition.each do |sig, state|
                        # Si l'état du signal est à un
                        if state == '1'
                            # push du cycle nominal courant à cycle_diff
                            cycle_diff[sig] << nom_cycle
                        elsif state == '0' # * Assuming transition is '1'->'0' 
                            unless cycle_diff[sig].empty? # * handling transitions 'U'->'0'
                                (cycle_diff[sig].last+1 ... nom_cycle).each{|cycle| cycle_diff[sig] << cycle}
                            end
                            # cycle_diff[sig] << nom_cycle
                        end
                        # Fin Si
                    # Fin Pour
                    end
                # Fin Si
                end

                last_obs_cycle = obs_cycle
            end

            # monitored_signals.each do |sig|
            #     trace.keys.each do |t|
            #         if trace[t][sig] == '1'
            #             cycle_diff[sig] << (t / (obs_clk_period)).to_i
            #         end
            #     end
            # end

            cycle_diff.delete_if{|sig,list| list.empty?}

            return cycle_diff
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
                
                list_a[sig].zip list_b[sig] do |a, b|
                    if a != 'U' and b != 'U' 
                        xor_list << (a.to_i ^ b.to_i).to_s(2)
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
                return "none, none"
            else 
                return "#{nb_sig_diff}, #{nb_differences}"
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

        def intercorrelation a, b, max_tau = a.keys.length
            corr_by_sig = {}

            max_tau.times do |tau|
                corr_by_sig[tau] = {}
                a.keys.length.times do |sig_index|
                    sig = a.keys[sig_index]
                    a.values.first.length.times do |i|
                        val_a = a[sig][i] 

                        val_b = b[sig][i - tau]
                        # * : Initialization 
                        if corr_by_sig[tau][sig].nil?
                            corr_by_sig[tau][sig] = 0
                        end
                        
                        if val_b.nil?   # * : Unbiased thanks to this 
                            next        # * : A nil value (or inexistant for example cause non-cyclic correlation here)  won't affect the final correlation score 
                        elsif val_a == val_b
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
                    # * : No absolute value here to avoid false negative with a inverting payload activated
                    acc += corr_by_sig[tau][sig]
                    nb_val += 1
                # * : Compute variance of these cross correlations (for every signals) with a fixed 'tau' value 
                # * : Compute the "inverted" dispersion (density ?) of these values (mean/variance) and associate it to corresponding 'tau' value in a hash structure.
                end
                if nb_val == 0
                    raise "Division by 0 !"
                end 

                mean[tau] = acc.to_f / nb_val
               

                # Calcul de la variance
                acc = 0
                nb_val = 0
                corr_by_sig[tau].keys.each do |sig|
                    # * : Compute the mean cross correlation of signals for a fixed 'tau' value
                        acc += (corr_by_sig[tau][sig] - mean[tau])**2
                        nb_val += 1
                    # * : Compute variance of these correlations (for every signals) with a fixed 'tau'    
                end
                variance[tau] = acc.to_f / nb_val
            end

            # * : Compute dispersion of these values (variance/mean) and associate it to corresponding 'tau' value in a hash structure.
            disp_index = {}
            mean.keys.each do |tau|
                if mean[tau] == 0.0 and variance[tau] == 0.0
                    disp_index[tau] = 0.0
                else
                    disp_index[tau] = variance[tau] / mean[tau]
                end
            end

            # * : Selected best 'tau' value is the one which has the closest to 0 variance/mean
            begin
                best_tau = closest(disp_index, 0).last
            rescue => exception
                raise "Error: 'disp_index' values comparison impossible\n -> #{disp_index}"
            end

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

            if $VERBOSE
                warn "#{__FILE__}:#{__LINE__} : Warning : Make sure test trace is the first parameter in front of the reference trace."
            end

            trace_a.keys.each do |sig|
                trace_a[sig].each_with_index do |val,i|
                    if trace_a[sig][i] != trace_b[sig][i] #and i > 0
                        res << i-1  #/ trace_a.length.to_f # outputs sampled by a register so the stimuli at previous cycle are responsible of the seen output
                    end
                end
            end
            
            return res.uniq
        end

        def compare_traces_async trace, monitored_signals, nom_clk_period, obs_clk_period
            # * Initialization of cycle_diff
            cycle_diff = monitored_signals.each_with_object({}) {|sig, h| h[sig] = []}
        
            sig_curr_state = monitored_signals.each_with_object(Hash.new()){|sig, h| h[sig] = 'U'}
        
            # * Filling cycle_diff, associating each sig to all timestamps when diff signal is raised (all timestamps of an anomaly)
        
            last_obs_cycle = 0
            trace.each do |t, sig_transition|
                obs_cycle = (t / obs_clk_period).to_i
                nom_cycle = (t / nom_clk_period).to_i
                
                sig_transition.each do |sig, state|
                
                # Si modification de cycle obs 
                # if last_obs_cycle != obs_cycle
                    # Pour chaque signaux 
                    
                        # Si l'état du signal est à un
                        if state == '1'
                            # push du cycle nominal courant à cycle_diff
                            cycle_diff[sig] << nom_cycle
                            # next
                        # elsif state == '0' # * Assuming transition is '1'->'0' 
                        #     unless cycle_diff[sig].empty? # * handling transitions 'U'->'0'
                        #         (cycle_diff[sig].last+1 ... nom_cycle).each{|cycle| cycle_diff[sig] << cycle}
                        #     end
                            # next
                            # cycle_diff[sig] << nom_cycle
                        end
                        # Fin Si
                    # Fin Pour
                end
                # Fin Si
                # 
        
                last_obs_cycle = obs_cycle
            end
    
            return cycle_diff
        end

        def get_anomaly_details vcd_path, monitored_signals

            vcd_extractor = VCD::Vcd_Signal_Extractor.new
            comparator = VCD::Vcd_Comparer.new
            # puts "> Chargement trace"    
            nom_clk = vcd_extractor.get_clock_period vcd_path, "nom_clk"
            obs_clk = vcd_extractor.get_clock_period vcd_path, "obs_clk"
            last_timestamp = vcd_extractor.get_last_timestamp vcd_path
            trace = vcd_extractor.extract(vcd_path, :ghdl, monitored_signals)["output_traces"]
            nb_nom_cycle = (`wc obj/stim.txt`.split(' ')[0].to_i) -1
        
            # * Initializations
            anomaly_details = monitored_signals.each_with_object({}) {|sig, h| h[sig] = {}}
            anomaly_duration_counter = monitored_signals.each_with_object({}) {|sig, h| h[sig] = 0}
            anomaly_amount = monitored_signals.each_with_object({}) {|sig, h| h[sig] = 0}
            # sig_curr_state = monitored_signals.each_with_object(Hash.new()){|sig, h| h[sig] = 'U'} # associate a signal to a value, timestamp pair
            last_rising_timestamp =  monitored_signals.each_with_object({}) {|sig, h| h[sig] = nil}
        
            # * Filling anomaly_duration_counter, associating each sig to all timestamps when diff signal is raised (all timestamps of an anomaly)
            last_nom_cycle = 0
            trace.each do |t, sig_transition|
                obs_cycle = (t / obs_clk).to_i
                nom_cycle = (t / nom_clk).to_i
                
                # sig_transition.each do |sig, arrival_state|
                    # sig_curr_state[sig] = arrival_state
                
        
                    # Si modification de cycle obs 
                    if last_nom_cycle != nom_cycle 
                        # Pour chaque signaux 
                        # sig_curr_state.each do |sig, state|
                        monitored_signals.each do |sig|
                            # Si l'état du signal est à un
                            # if arrival_state == '1' #?optionnal (a 1->0 transition is never first to occur un a cycle, no triggering thus detection at nominal frequency)
                                # push du cycle nominal courant à cycle_diff
                                anomaly_details[sig][last_nom_cycle] = {:amount => anomaly_amount[sig], :duration => anomaly_duration_counter[sig]}
                                anomaly_duration_counter[sig] = 0
                                anomaly_amount[sig] = 0
        
                                last_rising_timestamp[sig] = t
                                # cycle_diff[sig] << nom_cycle
                            # end
                            # Fin Si
                        # Fin Pour
                        end
                    # Fin Si
                    else 
                        # sig_curr_state.each do |sig, state|
                        sig_transition.each do |sig, arrival_state|
                            if arrival_state == '0'
                                anomaly_duration_counter[sig] += t.to_i - last_rising_timestamp[sig].to_i
                                anomaly_amount[sig] += 1
                                # unless cycle_diff[sig].empty? # * If transition is 'U'->'0'
                                #     (cycle_diff[sig].last+1 ... nom_cycle).each{|cycle| cycle_diff[sig] << cycle}
                                # end
                                # cycle_diff[sig] << nom_cycle
                            elsif arrival_state == '1'
                                last_rising_timestamp[sig] = t
                            end
                        end 
                    end
        
                # end
        
                last_nom_cycle = nom_cycle
            end
        
            return anomaly_details
        end
        
        def get_mean_anomaly_duration anomaly_details, nb_cycle
            anomaly_details.each_with_object(Hash.new) do |(sig, cycle_diff), mean_anomaly_duration|
                duration_list = cycle_diff.values.collect{|h| h[:duration]}
                mean_anomaly_duration[sig] = (duration_list.sum / nb_cycle.to_f).round(3)
            end
        end
        
        def normalize_anomaly_durations mean_duration, crit_path_duration
            mean_duration.each_with_object(Hash.new) do |(sig, duration), norm_mean_duration|
                norm_mean_duration[sig] = (duration / (crit_path_duration*1_000)).round(3)
            end
        end
        
        def get_mean_anomaly_amount anomaly_details, nb_cycle
            anomaly_details.each_with_object(Hash.new) do |(sig, cycle_diff), mean_anomaly_amount|
                amount_list = cycle_diff.values.collect{|h| h[:amount]}
                mean_anomaly_amount[sig] = (amount_list.sum.to_f / nb_cycle).round(3)
            end
        end

        def delete_cycle_list vec_trace, list
            ret_trace = {}

            vec_trace.keys.each_with_index do |sig, i|
                ret_trace[sig] = ""

                vec_trace[sig].chars.each_with_index do |val, j|
                    if !list.include? j
                        ret_trace[sig] << val
                    end
                end
            end

            return ret_trace
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

        def trace_to_list trace, clk_period, trace_end
            # * : Return a list of values for each cycle in the trace and for each signal observed (outputs)
            list_trace = {}
            last_timestamp = {}
            timestamp_sorted_list = trace["output_traces"].keys.sort

            # * Iterate over event list
            timestamp_sorted_list.each do |timestamp|
                # * Iterate over different primary outputs
                trace["output_traces"][timestamp].keys.each do |sig|
                    # * First event on this output
                    if sig.nil? 
                        raise "Error : Nil signal name encountered"
                    end

                    if (timestamp % clk_period) != 0
                        if !$VERBOSE.nil?
                            warn "#{__FILE__}:#{__LINE__} : Warning : Asynchronous transition detected, ensure it is expected \n -> timestamp = #{timestamp}; clk_period = #{clk_period}; modulo : #{timestamp % clk_period}; signal : #{sig}"
                        end
                    end

                    # * Initial state then nothing to do
                    if timestamp == 0
                        last_timestamp[sig] = timestamp
                        next
                    end
                    
                    # * Compute the number of cycles the value last on primary output 
                    nb_cycles = ((timestamp - last_timestamp[sig])/clk_period.to_f).ceil

                    # * : If first values then store in a new array
                    if list_trace[sig].nil?
                        list_trace[sig] = Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig]][sig])
                    else # * : Else store in the array already created
                        list_trace[sig].concat Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig]][sig])
                    end

                    # * : Value verification
                    if trace['output_traces'][last_timestamp[sig]][sig].nil?
                        raise "Error : Corresponding value not found in traces"
                    end

                    # * : Go to next event
                    last_timestamp[sig] = timestamp
                end
            end 

            # Get the last timestamp in the trace
            list_trace.keys.each do |sig|
                if sig.nil?
                    raise "Error : Nil signal name encountered"
                end

                nb_cycles = ((trace_end - last_timestamp[sig]) / clk_period.to_f).ceil

                if list_trace[sig].nil?
                    list_trace[sig] = Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig]][sig])
                else
                    list_trace[sig].concat Array.new(nb_cycles, trace['output_traces'][last_timestamp[sig]][sig])
                end
            end

            if list_trace.keys.include? nil
                raise "Error : Nil signal name encountered"
            end

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