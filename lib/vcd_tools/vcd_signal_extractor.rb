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
        def extract
            if @vcd.nil?
                raise "Error : A VCD file must be loaded with 'load_vcd()' first."
            end
            traces_definition
            selected_traces_extraction
            return {    "output_traces" => @output_traces, 
                        "id_tab" => @id_tab }
        end

        # * : Defines traces to follow and their identifier in the vcd file (header data extraction)
        # ? : Renommer en get_ids ou id_extraction ou extract_definitions 
        def traces_definition
            @vcd.shift(8)
            tmp = next_output

            until tmp == "$enddefinitions $end" 
                if tmp.match?(/\$var reg [0-9]+ .+ tb_o[0-9]+_s .+/) # ! : Semble tourner à l'infini...
                    tmp = tmp.split
                    @id_tab[tmp[3]] = tmp[4] # * : The original signal name (tmp[4]) is associated to VCD ID (tmp[3]).
                    # @output_traces[tmp[3]] = {} # * : Hash initialization allowing to add timestamp/value pairs later 
                end
                tmp = next_output
            end
        end

        def selected_traces_extraction
            @output_traces = {}
            # * Only keeps the output signals
            tmp = next_output
            until tmp.nil?
                if tmp.match?(/\A#\d+/) # * : new timestamp detected, update it
                    update_timestamp tmp.delete_prefix("#")
                # * : Unexpected syntax are covered by the raise in the next conditionnal branchement
                else
                    tmp.concat("\n")
                    # tmp.map!{|e| e.concat "\n"}
                    # if tmp.length == 1
                    if @id_tab.keys.collect{|id| tmp.include?("#{id}\n")}.include?(true)
                        tmp = tmp.chars
                        @output_traces[@current_timestamp][tmp[1]] = tmp[0]
                    end
                    # elsif tmp.length == 2 # ! Not sure it happens anytime with the generated testbenches
                    #     @output_traces[@current_timestamp][tmp[1]] = tmp[0]
                    # else 
                    #     raise "Internal error : Unexpected syntax encountered."
                    # end
                end

                tmp = next_output # todo : Le déplacer en début de boucle et supprimer l'initialisation juste avant la boucle ?
            end

            @output_traces.each{|key,val| if val.empty? then @output_traces.delete(key) end}
        end

        def get_clock_period
            # * : Returns the clock period for the given vcd file 
            # TODO : Find 'clk' VCD_ID in declarations section
                # TODO : Go to line 17 -> recover the ID
            id = @vcd[16].split[3]

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

            # TODO : Reuse the line splitted version of the file
            @vcd[events_line..].each do |line|
                if bounds.length == 2
                    # TODO : Compute the clk periof as 2x the second timestamp value
                    return bounds[1]*2
                elsif line[0]=='#'
                    # TODO : Memorize the last encountered timestamp (0 as the first) 
                    # TODO : When found memorize the timestamp 
                    last_timestamp = line.delete_prefix("#")
                elsif line.include?(id) and (line.length < 3)
                    # TODO : Check if the ID has an event in this timestamp until it is another timestamp, then update the last uncountered timestamp
                    bounds << last_timestamp.to_i
                # TODO : When 2 timestamp are found by this way (first should be 0, second is half the period) 
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