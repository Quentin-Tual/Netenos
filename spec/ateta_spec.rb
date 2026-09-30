# frozen_string_literal: true

require_relative '../lib/netenos'

describe AtetaAddOn::Ateta do
  smt_path = '/tmp/Netenos/htpg_smt'

  test_v_file = 'tests/verilog/f51m.nl.v'
  nl = Verilog.load_netlist(test_v_file)
  test_sdf_file = 'tests/sdf/f51m__nom_tt_025C_1v80.sdf'
  SDF.annotate(nl, test_sdf_file)

  delay_model = :sdf
  nl.getNetlistInformations(delay_model)
  nl.get_timings_hash(delay_model)
  nl.get_netlist_precedence_grid

  subject(:payload_delay) { nl.get_comp_min_delay(delay_model) }

  subject(:ateta) { AtetaAddOn::Ateta.new(nl, payload_delay, delay_model) }
  subject(:save_tvps) { ateta.save_explicit(tvps_save_path) }
  subject(:save_bin_tvps) { Converter::GenStim.new(nl).save_vec_list(bin_tvps_save_path, generate, bin_stim_vec: true) }
  # subject(:smt_path) {'/tmp/Netenos/htpg_smt'}

  context 'used on a Verilog parsed netlist with SDF annotation' do
    subject(:tvps_save_path) { 'tests/tmp/test_ateta.stim' }
    subject(:bin_tvps_save_path) { 'tests/tmp/test_bin_ateta.stim' }
    subject(:generate) { ateta.generate_stim }

    # before :example do
    #   `rm tmp.smt` if File.exist?('tmp.smt')
    #   `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
    # end

    # after :all do
    #   `rm tmp.smt` if File.exist?('tmp.smt')
    #   # `rm -r #{smt_path}` if Dir.exist?(smt_path)
    #   `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
    # end

    it 'does not raise errors' do
      expect { generate }.not_to raise_error
    end

    it 'generates test vectors' do
      generate
      save_tvps
      expect(Dir.exist?(smt_path)).to eq(true)
      expect(Dir.empty?(smt_path)).to eq(false)
      expect(File.exist?(tvps_save_path))
    end

    it 'has no unobservable risky signal' do
      uut = ateta
      uut.generate_stim
      expect(uut.unobservables).to be_empty
    end
  end

  # context 'Use to generate glitches on a Verilog netlist annotated with a SDF file' do
  #   subject(:tvps_save_path) { 'tests/tmp/test_ateta_glitch.stim' }
  #   subject(:bin_tvps_save_path) { 'tests/tmp/test_bin_ateta_glitch.stim' }
  #   subject(:generate) { ateta.generate_glitch_stim }
  #   # subject(:smt_path) {'/tmp/Netenos/htpg_smt'}

  #   before :example do
  #     `rm -r #{smt_path}` if File.exist?(smt_path)
  #     # `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
  #   end

  #   after :example do
  #     `rm tmp.smt` if File.exist?('tmp.smt')
  #     # `rm -r #{smt_path}` if Dir.exist?(smt_path)
  #   end

  #   it 'does not raise errors' do
  #     expect { generate }.not_to raise_error
  #   end

  #   it 'generates test vectors' do
  #     generate
  #     save_tvps
  #     save_bin_tvps
  #     expect(Dir.exist?(smt_path)).to eq(true)
  #     expect(Dir.empty?(smt_path)).to eq(false)
  #     expect(File.exist?(tvps_save_path))
  #   end

  #   it 'has no unobservable risky signal' do
  #     uut = ateta
  #     uut.generate_stim
  #     expect(uut.unobservables).to be_empty
  #   end
  # end

  # context 'Use to generate anomalies with a maximized length on a Verilog netlist annotated with a SDF file' do
  #   subject(:tvps_save_path) { 'tests/tmp/test_ateta_max.stim' }
  #   subject(:bin_tvps_save_path) { 'tests/tmp/test_bin_ateta_max.stim' }
  #   subject(:generate) { ateta.generate_maximized_stim }
  #   # subject(:smt_path) {'/tmp/Netenos/htpg_smt'}

  #   before :example do
  #     `rm -r #{smt_path}` if File.exist?(smt_path)
  #     # `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
  #   end

  #   after :example do
  #     `rm tmp.smt` if File.exist?('tmp.smt')
  #     # `rm -r #{smt_path}` if Dir.exist?(smt_path)
  #   end

  #   it 'does not raise errors' do
  #     expect { generate }.not_to raise_error
  #   end

  #   it 'generates test vectors' do
  #     generate
  #     save_tvps
  #     save_bin_tvps
  #     expect(Dir.exist?(smt_path)).to eq(true)
  #     expect(Dir.empty?(smt_path)).to eq(false)
  #     expect(File.exist?(tvps_save_path))
  #   end

  #   it 'has no unobservable risky signal' do
  #     uut = ateta
  #     uut.generate_stim
  #     expect(uut.unobservables).to be_empty
  #   end
  # end
end
