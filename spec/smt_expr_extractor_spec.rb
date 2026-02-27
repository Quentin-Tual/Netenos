# frozen_string_literal: true
require_relative '../lib/netenos'
require_relative '../lib/sdf/sdf_delay_generator'
require_relative '../lib/delays'
require_relative '../lib/smt/smt_expr_extractor'

describe SMT::SMTExprExtractor do
  describe "With a xor5 netlist" do
    subject(:v_filepath) {'tests/verilog/xor5_prepnr.nl.v'}
    subject(:sdf_filepath) {'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'}
    subject(:obtained_file) {'tests/tmp/obtained.smt'}
    subject(:nl) {Verilog.load_netlist(v_filepath)}
    subject(:ast) {SDF::Parser.new.parse(sdf_filepath)}
    subject(:nl_delays) {ast.accept(SDF::DelayGenerator.new(nl, :typ))}
    # subject(:obtained_text) {
    #   smt_extractor = subject
    #   nl.get_outputs.first.accept(smt_extractor)
    #   smt_extractor.save_as(obtained_file)
    #   smt_extractor.print
    # }
    subject {SMT::SMTExprExtractor.new(nl, nl_delays, sdf_col: :typ)}

    before(:example) do 
      `rm #{obtained_file}` if File.exist?(obtained_file)
    end

    it "raises no error" do
      expect{nl.get_outputs.first.accept(subject)}.not_to raise_error
    end

    it "allows to save obtained smt expr in a file" do
      smt_extractor = subject
      nl.get_outputs.first.accept(smt_extractor)
      smt_extractor.visited.each{|node| node.is_a?(Netlist::Gate) ? puts(node.name) : puts(node.get_full_name)}
      smt_extractor.save_as(obtained_file)
      expect(File.exist?(obtained_file)).to eq(true)
      expect(File.zero?(obtained_file)).to eq(false) # not empty
    end
  end
end
