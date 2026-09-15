require_relative '../lib/netenos'
require_relative '../lib/asp/gate_asp2'
require_relative '../lib/asp/asp_extractor'

# frozen_string_literal: true

describe ASP::ASPExtractor do
  subject(:pdk_fun) { JSON.parse(File.read($PDK_FUN_JSON)) }
  subject(:pdk_ios) { JSON.parse(File.read($PDK_IOS_JSON)) }

  describe 'Using an Integer Delay model' do
    describe 'With a xor5 netlist' do
      subject(:v_filepath) { 'tests/verilog/xor5_prepnr.nl.v' }
      subject(:sdf_filepath) { 'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf' }
      subject(:obtained_file) { 'tests/tmp/obtained.lp' }
      subject(:nl) { Verilog.load_netlist(v_filepath) }
      subject(:ast) { SDF::Parser.new.parse(sdf_filepath) }
      subject(:nl_delays) { ast.accept(SDF::DelayGenerator.new(nl, :typ)) }
      subject(:timings_db) { Delays::TimingAnalyzer.new(nl, nl_delays).analyze }
      # subject(:obtained_text) {
      #   smt_extractor = subject
      #   nl.get_outputs.first.accept(smt_extractor)
      #   smt_extractor.save_as(obtained_file)
      #   smt_extractor.print
      # }
      subject { ASP::ASPExtractor.new(nl, nl_delays, timings_db.max_by { |_, val| val }.last, sdf_col: :typ) }

      before(:example) do
        `rm #{obtained_file}` if File.exist?(obtained_file)
      end

      it 'raises no error' do
        expect { nl.get_outputs.first.accept(subject) }.not_to raise_error
      end

      it 'allows to save obtained smt expr in a file' do
        asp_extractor = subject
        nl.get_outputs.first.accept(asp_extractor)
        asp_extractor.save_as(obtained_file)
        expect(File.exist?(obtained_file)).to eq(true) # exists
        expect(File.zero?(obtained_file)).to eq(false) # not empty
      end
    end
  end
end
