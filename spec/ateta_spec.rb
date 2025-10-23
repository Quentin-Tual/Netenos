# frozen_string_literal: true

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

  subject(:nl) {NETLIST}
  context "used on a Verilog parsed netlist with SDF annotation" do
    it "does not raise errors" do
      
    end
  end
end
