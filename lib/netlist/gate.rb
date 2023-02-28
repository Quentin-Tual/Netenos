require_relative 'port.rb'

module Netlist

    class Gate
        attr_reader :ports, :partof
        
        def initialize 
            @ports = {:in => [Netlist::Port.new("i0",:in), Netlist::Port.new("i1",:in)], :out => [Netlist::Port.new("o0",:out)]}
            @ports.each_value{|p| p[0].partof = self}
            @partof = nil
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
                        raise "Error : Trying to add a third input to a logical gate (only 2 ports available)."        
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

        def inputs
            @ports[:in]
        end
      
        def outputs
            @ports[:out]
        end

        def get_port_named str
            @ports.values.flatten.find{|port| port.name==str}
        end

    end

    class AndGate < Gate; end

    class OrGate < Gate; end

    class XorGate < Gate; end
    
    class NotGate < Gate

        def initialize 
            @ports = {:in => [Netlist::Port.new("i0",:in)], :out => [Netlist::Port.new("o0",:out)]}
            @ports.each_value{|p| p[0].partof = self}
            @partof = nil
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

end