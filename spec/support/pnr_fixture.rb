# spec/support/pnr_fixture.rb
module PnrFixture
  BLIF = Pathname.new('/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/C17.blif').realpath

  def self.run
    @run ||= begin
      dir    = Pathname(Dir.mktmpdir('rspec_pnr_C17'))
      config = Librelane::LibrelaneConfig.new(BLIF.to_s, 100)
      env    = Librelane::LibrelaneEnv.new(config, dir)
      { dir: dir, env: env, files: env.synth_n_pnr(BLIF.to_s) }
    end
  end
end

## Décommenter pour supprimer le dossier temporaire après tous les tests Rspec d'une suite
# RSpec.configure do |c|
#   c.after(:suite) { FileUtils.rm_rf(PnrFixture.run[:dir]) if PnrFixture.instance_variable_get(:@run) }
# end
