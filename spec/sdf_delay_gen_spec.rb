# frozen_string_literal: true

require_relative '../lib/netenos'
require_relative '../lib/sdf/sdf_delay_generator'
require_relative '../lib/delays'

describe SDF::DelayGenerator do
  describe "With the xor5 circuit " do
    subject(:v_filepath) {'tests/verilog/xor5_prepnr.nl.v'}
    subject(:nl) {Verilog.load_netlist(nl, v_filepath)}
    subject(:sdf_filepath) {'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'}
    subject(:ast) {SDF::Parser.new.parse(sdf_filepath)}
    subject {ast.accept(SDF::DelayGenerator.new(nl, :typ))}

    it "raises no error" do
      expect{subject}.not_to raise_error
      # expect(true).to eq(true)
    end
  end
end
