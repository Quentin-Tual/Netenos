# frozen_string_literal: true

require_relative '../lib/netenos'

describe Delays::SlackAnalyzer do
  describe 'With a xor5 circuit and its associated SDF delays' do
    subject(:v_filepath) { 'tests/verilog/xor5_prepnr.nl.v' }
    subject(:sdf_filepath) { 'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf' }
    # subject(:v_filepath) { 'tests/verilog/f51m.nl.v' }
    # subject(:sdf_filepath) { 'tests/sdf/f51m__nom_tt_025C_1v80.sdf' }
    subject(:nl) { Verilog.load_netlist(v_filepath) }
    subject(:dly_db) { SDF.generate_dly_db(nl, sdf_filepath) }
    subject(:timings) { Delays::TimingAnalyzer.new(nl, dly_db).analyze }
    subject { Delays::SlackAnalyzer.new(nl, timings) }

    it 'raises no error' do
      expect { subject.analyze }.not_to raise_error
    end

    it 'associates all primary and gate inputs and wires to a delay' do
      uut = subject
      uut.analyze
      objs =  nl.get_inputs + \
              nl.components.collect { |g| g.get_inputs }.flatten + \
              nl.wires + \
              nl.get_outputs

      all_objs_timed = objs.all? do |obj|
        uut.slack.include?(obj)
      end

      expect(all_objs_timed).to eq(true)
    end

    it 'computes valid slacks' do
      expected = {
        'o0' => 0,
        'w8' => 0,
        '_6_/o0' => 0,
        '_6_/i0' => 172,
        'w6' => 172,
        '_6_/i1' => 0,
        'w7' => 0,
        '_3_/o0' => 172,
        '_3_/i0' => 172,
        'w0' => 172,
        '_3_/i1' => 175,
        'w1' => 175,
        'i0' => 172,
        'i2' => 175,
        '_5_/o0' => 0,
        '_5_/i0' => 171,
        'w4' => 171,
        '_5_/i1' => 0,
        'w5' => 0,
        'i4' => 171,
        '_4_/o0' => 0,
        '_4_/i0' => 0,
        'w2' => 0,
        '_4_/i1' => 3,
        'w3' => 3,
        'i1' => 0,
        'i3' => 3
      }
      uut = subject
      uut.analyze
      obtained = {}
      uut.slack.each { |sig, t| obtained[sig.get_full_name] = uut.slack[sig] unless sig.is_a? Netlist::Gate }

      expect(obtained).to eq(expected)
    end

    # it 'returns the same as legacy slack_h used in theoretical approach' do
    #   # Annoter le circuit avec les valeurs max du SDF
    #   SDF.annotate(nl, sdf_filepath)
    #   # Récupérer le slack_h
    #   timings_h = nl.get_timings_hash(:sdf)
    #   slack_h = nl.get_slack_hash
    #   # Mettre dans un format comparable
    #   expected = {}
    #   slack_h.each do |t, sigs|
    #     sigs.each do |sig|
    #       unless sig.is_a?(Netlist::Gate) || sig.instance_of?(Netlist::Wire) || (sig.is_a?(Netlist::Port) && sig.is_output? && !sig.partof.nil?)
    #         expected[sig.get_full_name] = t
    #       end
    #     end
    #   end
    #   # Récupérer le slack_db
    #   uut = subject
    #   uut.analyze
    #   obtained = {}
    #   uut.slack.each_key do |sig|
    #     unless sig.is_a?(Netlist::Gate) || sig.instance_of?(Netlist::Wire) || (sig.is_a?(Netlist::Port) && sig.is_output? && !sig.partof.nil?)
    #       obtained[sig.get_full_name] = uut.slack[sig]
    #     end
    #   end
    #   # Comparer les valeurs des deux objets, devraient être identiques
    #   expect(obtained).to eq(expected)
    # end
  end
end
