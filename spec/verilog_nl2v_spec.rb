require_relative '../lib/netenos'

RSpec.describe Verilog::Netlist2Verilog do

  context "With xor5_prepnr.nl.v" do 
    before(:all) do
      Verilog::NetlisterVisitor.new
      # Parse xor5.v to obtain its AST
      parser = Verilog::Parser.new
      ast = parser.parse("tests/verilog/xor5_prepnr.nl.v")
      # Apply NetlisterVisitor to the AST
      netlister = Verilog::NetlisterVisitor.new
      nl = ast.accept(netlister)
      # Apply Netlist2Verilog to the netlist
      Verilog::Netlist2Verilog.new(nl).print("tests/tmp/test_Netlist2Verilog.v")
    end

    it "matches the expected" do
      expected = File.read("tests/verilog/ref_test_Netlist2Verilog.v")
      actual = File.read("tests/tmp/test_Netlist2Verilog.v") 
      expect(expected).to eq(actual)
    end
  end

  # context "With xor5.blif" do 
  #   before(:all) do 
  #     Netlist::generate_gtech(5)
  #     nl = Converter::ConvBlif2Netlist.new.convert "tests/C17.blif"
  #     # Apply Netlist2Verilog to the netlist
  #     Verilog::Netlist2Verilog.new(nl).print("tests/tmp/test_Netlist2Verilog.v")
  #   end

  #   it "matches the expected" do 
  #     puts "WIP"
  #   end
  # end
end