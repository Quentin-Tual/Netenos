# frozen_string_literal: true

require_relative '../lib/netenos'

describe Converter::GenRealflowTestbench do
  describe "With f51m netlists" do
    subject(:mapped_nl) {Verilog.load_netlist('tests/realflow_tb_gen/mapped_f51m.nl.v')}
    subject(:pnr_nl) {Verilog.load_netlist('tests/realflow_tb_gen/pnr_f51m.nl.v')}
    subject(:apnr_nl) {Verilog.load_netlist('tests/realflow_tb_gen/a_pnr_f51m.nl.v')}
    subject(:gen_tb) {Converter::GenRealflowTestbench.new(mapped_nl,pnr_nl,apnr_nl).gen_testbench("f51m", "tests/realflow_tb_gen/test.txt", 5, path: "tests/tmp/test_realflow_tb.v")}

    it "generates the expected testbench" do
      expect{gen_tb}.not_to raise_error
      
      expected = "tests/realflow_tb_gen/ref_test_realflow_tb.v"
      actual = "tests/tmp/test_realflow_tb.v"
      # expect(actual).to eq(expected)
      expect(FileUtils.identical?(expected, actual)).to eq(true)
    end
  end
end
