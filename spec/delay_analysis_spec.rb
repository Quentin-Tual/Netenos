# frozen_string_literal: true

# require 'ruby-debug'
require_relative '../lib/netenos'

describe Netlist::BackwardUniqDFS do
  describe "Applied on xor5 circuit" do
    subject(:v_filepath) {'tests/verilog/xor5_prepnr.nl.v'}
    subject(:nl) {Verilog.load_netlist(v_filepath)}
    subject {Netlist::BackwardUniqDFS.new(nl)}

    before(:all) do
      $DEBUG = true
    end

    it "raises no error" do
      expect{
        begin
          nl.get_outputs.first.accept(subject)
        rescue NotImplementedError => e 
        end
      }.not_to raise_error
    end

    it "follows the expecting exploration sequence" do
      uut = subject
      begin
        nl.get_outputs.first.accept(uut)
      rescue NotImplementedError => e 
      end
      expected = "o0
w8
_6_/o0
_6_
w6
_3_/o0
_3_
w0
i0
w1
i2
w7
_5_/o0
_5_
w4
i4
w5
_4_/o0
_4_
w2
i1
w3
i3"
      obtained = uut.visited.collect{|node| node.is_a?(Netlist::Gate) ? node.name : node.get_full_name}.join("\n")
      expect(obtained).to eq(expected)
    end

  end
end
