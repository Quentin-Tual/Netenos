# frozen_string_literal: true

require_relative '../lib/netenos'
require_relative '../lib/librelane'
require_relative 'support/pipeline_fixture'

# FileUtils.rm_r('tests/tmp/librelane_env') if Dir.exist?('tests/tmp/librelane_env')

describe Librelane::LibrelaneEnv do
  let(:blif) { '/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/C17.blif' }
  let(:circ_name) { 'C17' }
  let(:config) { Librelane::LibrelaneConfig.new(blif, 100) }
  let(:tmp_dir) { Pathname.new('tests/tmp') }
  let(:pnr) { PipelineFixture.pnr }
  let(:apnr) { PipelineFixture.apnr }
  let(:sim_all) { PipelineFixture.sim }
  subject(:env) { Librelane::LibrelaneEnv.new(config, tmp_dir.to_s) }

  it 'finds existing required installation (nix librelane, ciel and sky130 pdk in it, yosys-abc)' do
    env
  end

  it 'synthetize correctly a given blif file' do
    env.synth_only(blif)
    expect(env.layout.env_dir / 'synth/C17.v').to exist
  end

  it 'place and route' do
    # subject.synth_n_pnr(blif)
    expect(pnr[:env].layout.runs_dir).not_to be_empty

    # ! Terminer la réécriture
    # last_run = `ls -t tests/tmp/librelane_env/librelane/runs | head -1 | tr -d '\n'`
    # expect(Dir.exist?("tests/tmp/librelane_env/librelane/runs/#{last_run}/final")).to eq(true)
    # expect(File.empty?("tests/tmp/librelane_env/librelane/runs/#{last_run}/error.log")).to eq(true)
  end

  it 'saves pnr files in made directory' do
    # Ligne suivante exécutée ce test est lancé seul, sinon les autres tests auront déjà généré ces fichiers.
    expect(pnr[:env].layout.made_dir(circ_name)).to exist
    expect(pnr[:env].layout.pnr_v(circ_name)).to exist
    expect(pnr[:env].layout.pnr_sdf(circ_name)).to exist
  end

  # context 'buffer insertion' do
  #   let(:shared) { PnrFixture.run }
  #   let(:copy_base) { Pathname(Dir.mktmpdir('rspec_apnr_C17')) }
  #   let(:env) do
  #     FileUtils.cp_r(
  #       pnr[:env].layout.env_dir,
  #       copy_base / 'librelane_env',
  #       preserve: true
  #     )
  #     described_class.new(config, copy_base, circ_name: circ_name)
  #   end

  #   it 'allows to insert a buffer to a pnr design then reroute and finalize design' do
  #     apnr_variants = env.layout.apnr_variants(circ_name)
  #     apnr_variants.each do |apnr_path|
  #       sig_name = apnr_path.split('_apnr_').last
  #       sig_name[sig_name.rindex('_')] = '/'
  #       env.insert_buf_and_finalize(sig_name)
  #       expect(apnr_path / '.v').to exist
  #       expect(apnr_path / '.sdf').to exist
  #     end
  #     # expect(File.exist?('tests/tmp/librelane_env/made/C17/C17_apnr__2__A1.v')).to eq(true)
  #     # expect(File.exist?('tests/tmp/librelane_env/made/C17/C17_apnr__2__A1.sdf')).to eq(true)
  #   end

  #   it 'generates an ATETA test stimulus file' do
  #     stim_path = env.gen_ateta_stim(circ_name)

  #     # Verify the output file exists and contains expected content
  #     expect(stim_path).to eq(env.layout.stim(circ_name))
  #     expect(env.layout.stim(circ_name)).to exist
  #   end
  # end

  describe 'buffer insertion', :pnr do
    let(:circ_name) { apnr[:env].circ_name }
    let(:layout) { apnr[:env].layout }

    it 'creates the altered netlist and sdf for all risky signals' do
      layout.apnr_variants(circ_name).each do |apnr_path|
        expect(apnr_path.sub_ext('.v')).to exist
        expect(apnr_path.sub_ext('.sdf')).to exist
      end
    end
  end

  describe '#gen_ateta_stim', :pnr do
    let(:copy) { PipelineFixture.fresh_copy } # copie du PnR seul : bien moins cher qu'un PnR
    after { FileUtils.rm_rf(copy[:dir]) }

    it 'generates an ATETA test stimulus file' do
      stim_path = copy[:env].gen_ateta_stim(circ_name)

      expect(Pathname(stim_path)).to eq(copy[:env].layout.stim(circ_name))
      expect(Pathname(stim_path)).to exist
    end
  end

  describe '#sim_all_apnr', :questa do
    # let(:env) { described_class.new }
    # let(:test_path) { 'tests/tmp/librelane_env/made/f51m/f51m.stim' }
    # let(:blif) { '/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/f51m.blif' }
    # let(:pnr) { PipelineFixture.pnr }
    # let(:sim_params) do
    #   Librelane::SimParams.new(
    #     subject.gen_ateta_stim(circ_name),
    #     pnr[:env].layout.tb(circ_name),
    #     10,
    #     full_traces: true
    #   )
    # end
    # # let(:sim_outputs) { Librelane::SimOutputs.new()}
    # let(:sim_config) { Librelane::SimConfig.new(pnr[:files], nil, sim_params, nil) }

    # before do
    #   # subject.synth_n_pnr(test_blif) unless Dir.exist?('tests/tmp/librelane_env')
    #   subject.gen_ateta_stim # unless File.exist?('tests/tmp/librelane_env/made/C17/C17.stim')
    # end
    let(:circ_name) { sim_all[:env].circ_name }
    let(:layout) { sim_all[:env].layout }

    it 'simulates all alterated versions of a given pnr circuit' do
      # sim_all[:env].sim_all_apnr2(sim_config)

      layout.apnr_variants(circ_name).each do |apnr_path|
        expect(apnr_path).to exist
        expect(apnr_path / 'activity_pnr1Xapnr.log').to exist
        expect(apnr_path / 'activity_pnr1Xapnr.log.data').to exist
        expect(apnr_path / 'activity_pnr1Xapnr.log_filtered.data').to exist
        expect(apnr_path / "tb_#{circ_name}_pnr1Xapnr.vcd").to exist
      end
    end
  end

  # describe '#get_last_run_path' do

  it 'returns the valid last run path' do
    expect(pnr[:env].get_last_run_path).to exist
  end
  # end

  # ## Test validé en inversant l'ordre des valeurs FP_CORE_UTIL_VALUES dans la classe LibrelaneEnv,
  # describe 'place and route through multiple try' do
  #   # let(:test_blif_path) do
  #   #   '/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/C17.blif'
  #   # end
  #   it 'varying the value of fp_core_util' do
  #     expect { subject.synth_n_pnr(test_blif) }.not_to raise_error
  #     # On s'attend à ce que le paramètre FP_CORE_UTIL dans le fichier de config librelane du dernier run soit différent de 1 (par défaut la première valeur à être testée)
  #     # config = JSON.parse('tests/tmp/librelane_env/librelane/config.json')
  #     config = JSON.load_file('tests/tmp/librelane_env/librelane/config.json')
  #     fp_core_util = config['FP_CORE_UTIL']
  #     expect(fp_core_util).not_to eq(Librelane::LibrelaneEnv::FP_CORE_UTIL_VALUES.first)
  #     # On s'attend à ce que le fichier error.log soit vide
  #     last_run_path = subject.get_last_run_path
  #     error_log_path = "#{last_run_path}/error.log"
  #     expect(File.file?(error_log_path)).to eq(true)
  #     expect(File.empty?(error_log_path)).to eq(true)
  #   end
  # end
end
