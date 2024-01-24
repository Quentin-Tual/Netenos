module VCD

    class Vcd_Signal_Extractor

        def initialize
            @output_traces = {}
            @id_tab = {}
            @vcd = nil
            @current_timestamp = nil
        end

        def load_vcd path
            @vcd = IO.read(path).split("\n")
        end

        # * : Start the extraction, kind of the FSM controler
        def extract compiler, signals = :outputs_only
            if @vcd.nil?
                raise "Error : A VCD file must be loaded with 'load_vcd()' first."
            end

            traces_definition compiler, signals
            selected_traces_extraction
            return {    "output_traces" => @output_traces, 
                        "id_tab" => @id_tab }
        end

        # * : Defines traces to follow and their identifier in the vcd file (header data extraction)
        def traces_definition compiler, opt=:outputs_only
            @vcd.shift(8)
            tmp = next_output
            data_type = (compiler == :nvc) ? "logic" : "reg";

            if opt.is_a? Array # * 'opt' is a list of signals to monitor
                until tmp == "$enddefinitions $end" 
                    if opt.include? tmp.split(" ")[4] 
                        tmp = tmp.split
                        @id_tab[tmp[3]] = tmp[4] # * : The original signal name (tmp[4]) is associated to VCD ID (tmp[3]).
                    end
                    tmp = next_output
                end
            elsif opt == :outputs_only
                until tmp == "$enddefinitions $end" 
                    if tmp.match?(/\$var #{data_type} [0-9]+ .+ tb_o[0-9]+_s .+/) # ! : Not really optimized, certainly could be improved
                        tmp = tmp.split
                        @id_tab[tmp[3]] = tmp[4] # * : The original signal name (tmp[4]) is associated to VCD ID (tmp[3]).
                    end
                    tmp = next_output
                end
            else # :all_sig for example
                raise "Error : Functionnality not available yet ! WIP"
            end

        end

        def selected_traces_extraction
            @output_traces = {}
            # * Only keeps the output signals
            tmp = next_output # init

            until tmp.nil?
                if tmp[0] == '#' # * : new timestamp detected, update it
                    update_timestamp tmp.delete_prefix("#")
                # * : Unexpected syntax are covered by the raise in the next conditionnal branchement
                else
                    value = tmp[0]
                    id = tmp[1..]
                    if !@id_tab[id].nil?
                        id = id[0..-1]
                        @output_traces[@current_timestamp][@id_tab[id]] = value
                    end
                end

                tmp = next_output
            end

            @output_traces.each{|key,val| if val.empty? then @output_traces.delete(key) end}
        end

        def get_last_timestamp
            @vcd.reverse_each do |line|
                if line[0] == '#'
                    return line.delete_prefix('#').to_i
                end 
            end

            raise "Error: clock not found"
        end

        def get_clock_period clk_name="obs_clk"
            # * : Returns the clock period for the given vcd file (by default the OBSERVATION clock named 'obs_clk')
            id = nil
            @vcd.each do |line|
                if line.split.include? clk_name
                    id = line.split[3]
                    break
                else
                    next
                end
            end

            bounds = []

            events_line = 0
            @vcd.each do |line|
                if line.include? "$enddefinitions $end"
                    break
                else
                    events_line += 1
                    next
                end
            end

            last_timestamp = 0

            # * Reuse the line splitted version of the file
            @vcd[events_line..-1].each do |line|
                if bounds.length == 2
                    # * Compute the clk period as 2x the second timestamp value
                    return bounds[1]*2
                elsif line[0]=='#'
                    # * Memorize the last encountered timestamp (0 as the first) 
                    # * When found memorize the timestamp 
                    last_timestamp = line.delete_prefix("#")
                elsif line.include?(id) and (line.length < 3) # We know the clock is always in the first symbol attribution so its ID is only one symbol long 
                    # * Check if the ID has an event in this timestamp until it is another timestamp, then update the last uncountered timestamp
                    bounds << last_timestamp.to_i
                # * When 2 timestamp are found by this way (first should be 0, second is half the period) 
                else
                    next
                end
                
            end
            
        end

        def save_traces path
            # * : Saves the required data for comparison as wrapped in a Hash object
            File.write(path, Marshal.dump({ 
                "output_traces" => @output_traces, 
                "id_tab" => @id_tab})
            )
        end
        
        # * : Update the timestamp by the last just encountered
        def update_timestamp timestamp
            @current_timestamp = timestamp
            @output_traces[@current_timestamp] = {}
        end

        # * : Retrieve the next element in the vcd attribute (vcd file) and delete it of the array
        def next_output
            @vcd.shift
        end

        # * : Add last event just encountered to concerned signal 
        def add_output_event signal, val
            @output_traces[signal][timestamp] = val
        end

    end

end