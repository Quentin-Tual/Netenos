module Netlist
  # Components classes declaration (SubCircuits herited, global circuit components)
  class A < Circuit
    def initialize(name)
      super(name)
      %w[i1 i2].each { |port_name| self << Port.new(port_name, :in) }
      self << Port.new('o1', :out)
    end
  end

  class B < Circuit
    def initialize(name)
      super(name)
      %w[i1 i2].each { |port_name| self << Port.new(port_name, :in) }
      self << Port.new('o1', :out)
    end
  end

  class C < Circuit
    def initialize(name)
      super(name)
      %w[i1 i2 i3].each { |port_name| self << Port.new(port_name, :in) }
      %w[o1 o2].each { |port_name| self << Port.new(port_name, :out) }
    end
  end
end
