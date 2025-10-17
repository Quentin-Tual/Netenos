# frozen_string_literal: true

module Verilog
  class AstNode
    include ::Visitable
  end

  class Root < AstNode
    attr_reader :filepath,:mod

    def initialize(filepath, mod)
      super()
      @file = filepath
      @mod = mod
    end
  end

  class Module < AstNode
    attr_reader :name,:wires,:inputs,:outputs,:instances

    def initialize name
      super()
      @name = name
      @wires = []
      @inputs = []
      @outputs = []
      @instances = []
    end

    def add node 
      case node
      when Wire
        @wires << node
      when Input
        @inputs << node
      when Output
        @outputs << node
      when Instance 
        @instances << node
      else 
        raise "Error: Unknown type #{node.class} to add in a #{self.class}"
      end
    end
  end

  class Wire < AstNode
    attr_reader :name

    def initialize(name)
      super()
      @name = name
    end
  end

  class Input < AstNode
    attr_reader :name

    def initialize(name)
      super()
      @name = name
    end
  end

  class Output < AstNode
    attr_reader :name

    def initialize(name)
      super()
      @name = name
    end
  end

  class Instance < AstNode
    attr_reader :module_name, :instance_name, :port_map

    def initialize(module_name, instance_name, port_map)
      super()
      @module_name = module_name
      @instance_name = instance_name
      @port_map = port_map
    end
  end

  class PortMap < AstNode
    attr_reader :elements

    def initialize(elements = [])
      super()
      @elements = elements
    end
  end

  class PortMapElement < AstNode
    attr_reader :port, :wire

    def initialize(port, wire)
      super()
      @port = port
      @wire = wire
    end

    def attr_list 
      [@port, @wire]
    end
  end

  class Ident
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class Time
    attr_reader :val

    def initialize(val)
      @val = val
    end
  end
end
