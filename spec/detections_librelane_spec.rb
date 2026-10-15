# frozen_string_literal: true

require_relative '../lib/netenos'
require_relative '../lib/librelane/detections_lblane'
require_relative 'support/pipeline_fixture'

RSpec.describe Librelane::DetectionReporter do
  let(:made_dir) { Pathname(Dir.mktmpdir) }
  # after { FileUtils.rm_rf(made_dir) }

  let(:sim_config) do
    instance_double(Librelane::SimConfig, circ_name: 'C17', ref_nl: nil, stim_path: (made_dir / 'C17.stim').to_s)
  end
  subject(:reporter) { described_class.new(sim_config, made_dir) }

  describe '#parse_targets' do
    it 'extracts the signal and the output' do
      expect(reporter.parse_targets("# s=_2_/A1,o=o3\n")).to eq([['_2_/A1', '3']])
    end
  end

  describe '#detection_for_tvp' do
    before do
      PipelineFixture.sim
      allow(Librelane).to receive(:get_pdk_name).and_return('_2__A1')
      variant = made_dir / 'C17_apnr__2__A1'
      variant.mkpath
      (variant / 'activity_pnr1Xapnr.log_filtered.data').write("3 0 5\n") # format à adapter au vrai fichier
    end

    it 'counts a direct detection' do
      reporter.detection_for_tvp("# s=_2_/A1,o=o3\n", 0)
      expect(reporter.instance_variable_get(:@detections)).to include(direct: 1, combined: 1)
    end
  end

  describe 'avec la chaîne complète', :pnr, :questa do
    let(:sim)      { PipelineFixture.sim }
    let(:reporter) { described_class.new(sim[:sim_config], sim[:env].layout.made_dir('C17')) }

    it 'writes the detection report' do
      reporter.detection_report(sim[:sim_config])
      expect(sim[:env].layout.made_dir('C17') / 'detection_report.json').to exist
    end
  end
end
