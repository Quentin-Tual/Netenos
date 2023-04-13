require_relative "ht.rb"
require_relative "../netlist.rb"

module Netlist 

    class Xor_And < HT

        def initialize nb_trigger = 4
            # * : For the moment the only parameters allowed are power of 2 numbers. This is faster to develop and easier for a start. It may evolve later to allow more possibilities.
            if po2?(nb_trigger)
                # TODO : Générer toute la structure du HT dans le constructeur, possible en faisant appel à des méthodes lorsque nécessaire.
                super 
                @netlist = gen_netlist(nb_trigger)
            else 
                raise "Error : This parameter is not yet managed. Please use a power of 2 as the number of trigger signal."
            end
        end

        def gen_netlist nb_trigger
            gen_payload
            @payload_in <= gen_triggers(nb_trigger).get_output
            @payload_in = @payload_in.partof.get_free_input
            return @payload_out.partof
        end

        def gen_triggers nb_trigger
            # TOdo : Si le nombre de trigger est impaire faire -1 et enregistrer une porte de "carry" à utiliser à la fin
            if nb_trigger.odd?
                carry = Netlist::And.new 
                @components << carry
            else
                carry = nil
            end
            # Todo : Diviser le nombre de trigger par 2 pour connaître le nombre de portes à l'étage 0
            trig_tree = [[]]
            stage = 0
            nb_gates = nb_trigger/2
            # TODO : Instancier ce nombre de portes
            (nb_gates).times do |n|
                tmp = Netlist::And.new
                @components << tmp
                trig_tree[stage] << tmp
                tmp.get_inputs.each{ |in_p| @triggers << in_p} 
                # @triggers.flatten
            end 
            stage += 1
            # TODO : si le nombre de porte est impaire
            if nb_gates.odd? 
                # TODO : relier une sortie à la "carry" si elle existe.
                if !carry.nil?
                    carry.get_free_input <= trig_tree[0][0]
                    trig_tree[0].delete_at(0) 
                end
            end

            # TODO : répéter l'opération jusqu'à ce qu'une seule porte soit instancier (une seule sortie)
            prev_stage = stage-1
            until trig_tree[prev_stage].length == 1
                # TODO : Pour chaque paire de ces portes instancier une porte reliée à leur sortie, c'est l'étage suivant
                trig_tree[prev_stage].length.times do |n|
                    if n.even?
                        tmp = Netlist::And.new
                        @components << tmp
                        if trig_tree[stage].nil? 
                            trig_tree[stage] = [tmp]
                        else
                            trig_tree[stage] << tmp
                        end 
                        tmp.get_free_input <= trig_tree[prev_stage][n].get_output
                    else
                        # ! : Get_sinks renvoi une valeur nulle
                        tmp = trig_tree[stage][n/2].get_free_input
                        tmp <= trig_tree[prev_stage][n].get_output
                    end
                end
                prev_stage = stage
                stage += 1
            end


            # TODO : retourner la dernière porte AND instanciée (liée à toutes les autres par références)
            if !carry.nil?
                trig_tree[-1][0].get_output <= carry.get_free_input
                return carry
            else 
                return trig_tree[-1][0]
            end
        end

        def po2?(n)
            return false if n <= 0
            while n.even?
              n /= 2
            end
            n == 1
        end
          

        def gen_payload 
            generated_payload = Netlist::Xor.new
            @components << generated_payload
            @payload_out = generated_payload.get_output
            @payload_in = generated_payload.get_inputs[1]
            return generated_payload
        end

    end

end