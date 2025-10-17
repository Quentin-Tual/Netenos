module SDF
  
  class Node 
    include ::Visitable

    attr_accessor :subnodes

    def initialize 
      @subnodes = []
    end

    def add subnode
      @subnodes << subnode
    end
  end

  class EdgeNode
    include Visitable

    attr_accessor :data

    def initialize data
      @data = data
    end
  end

  class DelayNode < EdgeNode
    attr_reader :wire, :delays

    def initialize(wire, delays)
      @wire = wire
      @delays = delays
    end
  end

  class Root < Node 
    def initialize filename
      super()
      @name = filename
    end
  end

  class DELAYFILE < Node; end;
  class DESIGN < EdgeNode; end;
  class TIMESCALE < EdgeNode; end;
  class CELL < Node; end;
  class CELLTYPE < EdgeNode; end;
  class INSTANCE < EdgeNode; end;
  class DELAY < Node; end;
  class ABSOLUTE < Node; end;
  class INTERCONNECT < DelayNode; end;
  class IOPATH < DelayNode; end;

  class Ident
    attr_reader :name

    def initialize name
      @name = name
    end
  end

  class Time
    attr_reader :val

    def initialize val
      @val = val
    end
  end

  class Wire 
    attr_reader :source_name, :sink_name
    def initialize(source_name, sink_name)
      @source_name = source_name
      @sink_name = sink_name
    end
  end

  class DelayTable
    attr_accessor :rise, :fall

    def initialize rise, fall
      @rise = rise
      @fall = fall
    end

    def attr_list 
      [@rise,@fall]
    end
  end

  class DelayArray
    attr_accessor :min, :typ, :max
     
    def initialize txt
      txt.tr!('()','')  
      @min, @typ, @max = txt.split(':')
    end

    def attr_list
      [@min,@typ,@max]
    end
  end
end
