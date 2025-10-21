require_relative '../lib/netenos'

# frozen_string_literal: true

TEST_SDF_FILE='tests/sdf/test_sdf.sdf'
TEST_V_FILE='tests/sdf/test_sdf.v'

# Load netlist
NETLIST = Verilog.load_netlist(TEST_V_FILE)

RSpec.describe SDF::Annotator do

  context "Annotating the #{TEST_SDF_FILE} file with maximum values" do

    subject(:annotator) {SDF::Annotator.new(NETLIST, :max)}
    subject(:ast) {SDF::Parser.new.parse(TEST_SDF_FILE)}
    subject {ast.accept(annotator)}

    it "does not raise error with Netlist::Circuit methods and DotGen" do 
      expect{
        ast.accept(annotator)
        NETLIST.getNetlistInformations(:sdf)
        NETLIST.get_timings_hash(:sdf)
        NETLIST.get_slack_hash
        Converter::DotGen.new.dot(NETLIST, "tests/tmp/max_#{NETLIST.name}.dot", :sdf)
      }.not_to raise_error
    end

    it "applied a :sdf delay to each gate of the given netlist" do
      NETLIST.components.each do |comp|
        d = comp.propag_time[:sdf]
        expect(d).not_to eq(nil) 
        expect(d).to be_kind_of(Integer)
      end
    end

    it "applied the correct delay to gates" do 
      g = NETLIST.get_component_named("_2_")
      expect(g.propag_time[:sdf]).to eq(386)
      g = NETLIST.get_component_named("_3_")
      expect(g.propag_time[:sdf]).to eq(170)
      g = NETLIST.get_component_named("_4_")
      expect(g.propag_time[:sdf]).to eq(170)
    end
  end

  context "Annotating the #{TEST_SDF_FILE} file with average values" do
    subject(:annotator) {SDF::Annotator.new(NETLIST, :avg)}
    subject(:ast) {SDF::Parser.new.parse(TEST_SDF_FILE)}
    subject {ast.accept(annotator)}

    it "does not raise error with Netlist::Circuit methods and DotGen" do 
      expect{
        ast.accept(annotator)
        NETLIST.getNetlistInformations(:sdf)
        NETLIST.get_timings_hash(:sdf)
        NETLIST.get_slack_hash
        Converter::DotGen.new.dot(NETLIST, "tests/tmp/avg_#{NETLIST.name}.dot", :sdf)
      }.not_to raise_error
    end

    it "applied a :sdf delay to each gate of the given netlist" do
      NETLIST.components.each do |comp|
        d = comp.propag_time[:sdf]
        expect(d).not_to eq(nil) 
        expect(d).to be_kind_of(Integer)
      end
    end

    it "applied the correct delay to gates" do 
      g = NETLIST.get_component_named("_2_")
      expect(g.propag_time[:sdf]).to eq(269)
      g = NETLIST.get_component_named("_3_")
      expect(g.propag_time[:sdf]).to eq(138)
      g = NETLIST.get_component_named("_4_")
      expect(g.propag_time[:sdf]).to eq(138)
    end
  end

  context "Annotating the #{TEST_SDF_FILE} file with minimum values" do
    subject(:annotator) {SDF::Annotator.new(NETLIST, :min)}
    subject(:ast) {SDF::Parser.new.parse(TEST_SDF_FILE)}
    subject {ast.accept(annotator)}

    it "does not raise error with Netlist::Circuit methods and DotGen" do 
      expect{
        ast.accept(annotator)
        NETLIST.getNetlistInformations(:sdf)
        NETLIST.get_timings_hash(:sdf)
        NETLIST.get_slack_hash
        Converter::DotGen.new.dot(NETLIST, "tests/tmp/min_#{NETLIST.name}.dot", :sdf)
      }.not_to raise_error
    end

    it "applied a :sdf delay to each gate of the given netlist" do
      NETLIST.components.each do |comp|
        d = comp.propag_time[:sdf]
        expect(d).not_to eq(nil) 
        expect(d).to be_kind_of(Integer)
      end
    end

    it "applied the correct delay to gates" do 
      g = NETLIST.get_component_named("_2_")
      expect(g.propag_time[:sdf]).to eq(145)
      g = NETLIST.get_component_named("_3_")
      expect(g.propag_time[:sdf]).to eq(73)
      g = NETLIST.get_component_named("_4_")
      expect(g.propag_time[:sdf]).to eq(73)
    end

  end
end
