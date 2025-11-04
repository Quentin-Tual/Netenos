# frozen_string_literal: true

require_relative '../lib/netenos'

describe AtetaAddOn::Ateta do
  TEST_SDF_FILE='tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'
  TEST_V_FILE='tests/verilog/xor5_prepnr.nl.v'
  DELAY_MODEL=:sdf
  SIMPLIFIER_FUN=:max
  
  NETLIST = Verilog.load_netlist(TEST_V_FILE)
  SDF.annotate(NETLIST,TEST_SDF_FILE)
  
  NETLIST.getNetlistInformations(DELAY_MODEL)
  timings_h = NETLIST.get_timings_hash(DELAY_MODEL)
  precedence_grid = NETLIST.get_netlist_precedence_grid

  subject(:delay_model) {:sdf}
  subject(:nl) {NETLIST}
  subject(:payload_delay) {nl.get_comp_min_delay(delay_model)}

  context "used on a Verilog parsed netlist with SDF annotation" do
    subject(:ateta) {AtetaAddOn::Ateta.new(nl,payload_delay,delay_model)}
    subject(:generate) {ateta.generate_stim}

    it "does not raise errors" do
      expect{generate}.not_to raise_error
    end
  end
end
