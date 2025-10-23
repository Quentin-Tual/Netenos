require_relative '../lib/netenos'

# frozen_string_literal: true

TEST_SDF_FILE='tests/sdf/test_sdf.sdf'
TEST_V_FILE='tests/sdf/test_sdf.v'

RSpec.describe SDF::Annotator do
  subject(:netlist) {Verilog.load_netlist(TEST_V_FILE)}

  context "Annotating the #{TEST_SDF_FILE} file with maximum values" do
    subject(:annotator) {SDF::Annotator.new(netlist, :max)}
    subject(:ast) {SDF::Parser.new.parse(TEST_SDF_FILE)}
    subject(:annotated_nl) {
      nl = netlist; 
      annotator_local = SDF::Annotator.new(nl, :max)
      ast.accept(annotator_local)
      nl
    } 
    subject {ast.accept(annotator)}


    it "does not raise error with Netlist::Circuit methods and DotGen" do 
      expect{
        nl = annotated_nl
        nl.getNetlistInformations(:sdf)
        nl.get_timings_hash(:sdf)
        nl.get_slack_hash
        Converter::DotGen.new.dot(nl, "tests/tmp/max_#{netlist.name}.dot", :sdf)
      }.not_to raise_error
    end

    it "returns a full connected netlist" do 
      expect(annotated_nl.all_ports_connected?).to eq(true)
    end

    it "applied a :sdf delay to each gate of the given netlist" do
      annotated_nl.components.each do |comp|
        d = comp.propag_time[:sdf]
        expect(d).not_to eq(nil) 
        expect(d).to be_kind_of(Integer)
      end
    end

    it "applied the correct delay to gates" do 
      nl = annotated_nl
      g = nl.get_component_named("_2_")
      expect(g.propag_time[:sdf]).to eq(386)
      g = nl.get_component_named("_3_")
      expect(g.propag_time[:sdf]).to eq(170)
      g = nl.get_component_named("_4_")
      expect(g.propag_time[:sdf]).to eq(170)
    end
  end

  context "Annotating the #{TEST_SDF_FILE} file with average values" do
    subject(:annotator) {SDF::Annotator.new(netlist, :avg)}
    subject(:ast) {SDF::Parser.new.parse(TEST_SDF_FILE)}
    subject {ast.accept(annotator)}
    subject(:annotated_nl) {
      nl = netlist; 
      annotator_local = SDF::Annotator.new(nl, :avg)
      ast.accept(annotator_local)
      nl
    } 

    it "does not raise error with Netlist::Circuit methods and DotGen" do 
      expect{
        nl = annotated_nl
        nl.getNetlistInformations(:sdf)
        nl.get_timings_hash(:sdf)
        nl.get_slack_hash
        Converter::DotGen.new.dot(nl, "tests/tmp/avg_#{netlist.name}.dot", :sdf)
      }.not_to raise_error
    end

    it "applied a :sdf delay to each gate of the given netlist" do
      annotated_nl.components.each do |comp|
        d = comp.propag_time[:sdf]
        expect(d).not_to eq(nil) 
        expect(d).to be_kind_of(Integer)
      end
    end

    it "applied the correct delay to gates" do 
      nl = annotated_nl
      g = nl.get_component_named("_2_")
      expect(g.propag_time[:sdf]).to eq(269)
      g = nl.get_component_named("_3_")
      expect(g.propag_time[:sdf]).to eq(138)
      g = nl.get_component_named("_4_")
      expect(g.propag_time[:sdf]).to eq(138)
    end
  end

  context "Annotating the #{TEST_SDF_FILE} file with minimum values" do
    subject(:annotator) {SDF::Annotator.new(netlist, :min)}
    subject(:ast) {SDF::Parser.new.parse(TEST_SDF_FILE)}
    subject {ast.accept(annotator)}
    subject(:annotated_nl) {
      nl = netlist; 
      annotator_local = SDF::Annotator.new(nl, :min)
      ast.accept(annotator_local)
      nl
    } 

    it "does not raise error with Netlist::Circuit methods and DotGen" do 
      expect{
        nl = annotated_nl
        nl.getNetlistInformations(:sdf)
        nl.get_timings_hash(:sdf)
        nl.get_slack_hash
        Converter::DotGen.new.dot(nl, "tests/tmp/max_#{netlist.name}.dot", :sdf)
      }.not_to raise_error
    end

    it "applied a :sdf delay to each gate of the given netlist" do
      annotated_nl.components.each do |comp|
        d = comp.propag_time[:sdf]
        expect(d).not_to eq(nil) 
        expect(d).to be_kind_of(Integer)
      end
    end

    it "applied the correct delay to gates" do 
      nl = annotated_nl
      g = nl.get_component_named("_2_")
      expect(g.propag_time[:sdf]).to eq(145)
      g = nl.get_component_named("_3_")
      expect(g.propag_time[:sdf]).to eq(73)
      g = nl.get_component_named("_4_")
      expect(g.propag_time[:sdf]).to eq(73)
    end

    it "applied a :sdf delay to each wire of the given netlist" do
      annotated_nl.wires.each do |w|
        d = w.propag_time[:sdf]
        expect(d).not_to eq(nil) 
        expect(d).to be_kind_of(Integer)
      end
    end
  end
end
