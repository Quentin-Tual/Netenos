# frozen_string_literal: true

require_relative '../lib/netenos'
require_relative '../lib/sdf/sdf_delay_generator'
require_relative '../lib/delays'

describe SDF::DelayGenerator do
  describe "With the xor5 circuit " do
    subject(:v_filepath) {'tests/verilog/xor5_prepnr.nl.v'}
    subject(:nl) {Verilog.load_netlist(v_filepath)}
    subject(:sdf_filepath) {'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'}
    subject(:ast) {SDF::Parser.new.parse(sdf_filepath)}
    subject {ast.accept(SDF::DelayGenerator.new(nl, :typ))}

    it "raises no error" do
      expect{subject}.not_to raise_error
    end

    # Check if the values are valid
    it "returns a valid object" do
      expect(subject).to be_valid
    end

    # Check if the values match the SDF file
    
    # Check if the methods of the SDFDelays object works correctly
    it "allows to retrieve wire delay" do
      w = nl.wires.first
      expect(subject.get_wire_dly(w,:rise,:typ)).to eq(32)
    end

    it "allows to retrieve gate delays" do
      g = nl.components.first
      input = g.get_inputs.first.get_full_name
      output = g.get_output.get_full_name
      ioarc = [input,output]
      dly = subject.get_gate_dly(
        g,
        ioarc, 
        :rise,
        :typ)
      expect(dly).to eq(157)
    end
  end
end
