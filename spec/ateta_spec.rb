# frozen_string_literal: true

require_relative '../lib/netenos'

describe AtetaAddOn::Ateta do
  TEST_SDF_FILE='tests/sdf/f51m__nom_tt_025C_1v80.sdf'
  TEST_V_FILE='tests/verilog/f51m.nl.v'
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
  subject(:tvps_save_path) {'tests/tmp/test_ateta.stim'}

  context "used on a Verilog parsed netlist with SDF annotation" do
    subject(:ateta) {AtetaAddOn::Ateta.new(nl,payload_delay,delay_model)}
    subject(:generate) {ateta.generate_stim}
    subject(:save_tvps) {ateta.save_explicit(tvps_save_path)}

    before :example do 
      `rm tmp.smt` if File.exist?('tmp.smt')
      `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
    end

    after :example do 
      `rm tmp.smt` if File.exist?('tmp.smt')
      `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
    end

    it "does not raise errors" do
      expect{generate}.not_to raise_error
    end

    it "generates test vectors" do
      generate 
      save_tvps
      expect(File.exist?('tmp.smt')).to eq(true)
      expect(File.exist?(tvps_save_path))
    end

    it "has no unobservable risky signal" do 
      uut = ateta
      uut.generate_stim
      expect(uut.unobservables).to be_empty 
    end
  end
end
