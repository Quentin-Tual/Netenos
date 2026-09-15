require_relative '../netlist'

module Reverse
  class InvertedGate
    attr_accessor :name, :sinks, :source, :partof, :propag_time

    def initialize(name = "#{self.class.name.split('::')[1]}#{object_id}", partof = nil,
                   nb_inputs = self.class.name.split('::')[1].chars[-1].to_i)
      @name = name
      @sinks = []
      @source = []
      @partof = partof
      @propag_time = { one: 1.0,
                       int: ((nb_inputs + 1.0) / 2.0).round(3),
                       int_rand: (((nb_inputs + 1.0) / 2.0) * rand(0.9..1.1)).round(3),
                       fract: (0.3 + ((((nb_inputs + 1.0) / 2.0) * rand(0.9..1.1)) / 2.2)).round(3) } # Supposedly in nanoseconds, 2.2 is the max value , 0.3 is the offset to center the distribution at 1.(normalization to fit in the other model)
      klass = self.class.name.split('::')[1]
      @propag_time[:int_multi] = if klass == 'Xor2'
                                   2.5
                                 elsif %w[Nand2 Nor2].include?(klass)
                                   2.0
                                 else
                                   1.5
                                 end
    end

    def <=(other)
      source << other
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

    def get_input_transition(output_transition)
      case output_transition
      when '0'
        [%w[0 0], %w[0 1], %w[1 0], %w[0 R], %w[R 0], %w[0 F], %w[F 0], %w[R F], %w[F R]]
      when '1'
        [%w[1 1]]
      when 'R'
        [%w[1 R], %w[R 1], %w[R R]]
      when 'F'
        [%w[1 F], %w[F 1], %w[F F]]
      else
        raise 'Error: Unexpected transition value encountered.'
      end
    end
  end

  class InvertedOr2 < InvertedGate
    def initialize(*args)
      super(*args)
    end

    def get_input_transition(output_transition)
      case output_transition
      when '0'
        [%w[0 0]]
      when '1'
        [%w[0 1], %w[1 0], %w[1 1], %w[1 F], %w[F 1], %w[1 R], %w[R 1], %w[R F], %w[F R]]
      when 'R'
        [%w[0 R], %w[R 0], %w[R R]]
      when 'F'
        [%w[0 F], %w[F 0], %w[F F]]
      else
        raise 'Error: Unexpected output transition value encountered.'
      end
    end
  end

  class InvertedXor2 < InvertedGate
    def initialize(*args)
      super(*args)
    end

    def get_input_transition(output_transition)
      case output_transition
      when '0'
        [%w[0 0], %w[1 1], %w[R R], %w[F F]]
      when '1'
        [%w[0 1], %w[1 0], %w[R F], %w[F R]]
      when 'R'
        [%w[0 R], %w[R 0], %w[1 F], %w[F 1]]
      when 'F'
        [%w[0 F], %w[F 0], %w[1 R], %w[R 1]]
      else
        raise 'Error: Unexpected transition value encountered.'
      end
    end
  end

  class InvertedNand2 < InvertedGate
    def initialize(*args)
      super(*args)
    end

    def get_input_transition(output_transition)
      case output_transition
      when '0'
        [%w[1 1]]
      when '1'
        [%w[0 0], %w[1 0], %w[0 1], %w[0 R], %w[R 0], %w[0 F], %w[F 0]]
      when 'R'
        [%w[1 F], %w[F 1], %w[F F]]
      when 'F'
        [%w[1 R], %w[R 1], %w[R R]]
      else
        raise 'Error: Unexpected transition value encountered.'
      end
    end
  end

  class InvertedNor2 < InvertedGate
    def initialize(*args)
      super(*args)
    end

    def get_input_transition(output_transition)
      case output_transition
      when '0'
        [%w[0 1], %w[1 0], %w[1 1], %w[1 R], %w[R 1], %w[1 F], %w[F 1]]
      when '1'
        [%w[0 0]]
      when 'R'
        [%w[0 F], %w[F 0], %w[F F]]
      when 'F'
        [%w[0 R], %w[R 0], %w[R R]]
      else
        raise 'Error: Unexpected transition value encountered.'
      end
    end
  end

  class InvertedNot < InvertedGate
    def initialize(*args)
      super(*args)
    end

    def get_input_transition(output_transition)
      case output_transition
      when '0'
        [['1']]
      when '1'
        [['0']]
      when 'R'
        [['F']]
      when 'F'
        [['R']]
      else
        raise 'Error: Unexpected transition value encountered.'
      end
    end
  end

  class InvertedBuffer < InvertedGate
    def initialize(*args)
      super(*args)
    end

    def get_input_transition(output_transition)
      case output_transition
      when '0'
        [['0']]
      when '1'
        [['1']]
      when 'R'
        [['R']]
      when 'F'
        [['F']]
      else
        raise 'Error: Unexpected transition value encountered.'
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
