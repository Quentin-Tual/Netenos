# spec/support/pipeline_fixture.rb
module PipelineFixture
  BLIF     = Pathname('/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/C17.blif').realpath
  CIRC     = 'C17'
  ATTACKED = ['_2_/A1'].freeze # liste explicite et courte : chaque insertion coûte un run

  class << self
    def pnr  = stage(:pnr) { build_pnr }
    def apnr = stage(:apnr) { build_apnr } # PnR + insertions (sur une copie)
    def sim  = stage(:sim) { build_sim } # + stimuli + simulation de toutes les variantes

    # Copie jetable d'une étape : l'appelant est responsable de rm_rf(copy[:dir])
    def fresh_copy(from = pnr)
      dir = Pathname(Dir.mktmpdir('copy'))
      FileUtils.cp_r(from[:env].layout.env_dir, dir / 'librelane_env', preserve: true)
      env = Librelane::LibrelaneEnv.new(config, dir, circ_name: CIRC)
      { dir: dir, env: env, files: from[:files] }
    end

    def cleanup
      @stages&.each_value { |(status, value)| FileUtils.rm_rf(value[:dir]) if status == :ok }
    end

    private

    def config = Librelane::LibrelaneConfig.new(BLIF.to_s, 100)

    def build_pnr
      dir = Pathname(Dir.mktmpdir('pnr'))
      env = Librelane::LibrelaneEnv.new(config, dir)
      { dir: dir, env: env, files: env.synth_n_pnr(BLIF.to_s) }
    end

    def build_apnr
      copy = fresh_copy(pnr)
      ATTACKED.each { |sig| copy[:env].insert_buf_and_finalize(sig) }
      copy
    end

    def build_sim
      base = apnr
      env  = base[:env]
      params = Librelane::SimParams.new(env.gen_ateta_stim(CIRC), env.layout.tb(CIRC).to_s, 10, full_traces: true)
      sim_config = Librelane::SimConfig.new(base[:files], nil, params, nil)
      env.sim_all_apnr2(sim_config)
      base.merge(sim_config: sim_config)
    end

    def stage(name)
      @stages ||= {}
      @stages[name] ||= begin
        [:ok, yield]
      rescue StandardError => e
        [:error, e]
      end
      status, value = @stages[name]
      raise value if status == :error

      value
    end
  end
end

# RSpec.configure { |c| c.after(:suite) { PipelineFixture.cleanup } }
