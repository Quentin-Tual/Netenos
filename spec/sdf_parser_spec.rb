require_relative '../lib/netenos'

# frozen_string_literal: true

RSpec.describe SDF::Parser do

  subject(:test_file) {'tests/sdf/test_sdf.sdf'}
  subject(:ref_test_file) {'tests/sdf/ref_test_sdf.sdf'}
  subject(:obtained_file) {'tests/tmp/deparsed_test_sdf.sdf'}
  subject(:parse_deparse) {
    `rm #{obtained_file}` if File.exist?(obtained_file)
    # Parse test_sdf file
    ast = SDF::Parser.new.parse(ref_test_file)
    # Deparse the obtained AST
    deparser = SDF::Deparser.new(obtained_file)
    ast.accept(deparser)
  }

  context "Parsing then deparsing the tests/sdf/ref_test_sdf.sdf file" do

    it "Valid SDF matches the parsed then deparsed file" do
      # Read test_sdf file
      expected = File.read(ref_test_file)
      parse_deparse
      # Read obtained file
      obtained = File.read(obtained_file)
      expect(obtained).to eq(expected)
    end
  end

  context "Parsing tests/sdf/test_sdf.sdf file" do
    # Subject is the SDF AST obtained
    subject(:ast) {SDF::Parser.new.parse(test_file)}
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
      expect(ast.name).to eq(test_file)
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
      expect(test_sdf_cell.celltype.data).to eq("test_sdf")
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

    # Note : Not finished but the comparison between expected reference and obtained parsed deparsed files is enough 

  end
end
