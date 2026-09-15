require_relative '../lib/netenos'
require_relative '../lib/asp/gate_asp2'

# frozen_string_literal: true

describe ASP::GateASP do
  subject(:pdk_fun) { JSON.parse(File.read($PDK_FUN_JSON)) }
  subject(:pdk_ios) { JSON.parse(File.read($PDK_IOS_JSON)) }

  describe 'Using an Integer Delay model' do
    # Retrieve its ruby function
    subject(:pdk_gate) { pdk_gate_klass.new('test_and') }
    # subject(:gate_fun_proc) { pdk_gate_klass::RUBY_FUN_PROC }
    # Instantiate the associated GateASP class object
    subject(:asp_gate) do
      ASP::GateASP.new(
        pdk_gate.get_inputs.collect(&:name),
        pdk_gate.get_output.name,
        # Generate the ruby function for it
        pdk_gate_klass::RUBY_FUN_PROC,
        delay_r: 2,
        delay_f: 1
      )
    end
    context 'For an AND2 gate' do
      # Instantiate a sky130 standard cell
      subject(:pdk_gate_klass) { Netlist.create_pdk_class('Sky130_fd_sc_hd__and2_1', pdk_fun, pdk_ios) }

      it 'allows to encode its behavior in ASP' do
        puts asp_gate.to_asp
        expect { asp_gate.to_asp }.not_to raise_error

        # expect(true).to eq(true)
      end
    end

    context 'For an OR gate' do
      # Instantiate a sky130 standard cell
      subject(:pdk_gate_klass) { Netlist.create_pdk_class('Sky130_fd_sc_hd__or2_1', pdk_fun, pdk_ios) }

      it 'allows to encode its behavior in ASP' do
        puts asp_gate.to_asp
        expect { asp_gate.to_asp }.not_to raise_error

        # expect(true).to eq(true)
      end
    end

    context 'For a XOR gate' do
      # Instantiate a sky130 standard cell
      subject(:pdk_gate_klass) { Netlist.create_pdk_class('Sky130_fd_sc_hd__xor2_1', pdk_fun, pdk_ios) }

      it 'allows to encode its behavior in ASP' do
        puts asp_gate.to_asp
        expect { asp_gate.to_asp }.not_to raise_error

        # expect(true).to eq(true)
      end
    end
  end
end
