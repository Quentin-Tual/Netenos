require_relative '../lib/netenos'

# frozen_string_literal: true


RSpec.describe Inserter::Tamperer do
  TEST_SDF_FILE='tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'
  TEST_V_FILE='tests/verilog/xor5_prepnr.nl.v'
  DELAY_MODEL=:sdf
  SIMPLIFIER_FUN=:max
  
  NETLIST = Verilog.load_netlist(TEST_V_FILE)
  SDF.annotate(NETLIST,TEST_SDF_FILE)
  
  NETLIST.getNetlistInformations(DELAY_MODEL)
  timings_h = NETLIST.get_timings_hash(DELAY_MODEL)
  precedence_grid = NETLIST.get_netlist_precedence_grid

  subject(:netlist) {NETLIST}
  
  context "Using Sky130_Tbuffer HT to tamper" do 
    subject(:alt_nl) {
      to_alter_nl = NETLIST.deep_copy
      attacker = Inserter::Tamperer.new(to_alter_nl,precedence_grid,timings_h, DELAY_MODEL)
      min_delay = to_alter_nl.get_comp_min_delay(DELAY_MODEL)
      insertion_points = to_alter_nl.get_insertion_points(min_delay)
      loc = insertion_points.first
      # delay_h = {sdf: min_delay}
      attacker.insert_sky130_buffer_at(loc, min_delay).add_wires
      to_alter_nl
    }
  
    context "a Verilog parsed netlist from #{TEST_V_FILE} annotated with the SDF file #{TEST_SDF_FILE}" do
      it "does not raise errors" do
        expect{alt_nl}.not_to raise_error
      end

      it "gives a valid altered netlist" do
        expect(alt_nl).to be_valid
      end 

      it "contains gates tagged as HT" do 
        expect(alt_nl.components.any?{|comp| comp.tag == :ht}).to eq(true)
      end
      
      it "inserted gates all have a delay" do
        ht_gates = alt_nl.components.select{|comp| comp.tag == :ht}
        expect(ht_gates.none?{|g| g.propag_time[DELAY_MODEL].nil?}).to eq(true)
      end

      it "does not raise errors with usual methods" do
        expect{
          uut = alt_nl
          uut.getNetlistInformations(DELAY_MODEL)
          uut.get_timings_hash(DELAY_MODEL)
          uut.get_netlist_precedence_grid
          uut.get_slack_hash
        }.not_to raise_error
      end

      it "does not raise errors with DotGen after insertion" do
        expect{
          uut = alt_nl
          uut.getNetlistInformations(DELAY_MODEL)
          Converter::DotGen.new.dot(
            uut, 
            "tests/tmp/test_ht_insertion.dot", 
            DELAY_MODEL
          )
        }.not_to raise_error
      end
    end
  end
end
