module Netlist
    class Wire
        attr_accessor :name, :fanin, :fanout

        def initialize name
            @name = name
            @fanin = nil # Always only one source to the input 
            @fanout = []
        end

        def <= source 
            if source.is_a? Port 
                if !source.is_global? and source.is_input?
                    raise "Error : This port #{source.get_full_name} is a non global input and can't be used as a source."
                end
            end
            if self.is_a? Port 
                if !self.is_global? and self.is_output?
                    raise "Error : This port #{self.get_full_name} is a non global output and can't be used as a sink."
                end
            end
            source.fanout << self
            if @fanin.nil?
                @fanin = source
            else
                raise "Error : Interface #{self.get_full_name} already has a source, please verify."
            end
        end

        def get_source
            return @fanin
        end

        def get_sinks
            return @fanout
        end

        def get_full_name
            return @name
        end

        def has_source?
            return fanin.nil?
        end

        def to_hash
            return {
                :class => self.class.name,
                :data =>    {   
                                :name => @name,
                                :fanin => @fanin == nil ? nil : @fanin.name,
                                :fanout => @fanout == [] ? nil : @fanout.collect!{|sink| sink.name}

                            }
            }
        end

        # def <= port
        #     self.plug port
        #     port.plugWire self
        # end

        # def plug port 
        #     # ! : Quid pour les entrées et sorties globales ? Sûrement un soucis, nécessite des conditions pour prendre en charge ces cas particuliers
        #     # * : On ne peut avoir qu'une sortie par 'Wire'
        #     # * : On peut avoir un nombre théoriquement illimité d'entrées
        #     if ((port.direction == :out) and (!port.is_global?)) or ((port.direction == :in) and (port.is_global?)) 
        #         if @pluggedOutput.nil?
        #             @pluggedOutput = port
        #             @name = "w#{port.partof.name}#{port.name}"
        #         else 
        #             raise "Error : This wire #{self.name} is already plugged to an output port #{@pluggedOutput.partof.name}#{@pluggedOutput.name}, can't wire it to #{port.partof.name}#{port.name}."
        #         end
        #     else 
        #         @pluggedInputs << port
        #     end
        # end

        # def getPluggedInputs # ! doit renvoyer un tableau de poprt (et pas un énumérateur)
        #     # 
        #     return @pluggedInputs
        # end

        # def getPluggedOutput
        #     return [@pluggedOutput] # Voir si la conversion en énumérateur est nécessaire ici
        # end

        # def to_hash uid_table
        #     uid_table << self.object_id
        #     {
        #         :class => self.class.name,
        #         :data =>    {   :name           => @name, 
        #                         :pluggedInputs  => @pluggedInputs.collect{|p| p.name},
        #                         :pluggedOutput  => @pluggedOutput.name
        #                     }
        #     }
        # end
    end
end