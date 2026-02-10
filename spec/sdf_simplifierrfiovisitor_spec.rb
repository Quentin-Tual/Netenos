# frozen_string_literal: true
require_relative '../lib/netenos'

describe SDF::SimplifierRFIOVisitor do
  describe "Used on the AST obtained from SDF file" do
    subject(:test_file) {'tests/sdf/test_sdf.sdf'}
    subject(:ref_file) {'tests/sdf/ref_simplifiedRFIO.sdf'}
    subject(:obtained_file) {
      unless Dir.exist?('tests/tmp')
        Dir.mkdir('tests/tmp')
      end
      'tests/tmp/actual_simplifiedRFIO.sdf'
    }

    subject(:simplifier) {SDF::SimplifierRFIOVisitor.new(:max)}
    subject(:parse_deparse) {
      `rm #{obtained_file}` if File.exist?(obtained_file)
      # Parse test_sdf file
      ast = SDF::Parser.new.parse(test_file)
      ast.accept(simplifier)
      # Deparse the obtained AST
      deparser = SDF::Deparser.new(obtained_file)
      ast.accept(deparser)
    }

    it "simplifies the file by replacing all min and max values with corresponding typ values." do
      expect{parse_deparse}.not_to raise_error
      expect(File.exist?(obtained_file)).to eq(true)
      expect(File.empty?(obtained_file)).to eq(false)
      expect(FileUtils.identical?(ref_file, obtained_file)).to eq(true)
    end
  end
end
