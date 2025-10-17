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

    # it "generates the right amount of IOs" do
    #   expect(subject.ports[:in].length).to eq(5) # Thus not empty
    #   expect(subject.ports[:out].length).to eq(1) # Thus not empty
    # end

    # it "generates the right amount of standard cells" do
    #   expect(subject.components.length).to eq(4)
    # end

    # it "extracted standard cells name" do 
    #   stdcells_list = subject.components
    #   stdcells_names = stdcells_list.collect{|c| c.class.name.split("::").last.downcase}
    #   expect(stdcells_names).to include("sky130_fd_sc_hd__xor2_2")
    #   expect(stdcells_names.count("sky130_fd_sc_hd__xor2_2")).to eq(2)
    #   expect(stdcells_names).to include("sky130_fd_sc_hd__xnor2_2")
    #   expect(stdcells_names.count("sky130_fd_sc_hd__xnor2_2")).to eq(2)
    # end

    # it "named each stdcell instance name" do
    #   instance_names = (3..6).collect{|i| "_#{i}_"}

    #   instance_names.each do |inst_name|
    #     expect(subject.components.collect{|c| c.name}).to include(inst_name)
    #   end
    # end

    # it "generates the right amount of standard wires" do
    #   expect(subject.wires.length).to eq(3)
    # end

    # it "extracted each wire name" do 
    #   w_names = (0..2).collect{|i| "_#{i}_"}

    #   w_names.each do |w_name|
    #     expect(subject.wires.collect{|w| w.name}).to include(w_name)
    #   end
    # end

  end
end