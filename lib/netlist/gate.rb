require_relative 'port.rb'

module Netlist

    class Gate < Circuit
        attr_reader :name, :ports, :partof

        def initialize name = "#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil
            @name = name
            @ports = {:in => [Netlist::Port.new("i0",:in), Netlist::Port.new("i1",:in)], :out => [Netlist::Port.new("o0",:out)]}
            @ports.each_value{|io| io.each{|p| p.partof = self}}
            @partof = partof
            @components = [] 
        end

        def <<(e)
            e.partof = self
            case e 
            when Port
                case e.direction
                when :in
                    if @ports[:in].length < 2
                        @ports[:in] << e
                    else
                        raise "Error : Trying to add a second port to a NOT gate inputs (only 1 input port available)."        
                    end
                when :out
                    if @ports[:out].length < 1 
                    @ports[:out] << e
                    else
                        raise "Error : Trying to add a second output port to a logical gate (2 ports available)." 
                    end
                end
            else 
                raise "Error : Unexpected or unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
            end
        end

        def get_outputs
            @ports[:out]
        end

        def get_output
            @ports[:out][0]
        end
    end

    class And2 < Gate; end

    class Or2 < Gate; end

    class Xor2 < Gate; end

    class Nor2 < Gate; end

    class Nand2 < Gate; end
    
    class Not < Gate

        def initialize name="#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil
            @name = name
            @ports = {:in => [Netlist::Port.new("i0", :in)], :out => [Netlist::Port.new("o0", :out)]}
            @ports.each_value{|p| p[0].partof = self}
            @partof = partof
            @components = []
        end

        def <<(e)
            e.partof = self
            case e 
            when Port
                case e.direction
                when :in
                    if @ports[:in].length < 1
                        @ports[:in] << e
                    else
                        raise "Error : Trying to add a second port to a NOT gate inputs (only 1 input port available)."        
                    end
                when :out
                    if @ports[:out < 1] 
                    @ports[:out] << e
                    else
                        raise "Error : Trying to add a second output port to a logical gate (2 ports available)." 
                    end
                end
            else 
                raise "Error : Unexpected or unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
            end
        end

    end

    $DEF_GATE_TYPES = [And2, Or2, Xor2, Not, Nand2, Nor2]
    $GTECH = $DEF_GATE_TYPES
end