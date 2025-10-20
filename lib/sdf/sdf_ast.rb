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

    def get_subnode(ntype)
      @subnodes.find{|n| n.instance_of? ntype}
    end

    def contains_class? *klass
      klass.all? do |k|
        @subnodes.any?{|obj| obj.instance_of? k}
      end
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
    attr_reader :name
    def initialize filename
      super()
      @name = filename
    end

    def valid?
      !@name.empty? and subnodes.length == 1
    end
  end

  class DELAYFILE < Node; 
    def valid?
      contains_class?(DESIGN,TIMESCALE,CELL)
    end 

    def design 
      get_subnode DESIGN
    end

    def timescale
      get_subnode TIMESCALE
    end

    def cells
      @subnodes.select{|n| n.instance_of? CELL}
    end
  end;
  class DESIGN < EdgeNode; end;
  class TIMESCALE < EdgeNode; end;
  class CELL < Node; 
    def instance
      get_subnode INSTANCE
    end

    def celltype
      get_subnode CELLTYPE
    end

    def delay
      get_subnode DELAY
    end
  end;
  class CELLTYPE < EdgeNode; end;
  class INSTANCE < EdgeNode; end;
  class DELAY < Node; 
    def valid?
      contains_class? ABSOLUTE
    end

    def absolute
      get_subnode ABSOLUTE
    end
  end;
  class ABSOLUTE < Node; 
    def valid?
      contains_class?(INTERCONNECT)
    end

    def interconnects
      subnodes.select{|n| n.instance_of? INTERCONNECT}
    end
  end;
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
