# frozen_string_literal: true

require_relative '../lib/netenos'

describe AtetaAddOn::Htpg do
  # TEST_SDF_FILE='tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'
  # TEST_V_FILE='tests/verilog/xor5_prepnr.nl.v'
  # delay_model = :sdf
  # asp_path = '/tmp/Netenos/htpg_smt'

  testfiles = [
    ['tests/verilog/pnr_pedagoExample.v', 'tests/sdf/pnr_pedagoExample.sdf']
    # ['tests/verilog/xor5_prepnr.nl.v', 'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf']
    # ['tests/verilog/f51m.nl.v', 'tests/sdf/f51m__nom_tt_025C_1v80.sdf']
  ]
  testfiles.each do |v_file, sdf_file|
    context "HTPG applied through ASP solving on #{v_file} Verilog netlist with #{sdf_file} SDF annotation" do
      subject(:nl) do
        nl = Verilog.load_netlist(v_file)
        SDF.annotate(nl, sdf_file)
        nl
      end
      subject(:dly_db) { SDF.generate_dly_db(nl, sdf_file) }
      subject(:payload_delay) { nl.get_comp_min_delay(:sdf, dly_db: dly_db) }
      # subject(:save_tvps) {htpg.save_explicit(tvps_save_path)}
      # subject(:save_bin_tvps) {Converter::GenStim.new(nl).save_vec_list(bin_tvps_save_path, generate, bin_stim_vec: true)}

      subject(:tvps_save_path) { 'tests/tmp/test_htpg_asp.stim' }
      subject(:bin_tvps_save_path) { 'tests/tmp/test_bin_htpg_asp.stim' }
      subject(:htpg_time_report) { 'tests/tmp/' }

      subject(:htpg) { AtetaAddOn::Htpg.new(nl, payload_delay, dly_db, smt_format: :simple, asp: true) }
      # subject(:generate) {htpg.generate_stim}

      # before :example do
      #   `rm tmp.smt` if File.exist?('tmp.smt')
      #   `rm -r #{smt_path}` if Dir.exist?(smt_path)
      #   `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
      # end

      it 'does not raise errors' do
        expect do
          uut = htpg
          uut.generate_stim
          `mv htpg_time_report.txt #{htpg_time_report}`
          uut.save_explicit(tvps_save_path, binStimVec: true)
        end.not_to raise_error
      end
    end
  end
end
