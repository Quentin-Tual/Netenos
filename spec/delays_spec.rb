# frozen_string_literal: true

require_relative '../lib/netenos'
require_relative '../lib/delays'

describe Netlist::GetDelaysVisitor do
  describe "For the circuit xor5" do
    subject(:test_v_file) {'tests/verilog/xor5_prepnr.nl.v'}
    subject(:nl) {Verilog.load_netlist(test_v_file)}
    
    context "with one unit delay model" do
      subject(:dly_mdl) {Delays::OneUnitDelays}

      context "without wire delays" do 
        subject(:uut) {Netlist::GetDelaysVisitor.new(dly_mdl)}
        subject(:res) {nl.accept(uut)}
        it "raises no error" do
          expect{res}.not_to raise_error
        end

        it "associates a delays of 1 to each gate and each wire" do
          expect(res).to be_valid
          objects_timed = Set.new(res.delays.keys)
          all_objects = Set.new(nl.components)
          expect(objects_timed).to eq(all_objects)
        end
      end

      context "with wire delays" do 
        subject(:uut) {Netlist::GetDelaysVisitor.new(dly_mdl, wire_delays: true)}
        subject(:res) {nl.accept(uut)}
        it "raises no error" do
          expect{res}.not_to raise_error
        end

        it "associates a delays of 1 to each gate and each wire" do
          expect(res).to be_valid
          objects_timed = Set.new(res.delays.keys)
          all_objects = Set.new(nl.components + nl.wires)
          expect(objects_timed).to eq(all_objects)
        end
      end
    end
  end
end
