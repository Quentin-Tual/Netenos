require_relative '../lib/netlist'

RSpec.describe Netlist::Circuit do

    # TODO : Vérifier la structure de l'objet après instanciation
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
end