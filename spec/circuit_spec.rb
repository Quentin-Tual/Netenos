require_relative '../lib/netenos'

RSpec.describe Netlist::Circuit do
    subject(:delay_model) {:one}
    
    context "After instanciation" do
        subject{Netlist::Circuit.new('test')}

        it 'is a circuit class object' do
            expect(subject).to be_kind_of Netlist::Circuit
        end

        it ', contains a name' do
            expect(subject.name).to be_kind_of String
        end

        it ', contains ports of type \'in\'' do
            expect(subject.ports).to be_kind_of Hash
            expect(subject.ports[:in]).to be_kind_of Array
            
        end

        it ', contains ports of type \'out\'' do
            expect(subject.ports).to be_kind_of Hash
            expect(subject.ports[:out]).to be_kind_of Array
        end

        it 'is part of nil or another circuit' do
            expect(subject.partof).to be_kind_of(Netlist::Circuit).or eq(nil)
        end

        it 'does not contains components yet' do
            expect(subject.components).to be_kind_of Array
            subject.components.each{|c| expect(c).to eq(nil).or be_kind_of(Netlist::Circuit)}
        end

    end
    
    # TODO : Vérifier l'intégration d'un objet (port, composant), fonction "<<" 
    context 'After instanciation, provides the ability to' do
        before(:all) do
            @circ = Netlist::Circuit.new("test")
            @comp = Netlist::Circuit.new("comp")
            @in_port1 = Netlist::Port.new("i1", :in)
            @in_port2 = Netlist::Port.new("i2", :in)
            @out_port1 = Netlist::Port.new("o1", :out)
            @out_port2 = Netlist::Port.new("o2", :out)
        end

        it 'add ports to it' do
            @circ << @in_port1
            @circ << @in_port2
            @circ << @out_port1
            @circ << @out_port2

            expect(@circ.ports[:in]).to include(@in_port1)
            expect(@circ.ports[:in]).to include(@in_port2)
            expect(@circ.ports[:out]).to include(@out_port1)
            expect(@circ.ports[:out]).to include(@out_port2)
            
            expect(@in_port1.partof).to eq(@circ)
            expect(@in_port2.partof).to eq(@circ)
            expect(@out_port1.partof).to eq(@circ)
            expect(@out_port2.partof).to eq(@circ)
        end

        it 'add components to it' do
            @circ << @comp 
            expect(@circ.components).to include(@comp)
            expect(@comp.partof).to eq(@circ)
        end

        it 'add functions to it' do
            # * : We take the following expression as an example : o1 = in1 + in2 . in3
            @circ = Netlist::Circuit.new("test")
            out = Netlist::Port.new('o0', :out)
            in1 = Netlist::Port.new('i1', :in)
            in2 = Netlist::Port.new('i2', :in)
            in3 = Netlist::Port.new('i3', :in)
            g1 = Netlist::And2.new("g1")
            g2 = Netlist::Or2.new("g2")

            @circ << out
            @circ << in1
            @circ << in2
            @circ << in3
            
            g1.get_ports.each{|p| expect(p.partof).to eq(g1)}
            g2.get_ports.each{|p| expect(p.partof).to eq(g2)}
            
            in1 <= g2.get_port_named("i0")
            in2 <= g1.get_port_named("i0")
            in3 <= g1.get_port_named("i1")
            out <= g2.get_port_named("o0")
            g1.get_port_named("o0") <= g2.get_port_named("i1")

            @circ << g1
            @circ << g2

            expect(g1.partof).to eq(@circ)
            expect(g2.partof).to eq(@circ)

            # TODO : Voir si un 'visiteur' ne serait pas utile ici pour tester si le chemin est complet en départ de chaque entrée vers la sortie puis inversement.

            # TODO : Tester chaque interconnection, au moins vérifier si chaque port est connecté à un autre (source pour une entrée, sink pour une sortie)
        end
    end

    context "Adding wires to each interconnection" do 
      subject(:wired_circ) {
            circ = Netlist::Circuit.new("test")
            out = Netlist::Port.new('o0', :out)
            in1 = Netlist::Port.new('i1', :in)
            in2 = Netlist::Port.new('i2', :in)
            in3 = Netlist::Port.new('i3', :in)
            g1 = Netlist::And2.new("g1")
            g2 = Netlist::Or2.new("g2")
            w1 = Netlist::Wire.new('i1')
            w2 = Netlist::Wire.new('i2')
            w3 = Netlist::Wire.new('i3')
            w4 = Netlist::Wire.new('o0')
            w5 = Netlist::Wire.new('g1_o0')

            circ << g1
            circ << g2
            circ << out
            circ << in1
            circ << in2
            circ << in3
            circ << w1
            circ << w2
            circ << w3
            circ << w4
            circ << w5
            
            w1 <= in1
            g2.get_port_named("i0") <= w1
            w2 <= in2 
            g1.get_port_named("i0") <= w2
            w3 <= in3
            g1.get_port_named("i1") <= w3
            out <= w4
            w4 <= g2.get_port_named("o0") 
            w5 <= g1.get_port_named("o0")
            g2.get_port_named("i1") <= w5 
            
            circ
        }
        subject(:p2p_circ) {nl = wired_circ; nl.remove_wires; nl}
        subject(:rewired_circ) {nl = p2p_circ; nl.add_wires; nl}

        it "does not raise errors and returns a valid netlist" do
            expect{rewired_circ}.not_to raise_error
            expect(rewired_circ).to be_valid
        end

        it "leaves the netlist with all existing wires connected" do
            expect(rewired_circ.all_wires_connected?).to eq(true)
        end

        it "leaves the netlist with all existing ports connected" do
            expect(rewired_circ.all_ports_connected?).to eq(true)
        end

        it "leaves the netlist with no combinational loop" do
            expect(rewired_circ.has_combinational_loop?).to eq(false)
        end

        it "leaves the netlist with valid connections" do
            expect(rewired_circ.valid_connections?).to eq(true)
        end
    end

    context "Containing wires" do
        
        subject(:wired_circ) {
            circ = Netlist::Circuit.new("test")
            out = Netlist::Port.new('o0', :out)
            in1 = Netlist::Port.new('i1', :in)
            in2 = Netlist::Port.new('i2', :in)
            in3 = Netlist::Port.new('i3', :in)
            g1 = Netlist::And2.new("g1")
            g2 = Netlist::Or2.new("g2")
            w1 = Netlist::Wire.new('i1')
            w2 = Netlist::Wire.new('i2')
            w3 = Netlist::Wire.new('i3')
            w4 = Netlist::Wire.new('o0')
            w5 = Netlist::Wire.new('g1_o0')

            circ << g1
            circ << g2
            circ << out
            circ << in1
            circ << in2
            circ << in3
            circ << w1
            circ << w2
            circ << w3
            circ << w4
            circ << w5
            
            w1 <= in1
            g2.get_port_named("i0") <= w1
            w2 <= in2 
            g1.get_port_named("i0") <= w2
            w3 <= in3
            g1.get_port_named("i1") <= w3
            out <= w4
            w4 <= g2.get_port_named("o0") 
            w5 <= g1.get_port_named("o0")
            g2.get_port_named("i1") <= w5 
            
            circ
        }
        subject(:p2p_circ) {wired_circ.remove_wires; wired_circ}

        it "contains components with expected attributes" do
            expect(wired_circ.components).not_to be_empty
            wired_circ.components.each do |comp|
                expect(comp.propag_time).not_to be_empty
            end
        end

        it "contains connected wires" do
            expect(wired_circ.wires).not_to be_empty
            expect(wired_circ.wires.length).to eq(5)
            wired_circ.wires.each do |w|
            expect(w.fanin).not_to eq(nil)
            expect(w.fanout).not_to be_empty
            end
        end

        it "wired circuit does not raise error with DotGen" do
            expect{
            wired_circ.getNetlistInformations(delay_model)
            Converter::DotGen.new.dot(
                wired_circ, 
                "tests/tmp/wired_#{wired_circ.name}.dot", 
                delay_model
            )
        }.not_to raise_error
        end

        it "does not raise error with DotGen after removing wires" do
            expect{
                p2p_circ.getNetlistInformations(delay_model)
                Converter::DotGen.new.dot(
                    p2p_circ, 
                    "tests/tmp/p2p_#{p2p_circ.name}.dot", 
                    delay_model
                )
            }.not_to raise_error
        end

        it "allows to remove wires" do
            expect(wired_circ.all_ports_connected?).to eq(true)
            expect{p2p_circ}.not_to raise_error
            expect(p2p_circ.all_ports_connected?).to eq(true)
            expect(p2p_circ).to be_valid
        end

        it "does not raise error with util methods after removing wires" do 
            expect{
                uut = p2p_circ
                uut.getNetlistInformations(delay_model)
                uut.get_timings_hash(delay_model)
                uut.get_netlist_precedence_grid
                uut.get_slack_hash
            }.not_to raise_error
        end

        it "allows to get the avg delay of its components" do
          expect(p2p_circ.get_comp_avg_delay(delay_model)).to eq(1)
        end

        it "returns a correct slack hash" do
          uut = wired_circ
          uut.getNetlistInformations delay_model
          slack_h = uut.get_slack_hash
          uut.wires.each do |w|
            expect(w.slack).not_to eq(nil)
          end
        end

        it "computes correct cumulated_propag_times with delays on wires" do 
          uut = wired_circ
          uut.wires.each{|w| w.propag_time[delay_model] = 1}
          uut.getNetlistInformations delay_model
          uut.wires.each do |w|
            expect(w.cumulated_propag_time).not_to eq(0)
          end
          expect(uut.get_wire_named("i1").cumulated_propag_time).to eq(1)
          expect(uut.get_wire_named("i2").cumulated_propag_time).to eq(1)
          expect(uut.get_wire_named("i3").cumulated_propag_time).to eq(1)
          expect(uut.get_wire_named("g1_o0").cumulated_propag_time).to eq(3)
          expect(uut.get_wire_named("o0").cumulated_propag_time).to eq(5)
          expect(uut.get_port_named("o0").cumulated_propag_time).to eq(5)
        end

        it "returns a correct slack hash with delays on wires" do
          uut = wired_circ
          uut.wires.each{|w| w.propag_time[delay_model] = 1}
          uut.getNetlistInformations delay_model
          slack_h = uut.get_slack_hash
          uut.wires.each do |w|
            expect(w.slack).not_to eq(nil)
          end
          expect(uut.get_wire_named("o0").slack).to eq(0)
          expect(uut.get_wire_named("i1").slack).to eq(2)
          expect(uut.get_wire_named("i2").slack).to eq(0)
          expect(uut.get_wire_named("i3").slack).to eq(0)
          expect(uut.get_wire_named("g1_o0").slack).to eq(0)
        end

        it "returns corrects insertion points with delays on wires" do 
          uut = wired_circ
          uut.wires.each{|w| w.propag_time[delay_model] = 1}
          uut.getNetlistInformations delay_model
          insertion_points = uut.get_insertion_points 1
          expect(insertion_points.collect(&:get_full_name)).to eq(["g2/i0"])
        end
    end

end