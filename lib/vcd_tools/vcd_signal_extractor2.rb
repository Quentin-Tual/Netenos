module VCD

    class Vcd_Signal_Extractor
        attr_reader :id_tab

        def initialize
            @output_traces = {}
            @id_tab = {}
            @vcd = SizedQueue.new(100000)
            @current_timestamp = nil
        end

        def load_vcd path, start = 0
            File.foreach(path).with_index do |line, i|
                if i <= start
                    next
                else
                    @vcd << line
                end 
            end

            @vcd << :eof
        end

        # * : Update the timestamp by the last just encountered
        def update_timestamp timestamp
            if @output_traces[@current_timestamp].nil?
                @output_traces.delete(@current_timestamp)
            end
            @current_timestamp = timestamp
            @output_traces[@current_timestamp] = {}
        end

        def update_timestamp2 timestamp
            if timestamp != 0 and @output_traces[-1].length == 1 
                @output_traces.delete_at(-1)
            end
            @current_timestamp = timestamp
            @output_traces << [@current_timestamp]
        end
        # * : Retrieve the next element in the vcd attribute (vcd file) and delete it of the array
        def next_output
            return @vcd.pop
        end

        def selected_traces_extraction2
            @output_traces = []
            # * Only keeps the output signals
            tmp = @vcd.pop # init

            until tmp == :eof
                if tmp[0] == '#' # * : new timestamp detected, update it
                    update_timestamp2 tmp.delete_prefix("#").to_i
                    # @output_traces << [@current_timestamp]
                    # pp @output_traces #!DEBUG
                    # gets
                # * : Unexpected syntax are covered by the raise in the next conditionnal branchement
                else
                    value = tmp[0]
                    id = tmp[1..].delete_suffix("\n")
                    if !@id_tab[id].nil?
                        id = id[0..-1]
                        @output_traces[-1] << "#{@id_tab[id]}#{value}"
                    end
                end
            
                tmp = @vcd.pop
            end

            @output_traces.each_with_index{|val, i| if val.length == 1 then @output_traces.delete_at(i) end}
        end

        def selected_traces_extraction
            @output_traces = {}
            # * Only keeps the output signals
            tmp = @vcd.pop # init

            until tmp == :eof
                if tmp[0] == '#' # * : new timestamp detected, update it
                    update_timestamp tmp.delete_prefix("#").to_i
                # * : Unexpected syntax are covered by the raise in the next conditionnal branchement
                else
                    value = tmp[0]
                    id = tmp[1..].delete_suffix("\n")
                    if !@id_tab[id].nil?
                        id = id[0..-1]
                        @output_traces[@current_timestamp][@id_tab[id]] = value
                    end
                end
            
                tmp = @vcd.pop
            end

            # @output_traces.each{|key,val| if val.empty? then @output_traces.delete(key) end}
        end

        # * : Start the extraction, kind of the FSM controler
        def extract2 path, compiler, signals = :outputs_only
            if @vcd.nil?
                raise "Error : A VCD file must be loaded with 'load_vcd()' first."
            end

            start = traces_definition path, compiler, signals

            # TODO : For optimization, it is possible to use a grep to get only the lines needed
            
            producer = Thread.new{
                load_vcd path, start
            }
            
            consumer = Thread.new{
                sleep 1
                selected_traces_extraction2
            }
            
            producer.join
            consumer.join

            return {    "output_traces" => @output_traces, 
                        "id_tab" => @id_tab }
        end
        
        # * : Start the extraction, kind of the FSM controler
        def extract path, compiler, signals = :outputs_only
            if @vcd.nil?
                raise "Error : A VCD file must be loaded with 'load_vcd()' first."
            end

            start = traces_definition path, compiler, signals

            # TODO : For optimization, it is possible to use a grep to get only the lines needed
            
            producer = Thread.new{
                load_vcd path, start
            }
            
            consumer = Thread.new{
                sleep 1
                selected_traces_extraction
            }
            
            producer.join
            consumer.join

            return {    "output_traces" => @output_traces, 
                        "id_tab" => @id_tab }
        end

        # * : Defines traces to follow and their identifier in the vcd file (header data extraction)
        def traces_definition path, compiler, opt=:outputs_only
            data_type = (compiler == :nvc) ? "logic" : "reg";

            if opt.is_a? Array # * 'opt' is a list of signals to monitor
                return traces_definition_signal_list(path, compiler,opt)
            elsif opt == :outputs_only
                return traces_definition_output_only(path, compiler)
            else # :all_sig for example
                raise "Error : Functionnality not available yet ! WIP"
            end
        end

        def traces_definition_output_only path, compiler
            data_type = (compiler == :nvc) ? "logic" : "reg";

            File.foreach(path).with_index do |line, i|
                # tmp = next_output
                if line == "$enddefinitions $end\n" 
                    return i
                else
                    if line.match?(/\$var #{data_type} [0-9]+ .+ tb_o[0-9]+_s .+/) # ! : Not really optimized, certainly could be improved
                        line = line.split
                        @id_tab[line[3]] = line[4] # * : The original signal name (line[4]) is associated to VCD ID (line[3]).
                    end
                end
            end

            raise "Error : VCD definition end not found."
        end

        def traces_definition_signal_list path, compiler, opt

            File.foreach(path).with_index do |line, i|
                # tmp = next_output
                if line == "$enddefinitions $end\n" 
                    return i
                else
                    if opt.include? line.split(" ")[4] 
                        line = line.split
                        @id_tab[line[3]] = line[4] # * : The original signal name (line[4]) is associated to VCD ID (line[3]).
                    end    
                end
            end

        end

        def get_last_timestamp path
            
            `tail -n 100000 #{path} > obj/tmp.vcd`

            File.foreach("obj/tmp.vcd").reverse_each do |line|
                if line[0] == '#'
                    `rm obj/tmp.vcd`
                    return line.delete_prefix('#').to_i
                end 
            end

            raise "Error: clock not found"
        end

        def get_clock_period path, clk_name="obs_clk"
            # * : Returns the clock period for the given vcd file (by default the OBSERVATION clock named 'obs_clk')
            id = nil

            File.foreach(path) do |line|
                if line.split.include? clk_name
                    id = line.split[3]
                    break
                else
                    next
                end
            end

            bounds = []

            last_timestamp = 0
            timestamp_zone = false

            # State machine 
                # 1 : reach the timestamp_zone (enddefinitions marker passed)
                # 2 : Get 2 timestamps for a transition on the searched clock
                # 3 : return the computed clock period (as 2 times the semi-period observed)
            File.foreach(path) do |line|
                if line.include? "$enddefinitions $end" 
                    timestamp_zone = true
                elsif timestamp_zone

                    if bounds.length == 2
                        # * Compute the clk period as 2x the second timestamp value
                        return bounds[1]*2
                    elsif line[0]=='#'
                        # * Memorize the last encountered timestamp (0 as the first) 
                        # * When found memorize the timestamp 
                        last_timestamp = line.delete_prefix("#").delete_suffix("\n")
                    elsif line.include?(id) and (line.length < 4) # We know the clock is always in the first symbol attribution so its ID is only one symbol long 
                        # * Check if the ID has an event in this timestamp until it is another timestamp, then update the last uncountered timestamp
                        bounds << last_timestamp.to_i
                    # * When 2 timestamp are found by this way (first should be 0, second is half the period) 
                    else
                        next
                    end
                else # Keep goind to reach the wanted zone
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

        # * : Add last event just encountered to concerned signal 
        def add_output_event signal, val
            @output_traces[signal][timestamp] = val
        end

    end

end