# frozen_string_literal: true
require_relative '../lib/netenos'

describe SDF::SimplifierVisitor do
  describe "Used on the AST obtained from SDF file" do
    subject(:test_file) {'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'}
    subject(:obtained_file) {
      unless Dir.exist?('tests/tmp')
        Dir.mkdir('tests/tmp')
      end
      'tests/tmp/noised.sdf'
    }

    subject(:noiseAdder) {SDF::NoiseAdder.new}
    subject(:ast) {ast = SDF::Parser.new.parse(test_file)}
    subject(:noised_ast) {ast.accept(noiseAdder)}

    it "simplifies the file by replacing all min and max values with corresponding typ values." do
      # init = ast 
      uut = nil
      expect{uut = noised_ast}.not_to raise_error
      uut.valid?
      # initial = `grep -Eo "[0-9]\.[0-9]+" #{test_file}`
      deparser = SDF::Deparser.new(obtained_file)
      ast.accept(deparser)
      # obtained = `grep -Eo "[0-9]\.[0-9]+" #{obtained_file}`
    end
  end
end
