require "../lib/netlist.rb"

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
            g1 = Netlist::And.new("g1")
            g2 = Netlist::Or.new("g2")

            @circ << out
            @circ << in1
            @circ << in2
            @circ << in3
            
            g1.ports.each_value{|p| expect(p[0].partof).to eq(g1)}
            g2.ports.each_value{|p| expect(p[0].partof).to eq(g2)}
            
            in1 <= g2.get_port_named("i0")
            in2 <= g1.get_port_named("i0")
            in3 <= g1.get_port_named("i1")
            out <= g2.get_port_named("o0")
            g1.get_port_named("o0") <= g2.get_port_named("i1")

            @circ << g1
            @circ << g2

            expect(g1.partof).to eq(@circ)
            expect(g2.partof).to eq(@circ)

            # TODO : Vérifier que le datapath est bien enregistré et accessible.
            # ? : Serait-il intéressant de constituer une classe Datapath ? permettrait d'ajouter des méthodes pour le parcours du chemin dans un sens ou dans l'autre, permettrait de poser un nom et une image sur l'attribut "function" d'un circuit, voire si ce n'est pas même plus clair en le renommant.

            # TODO : Voir si un 'visiteur' ne serait pas utile ici pour tester si le chemin est complet en départ de chaque entrée vers la sortie puis inversement.

        end

        # ? : vérifier le message d'erreur en rattrapant l'exception ? Serait préférable à terme
    end

    # TODO : Vérifier ce que renvoie la fonction "inputs"
    # ! : En soit fonction simple, pas vraiment besoin
    # context 'allows to retrieve all its inputs' do

    #     it 'when there is none' do
            
    #     end

    #     it 'when there is one' do

    #     end

    #     it 'when there is many' do

    #     end
    # end

    # TODO : Vérifier ce que renvoie la fonction "outputs"
    # ! : Idem

    # TODO : Vérifier le retour de la fonction "get_port_named"
    # * : Fonctionne car déjà utilisée

    # TODO : Vérifier le retour de la fonction "get_component named"
    # * : Idem

    # TODO : Vérifier l'effet de la fonction "to_hash"
    # * Relativement long à faire et fonctionne vraisemblablement donc pas besoin d'aller plus loin.
end