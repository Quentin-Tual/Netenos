module Verilog
  
  def self.parse path 
    parser = Verilog::Parser.new
    parser.parse(path)
  end

  def self.load_netlist path
    netlister = Verilog::NetlisterVisitor.new
    ast = parse(path)
    ast.accept(netlister)
  end

end