# frozen_string_literal: true

require_relative '../lib/netenos'

describe Delays::TimingAnalyzer do
  describe 'With a xor5 circuit and its associated SDF delays' do
    subject(:v_filepath) { 'tests/verilog/xor5_prepnr.nl.v' }
    subject(:nl) { Verilog.load_netlist(v_filepath) }
    subject(:sdf_filepath) { 'tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf' }
    subject(:dly_db) { SDF.generate_dly_db(nl, sdf_filepath) }
    subject { Delays::TimingAnalyzer.new(nl, dly_db) }

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
        uut.timings.include?(obj)
      end

      expect(all_objs_timed).to eq(true)
    end

    it 'computes valid max timings' do
      expected = {
        'i0' => 0,
        'i1' => 0,
        'i2' => 0,
        'i3' => 0,
        'i4' => 0,
        '_3_/i0' => 32,
        '_3_/i1' => 29,
        '_4_/i0' => 32,
        '_4_/i1' => 29,
        '_5_/i0' => 31,
        '_5_/i1' => 202,
        '_6_/i0' => 202,
        '_6_/i1' => 374,
        'w0' => 0,
        'w1' => 0,
        'w2' => 0,
        'w3' => 0,
        'w4' => 0,
        'w5' => 202,
        'w6' => 202,
        'w7' => 374,
        'w8' => 766,
        'o0' => 766
      }
      uut = subject
      uut.analyze
      obtained = {}
      uut.timings.each { |sig, t| obtained[sig.get_full_name] = uut.timings[sig] }
      expect(obtained).to eq(expected)
    end

    # it 'returns the same as legacy timings_h used in theoretical approach' do
    #   # Annoter le circuit avec les valeurs max du SDF
    #   SDF.annotate(nl, sdf_filepath)
    #   # Récupérer le slack_h
    #   timings_h = nl.get_timings_hash(:sdf)
    #   # Mettre dans un format comparable
    #   expected = {}
    #   timings_h.each do |t, sigs|
    #     sigs.each do |sig|
    #       if sig.is_a?(Netlist::Port) && sig.is_output? && !sig.partof.nil?
    #         sink_wires = sig.get_sinks
    #         sink_wires.each do |sink_wire|
    #           expected[sink_wire.get_full_name] = t
    #         end
    #       end
    #       unless sig.is_a?(Netlist::Gate) || sig.instance_of?(Netlist::Wire) || (sig.is_a?(Netlist::Port) && sig.is_output? && !sig.partof.nil?)
    #         expected[sig.get_full_name] = t
    #       end
    #     end
    #   end
    #   # Récupérer le slack_db
    #   uut = subject
    #   uut.analyze
    #   obtained = {}
    #   uut.timings.each_key do |sig|
    #     unless sig.is_a?(Netlist::Gate) || sig.instance_of?(Netlist::Wire) || (sig.is_a?(Netlist::Port) && sig.is_output? && !sig.partof.nil?)
    #       obtained[sig.get_full_name] = uut.timings[sig]
    #     end
    #   end
    #   # Comparer les valeurs des deux objets, devraient être identiques
    #   expect(obtained).to eq(expected)
    # end
  end
end
