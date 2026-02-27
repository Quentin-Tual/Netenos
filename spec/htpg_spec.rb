# frozen_string_literal: true

require_relative '../lib/netenos'

describe AtetaAddOn::Htpg do
  # TEST_SDF_FILE='tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'
  # TEST_V_FILE='tests/verilog/xor5_prepnr.nl.v'
  delay_model = :sdf
  smt_path = '/tmp/Netenos/htpg_smt'

  testfiles = [
    ['tests/verilog/xor5_prepnr.nl.v',  'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf']#,
    # ['tests/verilog/f51m.nl.v',         'tests/sdf/f51m__nom_tt_025C_1v80.sdf']
  ]
  testfiles.each do |v_file, sdf_file|
    context "HTPG applied on LGSynth91/xor5 Verilog netlist with SDF annotation" do
      subject(:nl) {nl = Verilog.load_netlist(v_file); SDF.annotate(nl, sdf_file); nl}
      subject(:dly_db) {SDF.generate_dly_db(nl, sdf_file)}
      subject(:payload_delay) {nl.get_comp_min_delay(:sdf, dly_db: dly_db)}
      subject(:htpg) {AtetaAddOn::Htpg.new(nl,payload_delay,dly_db)}
      subject(:save_tvps) {htpg.save_explicit(tvps_save_path)}
      subject(:save_bin_tvps) {Converter::GenStim.new(nl).save_vec_list(bin_tvps_save_path, generate, bin_stim_vec: true)}

      subject(:tvps_save_path) {'tests/tmp/test_htpg.stim'}
      subject(:bin_tvps_save_path) {'tests/tmp/test_bin_htpg.stim'}
      subject(:generate) {htpg.generate_stim}

      before :example do 
        `rm tmp.smt` if File.exist?('tmp.smt')
        `rm -r #{smt_path}` if Dir.exist?(smt_path)
        `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
      end

      # after :all do 
      #   `rm tmp.smt` if File.exist?('tmp.smt')
      #   `rm -r #{SMT_PATH}` if Dir.exist?(SMT_PATH)
      #   `rm #{TVPS_SAVE_PATH}` if File.exist?(TVPS_SAVE_PATH)
      # end

      it "does not raise errors" do
        expect{
          uut = htpg
          uut.generate_stim
          uut.save_explicit(tvps_save_path, binStimVec: true)
        }.not_to raise_error
      end

      # it "has no unobservable risky signal" do 
      #   uut = htpg
      #   uut.generate_stim
      #   expect(uut.unobservables).to be_empty 
      # end

      # it "generates test vectors" do
      #   uut = htpg
      #   uut.generate_stim
      #   uut.save_explicit(tvps_save_path)
      #   expect(Dir.exist?(smt_path)).to eq(true)
      #   expect(Dir.empty?(smt_path)).to eq(false)
      #   expect(File.exist?(tvps_save_path))
      # end
    end
  end

  # context "Use to generate glitches on a Verilog netlist annotated with a SDF file" do
  #   subject(:tvps_save_path) {'tests/tmp/test_ateta_glitch.stim'}
  #   subject(:bin_tvps_save_path) {'tests/tmp/test_bin_ateta_glitch.stim'}
  #   subject(:generate) {ateta.generate_glitch_stim}
  #   # subject(:smt_path) {'/tmp/Netenos/htpg_smt'}

  #   before :example do 
  #     `rm -r #{SMT_PATH}` if File.exist?(SMT_PATH)
  #     # `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
  #   end

  #   after :example do 
  #     `rm tmp.smt` if File.exist?('tmp.smt')
  #     if Dir.exist?(SMT_PATH)
  #       `rm -r #{SMT_PATH}`
  #     end
  #   end

  #   it "does not raise errors" do
  #     expect{generate}.not_to raise_error
  #   end

  #   it "generates test vectors" do
  #     generate 
  #     save_tvps
  #     save_bin_tvps
  #     expect(Dir.exist?(SMT_PATH)).to eq(true)
  #     expect(Dir.empty?(SMT_PATH)).to eq(false)
  #     expect(File.exist?(tvps_save_path))
  #   end

  #   it "has no unobservable risky signal" do 
  #     uut = ateta
  #     uut.generate_stim
  #     expect(uut.unobservables).to be_empty 
  #   end
  # end

  # context "Use to generate anomalies with a maximized length on a Verilog netlist annotated with a SDF file" do
  #   subject(:tvps_save_path) {'tests/tmp/test_ateta_max.stim'}
  #   subject(:bin_tvps_save_path) {'tests/tmp/test_bin_ateta_max.stim'}
  #   subject(:generate) {ateta.generate_maximized_stim}
  #   # subject(:smt_path) {'/tmp/Netenos/htpg_smt'}

  #   before :example do 
  #     `rm -r #{SMT_PATH}` if File.exist?(SMT_PATH)
  #     # `rm #{tvps_save_path}` if File.exist?(tvps_save_path)
  #   end

  #    after :example do 
  #     `rm tmp.smt` if File.exist?('tmp.smt')
  #     if Dir.exist?(SMT_PATH)
  #       `rm -r #{SMT_PATH}`
  #     end
  #   end

  #   it "does not raise errors" do
  #     expect{generate}.not_to raise_error
  #   end

  #   it "generates test vectors" do
  #     generate 
  #     save_tvps
  #     save_bin_tvps
  #     expect(Dir.exist?(SMT_PATH)).to eq(true)
  #     expect(Dir.empty?(SMT_PATH)).to eq(false)
  #     expect(File.exist?(tvps_save_path))
  #   end

  #   it "has no unobservable risky signal" do 
  #     uut = ateta
  #     uut.generate_stim
  #     expect(uut.unobservables).to be_empty 
  #   end
  # end
end
