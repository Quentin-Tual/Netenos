require_relative "ht.rb"

module Inserter

    class Xor_And < HT
        
        def initialize nb_trigger = 4
            # * : For the moment the only parameters allowed are power of 2 numbers. This is faster to develop and easier for a start. It may evolve later to allow more possibilities.
            if po2?(nb_trigger)
                super()
                @netlist = gen_netlist(nb_trigger)
            else 
                raise "Error : This parameter is not yet managed. Please use a power of 2 as the number of trigger signal."
            end
        end

        def gen_netlist nb_trigger
            gen_payload
            @payload_in <= gen_triggers(nb_trigger).get_output
            @payload_in = @payload_in.partof.get_free_input

            @propag_time = {}
            wrapper = Netlist::Circuit.new "tmp"
            @components.map {|comp| wrapper << comp}
            @payload_in.partof.propag_time.each do |delay_model,val|
                @components.each{|comp| comp.cumulated_propag_time = 0.0}
                trig_comps = @triggers.collect{|in_p| in_p.partof}.uniq
                trig_comps.each{|comp| comp.update_path_delay 0, delay_model}
                @propag_time[delay_model] = @payload_in.partof.cumulated_propag_time
            end
            wrapper = nil

            return @payload_out.partof
        end

        def gen_triggers nb_trigger
            if nb_trigger.odd?
                carry = Netlist::And2.new 
                @components << carry
            else
                carry = nil
            end
            trig_tree = [[]]
            stage = 0
            nb_gates = nb_trigger/2
            (nb_gates).times do |n|
                tmp = Netlist::And2.new
                @components << tmp
                trig_tree[stage] << tmp
                tmp.get_inputs.each{ |in_p| @triggers << in_p} 
                # @triggers.flatten
            end 
            stage += 1
            if nb_gates.odd? 
                if !carry.nil?
                    carry.get_free_input <= trig_tree[0][0]
                    trig_tree[0].delete_at(0) 
                end
            end

            prev_stage = stage-1
            until trig_tree[prev_stage].length == 1
                trig_tree[prev_stage].length.times do |n|
                    if n.even?
                        tmp = Netlist::And2.new
                        @components << tmp
                        tmp.partof = 0
                        if trig_tree[stage].nil? 
                            trig_tree[stage] = [tmp]
                        else
                            trig_tree[stage] << tmp
                        end 
                        tmp.get_free_input <= trig_tree[prev_stage][n].get_output
                    else
                        tmp = trig_tree[stage][n/2].get_free_input
                        tmp <= trig_tree[prev_stage][n].get_output
                    end
                end
                prev_stage = stage
                stage += 1
            end


            if !carry.nil?
                trig_tree[-1][0].get_output <= carry.get_free_input
                return carry
            else 
                return trig_tree[-1][0]
            end
        end

        def po2?(n)
            if n <= 0
                return false
            end
            while n.even?
              n /= 2
            end
            return n == 1
        end
          

        def gen_payload 
            generated_payload = Netlist::Xor2.new
            @components << generated_payload
            @payload_out = generated_payload.get_output
            @payload_in = generated_payload.get_inputs[1]
            return generated_payload
        end

    end

end