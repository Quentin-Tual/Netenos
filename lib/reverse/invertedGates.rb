 require_relative '../netlist.rb'

 module Reverse
    class InvertedGate
      attr_accessor :name, :sinks, :source, :partof, :propag_time

      def initialize name = "#{self.class.name.split("::")[1]}#{self.object_id}", partof = nil, nb_inputs = self.class.name.split("::")[1].chars[-1].to_i
        @name = name
        @sinks = []
        @source = []
        @partof = partof
        @propag_time = {    :one => 1.0, 
                            :int => (((nb_inputs+1.0)/2.0)).round(3), 
                            :int_rand => (((nb_inputs+1.0)/2.0)*rand(0.9..1.1)).round(3),
                            :fract => (0.3 + ((((nb_inputs+1.0)/2.0)*rand(0.9..1.1))/2.2)).round(3)
                        } # Supposedly in nanoseconds, 2.2 is the max value , 0.3 is the offset to center the distribution at 1.(normalization to fit in the other model)
        klass = self.class.name.split("::")[1]
        if klass == "Xor2"
            @propag_time[:int_multi] = 2.5
        elsif klass == "Nand2" or klass == "Nor2" 
            @propag_time[:int_multi] = 2.0
        else
            @propag_time[:int_multi] = 1.5
        end
      end


      def <=(e)
        source << e
        # e.partof = self
        # case e 
        # when Port
        #     case e.direction
        #     when :in
        #         if @ports[:in].length < 2
        #             @ports[:in] << e
        #         else
        #             raise "Error : Trying to add a second port to a NOT gate inputs (only 1 input port available)."        
        #         end
        #     when :out
        #         if @ports[:out].length < 1 
        #         @ports[:out] << e
        #         else
        #             raise "Error : Trying to add a second output port to a logical gate (2 ports available)." 
        #         end
        #     end
        # else 
        #     raise "Error : Unexpected or unknown class -> Integration of #{e.class.name} into #{self.class.name} is not allowed."
        # end
      end

      def update 
        # TODO : Get event at the input of the inverted gate
        # TODO : compute all the possibles events at the output of the inverted gate
        # TODO : push the possible events to the output 
        # TODO : call the update of the next gate
      end
    end

    class InvertedAnd3 < InvertedGate; end
    class InvertedOr3 < InvertedGate; end
    class InvertedXor3 < InvertedGate; end
    class InvertedNand3 < InvertedGate; end
    class InvertedNor3 < InvertedGate; end

    class InvertedAnd2 < InvertedGate
      def initialize(*args)
        super(*args)
      end

      def get_input_transition output_transition
        case output_transition
        when "0" 
            return [["0","0"],["0","1"],["1","0"],["0","R"],["R","0"],["0","F"],["F","0"],["R","F"],["F","R"]]
        when "1" 
            return [["1","1"]]
        when "R"
            return [["1","R"],["R","1"],["R","R"]]
        when "F"
            return [["1","F"],["F","1"],["F","F"]]
        else
            raise "Error: Unexpected transition value encountered."
        end
      end
    end

    class InvertedOr2 < InvertedGate
      def initialize(*args)
        super(*args)
      end

      def get_input_transition output_transition
        case output_transition
        when "0" 
            return [["0","0"]]
        when "1" 
            return [["0","1"],["1","0"],["1","1"],["1","F"],["F","1"],["1","R"],["R","1"],["R","F"],["F","R"]]
        when "R"
            return [["0","R"],["R","0"],["R","R"]]
        when "F"
            return [["0","F"],["F","0"],["F","F"]]
        else
            raise "Error: Unexpected output transition value encountered."
        end
      end
    end

    class InvertedXor2 < InvertedGate
      def initialize(*args)
        super(*args)
      end

      def get_input_transition output_transition
        case output_transition
        when "0" 
            return [["0","0"],["1","1"],["R","R"],["F","F"]]
        when "1" 
            return [["0","1"],["1","0"],["R","F"],["F","R"]]
        when "R"
            return [["0","R"],["R","0"],["1","F"],["F","1"]]
        when "F"
            return [["0","F"],["F","0"],["1","R"],["R","1"]]
        else
            raise "Error: Unexpected transition value encountered."
        end
      end
    end

    class InvertedNand2 < InvertedGate
      def initialize(*args)
        super(*args)
      end
       
      def get_input_transition output_transition
        case output_transition
        when "0" 
            return [["1","1"]]
        when "1" 
            return [["0","0"],["1","0"],["0","1"],["0","R"],["R","0"],["0","F"],["F","0"]]
        when "R"
            return [["1","F"],["F","1"],["F","F"]]
        when "F"
            return [["1","R"],["R","1"],["R","R"]]
        else
            raise "Error: Unexpected transition value encountered."
        end
      end
    end

    class InvertedNor2 < InvertedGate
      def initialize(*args)
        super(*args)
      end
       
      def get_input_transition output_transition
        case output_transition
        when "0" 
            return [["0","1"],["1","0"],["1","1"],["1","R"],["R","1"],["1","F"],["F","1"]]
        when "1" 
            return [["0","0"]]
        when "R"
            return [["0","F"],["F","0"],["F","F"]]
        when "F"
            return [["0","R"],["R","0"],["R","R"]]
        else
            raise "Error: Unexpected transition value encountered."
        end
      end
    end

    class InvertedNot < InvertedGate
      def initialize(*args)
        super(*args)
      end

      def get_input_transition output_transition
        case output_transition
        when "0" 
            return [["1"]]
        when "1" 
            return [["0"]]
        when "R"
            return [["F"]]
        when "F"
            return [["R"]]
        else
            raise "Error: Unexpected transition value encountered."
        end
    end
       
    end

    class InvertedBuffer < InvertedGate
      def initialize(*args)
        super(*args)
      end
       
      def get_input_transition output_transition
        case output_transition
        when "0" 
            return [["0"]]
        when "1" 
            return [["1"]]
        when "R"
            return [["R"]]
        when "F"
            return [["F"]]
        else
            raise "Error: Unexpected transition value encountered."
        end
      end
    end

    class InvertedZero < InvertedGate
      def initialize(*args)
        super(*args)
      end
       
    end

    class InvertedOne < InvertedGate
      def initialize(*args)
        super(*args)
      end
       
    end
end