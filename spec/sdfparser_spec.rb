require_relative '../lib/netenos'

# frozen_string_literal: true

TEST_FILE='tests/sdf/test_sdf.sdf'
REF_TEST_FILE='tests/sdf/ref_test_sdf.sdf'
OBTAINED_FILE='tests/sdf/deparsed_test_sdf.sdf'

RSpec.describe SDF::Parser do

  context "Parsing then deparsing the tests/sdf/ref_test_sdf file" do
    before(:all) do
      `rm #{OBTAINED_FILE}` if File.exist?(OBTAINED_FILE)
      # Parse test_sdf file
      ast = SDF::Parser.new.parse(REF_TEST_FILE)
      # Deparse the obtained AST
      deparser = SDF::Deparser.new(OBTAINED_FILE)
      ast.accept(deparser)
    end

    it "Valid SDF matches the parsed then deparsed file" do
      # Read test_sdf file
      expected = File.read(REF_TEST_FILE)
      # Read obtained file
      obtained = File.read(OBTAINED_FILE)
      expect(obtained).to eq(expected)
    end
  end

  context "with test_sdf SDF file" do
    # Subject is the SDF AST obtained
    subject(:ast) {SDF::Parser.new.parse(TEST_FILE)}
    subject(:delayfile) {ast.subnodes.first}
    subject(:design) {delayfile.design}
    subject(:timescale) {delayfile.timescale}
    subject(:cells) {delayfile.cells}
    subject(:test_sdf_cell) {delayfile.cells.find{|n| n.instance.data.name == ""}}
    subject(:test_sdf_delay) {test_sdf_cell.delay}
    subject(:test_sdf_interconnects) {test_sdf_delay.absolute.interconnects}

    it "returns a valid Root object" do
      expect(ast).to be_kind_of(SDF::Root)
      expect(ast).to be_valid
      expect(ast.name).to eq(TEST_FILE)
    end
    
    # !!! USE be_valid KEYWORD FOR CLARITY AND EFFICIENCY (CALLS valid? METHOD ON TESTED OBJECT)
    
    it "extracted required data from DELAYFILE" do
      expect(delayfile).not_to eq(nil)
      expect(delayfile).to be_valid
    end

    it "extracted the design name from DESIGN" do 
      expect(design).not_to eq(nil)
      expect(design.data).to eq("test_sdf")
    end

    it "extracted the TIMESCALE" do
      expect(timescale).not_to eq(nil)
      expect(timescale.data).to be_kind_of(SDF::Time)
      expect(timescale.data.val).to eq("1ns")
    end 
    
    it "extracted CELLs" do
      expect(cells).not_to be_empty
      expect(cells.length).to eq(4) 
    end

    it "extracted test_sdf CELL" do 
      expect(test_sdf_cell).not_to eq(nil) 
      expect(test_sdf_cell.celltype.data.name).to eq("\"test_sdf\"")
      expect(test_sdf_cell.instance.data.name).to eq("")
    end

    it "extracted test_sdf DELAY" do
      expect(test_sdf_delay).not_to eq(nil)
      expect(test_sdf_delay).to be_valid
      
      absolute_n = test_sdf_delay.absolute
      expect(absolute_n).not_to eq(nil)
      expect(absolute_n).to be_valid
    end 

    it "extracted test_sdf INTERCONNECTs" do
      expect(test_sdf_interconnects).not_to be_empty
      expect(test_sdf_interconnects.length).to eq(8)
      # Use a be_valid statement calling valid? method in a loop
      # valid? should check if source, sink and time values are not empty
      # and also check if values are indicated for rise/fall and min/typ/max
      
      # Check the values for two line

    end

  end
end
