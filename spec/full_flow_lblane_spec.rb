# frozen_string_literal: true

require_relative '../lib/netenos'
require_relative '../lib/librelane/full_flow_lblane'

RSpec.describe Librelane::ExperimentFullFlow do
  let(:env) do
    instance_double(Librelane::LibrelaneEnv, circ_name: 'C17', synth_only: nil, discard_variants: nil)
  end
  subject(:flow) { described_class.new(env: env, blif: 'C17.blif') }

  it 'retries with the next value after an insertion failure' do
    allow(env).to receive(:fp_core_util).and_return(1)
    allow(env).to receive(:place_and_route).and_return(:pnr_files)
    allow(env).to receive(:gen_ateta_stim).and_invoke(
      ->(_) { raise Librelane::InsertionError, 'boom' },
      ->(_) { 'C17.stim' }
    )
    allow(flow).to receive(:build_sim_config) # etc.

    flow.send(:pnr_and_stimuli, 'C17')

    expect(env).to have_received(:place_and_route).with(fp_core_utils: [5, 10, 20, 50])
    expect(env).to have_received(:discard_variants).with('C17')
  end

  it 'propagates the "no valid configuration" error when the values are exhausted' do
    allow(env).to receive(:fp_core_util).and_return(50)
    allow(env).to receive(:place_and_route).and_return(:pnr_files, :pnr_files)
    allow(env).to receive(:gen_ateta_stim).and_raise(Librelane::InsertionError)
    allow(env).to receive(:place_and_route).with(fp_core_utils: []).and_raise(RuntimeError, /No valid configuration/)

    expect { flow.send(:pnr_and_stimuli, 'C17') }.to raise_error(/No valid configuration/)
  end
end
