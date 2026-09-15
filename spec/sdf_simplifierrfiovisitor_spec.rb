# frozen_string_literal: true

require_relative '../lib/netenos'

describe SDF::SimplifierRFIOVisitor do
  describe 'Used on the AST obtained from SDF file' do
    subject(:test_file) { 'tests/sdf/test_sdf.sdf' }
    subject(:ref_file) { 'tests/sdf/ref_simplifiedRFIOlastval.sdf' }
    subject(:obtained_file) do
      Dir.mkdir('tests/tmp') unless Dir.exist?('tests/tmp')
      'tests/tmp/actual_simplifiedRFIO.sdf'
    end

    subject(:simplifier) { SDF::SimplifierRFIOVisitor.new(:max) }
    subject(:parse_deparse) do
      `rm #{obtained_file}` if File.exist?(obtained_file)
      # Parse test_sdf file
      ast = SDF::Parser.new.parse(test_file)
      ast.accept(simplifier)
      # Deparse the obtained AST
      deparser = SDF::Deparser.new(obtained_file)
      ast.accept(deparser)
    end

    it 'simplifies the file by replacing all min and max values with corresponding typ values.' do
      expect { parse_deparse }.not_to raise_error
      expect(File.exist?(obtained_file)).to eq(true)
      expect(File.empty?(obtained_file)).to eq(false)

      expected_lines = File.read(ref_file).split("\n")
      obtained_lines = File.read(obtained_file).split("\n")

      expect(obtained_lines.all? { |obtained_line| expected_lines.include?(obtained_line) }).to eq(true)
    end
  end
end
