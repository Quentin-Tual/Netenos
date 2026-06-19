# frozen_string_literal: true

require_relative '../lib/netenos'
require_relative '../lib/librelane/librelane'

# test_blif = "/home/quentint/Workspace/Ruby/Netenos/tests/C17.blif"
test_blif = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/alu3.blif"


Dir.chdir("tests/tmp")
FileUtils.rm_r('librelane_env') if Dir.exist?('librelane_env')

describe Librelane::LibrelaneEnv do
  describe "" do

    it "finds existing required installation (nix librelane, ciel and sky130 pdk in it, yosys-abc)" do
      expect{subject}.not_to raise_error
    end

    it "synthetize correctly a given blif file" do 
      expect{subject.synth_only(test_blif)}.not_to raise_error
      expect(File.exist?('librelane_env/synth/alu3.v')).to eq(true)
    end

    it "place and route" do
      expect{subject.synth_n_pnr(test_blif)}.not_to raise_error
      expect(Dir['librelane_env/librelane/runs/*'].empty?).to eq(false)
      last_run = `ls -t librelane_env/librelane/runs | head -1 | tr -d '\n'`
      expect(Dir.exist?('librelane_env/librelane/runs/' + last_run + '/final')).to eq(true)
    end

    it "saves pnr files in made directory" do 
      expect(Dir.exist?('librelane_env/made/alu3')).to eq(true)
      expect(File.exist?('librelane_env/made/alu3/pnr.v')).to eq(true)
      expect(File.exist?('librelane_env/made/alu3/pnr.sdf')).to eq(true)
    end

    it "allows to insert a buffer to a pnr design then reroute and finalize design" do
      expect{ lblane_env = subject
              lblane_env.synth_n_pnr(test_blif)
              Dir.chdir('librelane_env') do
                lblane_env.insert_buf_and_finalize("_32_/A")
              end
            }.to_not raise_error
      expect(File.exist?("librelane_env/made/alu3/apnr-_32_-A.v")).to eq(true)
      expect(File.exist?("librelane_env/made/alu3/apnr-_32_-A.sdf")).to eq(true)
    end

    describe "#gen_ateta_stim" do
      let(:env) { described_class.new }
      let(:test_path) { "librelane_env/made/alu3/alu3.stim" }

      before do
        env.synth_n_pnr(test_blif)
      end

      it "generates an ATETA test stimulus file" do
        expect { env.gen_ateta_stim }.not_to raise_error

        # Verify the output file exists and contains expected content
        expect(File.exist?(test_path)).to be true
      end
    end
  end
end
