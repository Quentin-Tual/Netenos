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

    def accept(visitor)
      self_classname = self.class.name.split('::').last
      visitor.send("visit_#{self_classname}".to_sym, self)
    end

    def valid?
      @subnodes.all?{|n| n.valid?}
    end
  end

  class EdgeNode
    include Visitable

    attr_accessor :data

    def initialize data
      @data = data
    end

    def accept(visitor)
      self_classname = self.class.name.split('::').last
      visitor.send("visit_#{self_classname}".to_sym, self)
    end
  end

  class DelayNode < EdgeNode
    attr_reader :wire, :delays

    def initialize(wire, delays)
      @wire = wire
      @delays = delays
    end

    def same_wire? w
      @wire.identical? w
    end

    def attr_flat_float_list 
      @delays.attr_list.collect do |delayArr|
        delayArr.attr_float_list
      end.flatten
    end

    def get_flat_float_list attr
      @delays.get_float_list(attr)
    end

    def get_flat_float_list_rising attr
      @delays.get_float_list_rising(attr)
    end

    def get_flat_float_list_falling attr
      @delays.get_float_list_falling(attr)
    end

    def apply_fun fun
      values = attr_flat_float_list
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end

    def apply_fun_to_col fun, col
      values = get_flat_float_list(col)
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end

    def valid?
      @wire.valid? and @delays.valid?
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
      super
    end
  end

  class DELAYFILE < Node; 
    def valid?
      contains_class?(DESIGN,TIMESCALE,CELL) and super
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
  end

  class DESIGN < EdgeNode
    # def accept visitor
    #   visitor.visit_DESIGN(self)
    # end

    def valid?
      !(@data.nil? or @data.empty?)
    end
  end
  class TIMESCALE < EdgeNode
    def valid?
      @data.valid?
    end
  end
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

    # def accept visitor
    #   visitor.visit_Cell(self)
    # end

    def valid?
      contains_class?(INSTANCE,CELLTYPE,DELAY) and super
    end 
  end

  class CELLTYPE < EdgeNode
    # def accept visitor
    #   visitor.visitCellType(self)
    # end

    def valid?
      !(@data.nil? or @data.empty?)
    end
  end

  class INSTANCE < EdgeNode
    # def accept visitor 
    #   visitor.accept(self)
    # end

    def valid?
      @data.valid?
    end
  end

  class DELAY < Node
    def valid?
      (contains_class?(ABSOLUTE)) and super
    end

    # def accept visitor
    #   visitor.visitDelay(self)
    # end

    def absolute
      get_subnode ABSOLUTE
    end
  end

  class ABSOLUTE < Node
    # def accept visitor
    #   visitor.visitAbsolute(self)
    # end

    def valid?
      (contains_class?(INTERCONNECT) or contains_class?(IOPATH)) and super
    end

    def interconnects
      @subnodes.select{|n| n.instance_of? INTERCONNECT}
    end

    def iopaths
      @subnodes.select{|n| n.instance_of? IOPATH}
    end

    def apply_fun fun
      values = @subnodes.collect do |delayNode|
        delayNode.attr_flat_float_list
      end.flatten
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end

    def apply_fun_to_col fun, col
      values = @subnodes.collect do |dly_node|
        dly_node.get_flat_float_list(col)
      end.flatten
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end

    def apply_fun_to_col_rising fun, col
      values = @subnodes.collect do |dly_node|
        dly_node.get_flat_float_list_rising(col)
      end.flatten
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end

    def apply_fun_to_col_falling fun, col
      values = @subnodes.collect do |dly_node|
        dly_node.get_flat_float_list_falling(col)
      end.flatten
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end
  
    def apply_fun_to_col_rising_ioarc fun, col, g
      values = g.collect{|n| n.get_flat_float_list_rising(col)}
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end
    
    def apply_fun_to_col_falling_ioarc fun, col, g
      values = g.collect{|n| n.get_flat_float_list_falling(col)}
      if fun == :avg or fun == :mean
        (values.sum / values.size).round(3)
      else # :min or :max
        values.send(fun)
      end
    end

  end

  class INTERCONNECT < DelayNode
  end

  class IOPATH < DelayNode;
  end;
  class Ident
    attr_reader :name

    def initialize name
      @name = name
    end

    # def accept visitor
    #   visitor.visit_Ident(self)
    # end

    def valid?
      !@name.nil?
    end
  end

  class Time
    attr_reader :val

    def initialize val
      @val = val
    end

    # def accept visitor
    #   visitor.visit_Time(self)
    # end


    def valid? 
      !@val.nil?
    end
  end

  class Wire 
    attr_reader :source_name, :sink_name
    def initialize(source_name, sink_name)
      @source_name = source_name
      @sink_name = sink_name
    end

    def identical? w
      (@source_name == w.source_name) and (@sink_name == w.sink_name)
    end

    def valid? 
      @source_name.valid? and @sink_name.valid? and @source_name != @sink_name
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

    def get_float_list attr
      [@rise.send(attr).to_f, @fall.send(attr).to_f]
    end

    def get_float_list_rising attr
      @rise.send(attr).to_f
    end

    def get_float_list_falling attr
      @fall.send(attr).to_f
    end

    def valid?
      @rise.valid? and @fall.valid?
    end

    def accept(visitor)
      visitor.visit_DelayTable(self)
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

    def attr_float_list
      [@min,@typ,@max].map(&:to_f)
    end

    def accept visitor
      visitor.visitDelayArray(self)
    end

    def valid?
      typ = @typ.to_f
      min = @min.to_f
      max = @max.to_f
      (typ <= max) and (typ >= min) and (max >= min)
    end

    def accept(visitor)
      visitor.visit_DelayArray(self)
    end
  end
end
