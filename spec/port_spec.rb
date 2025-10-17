require_relative '../lib/netlist'

RSpec.describe Netlist::Port do

    # TODO : Vérifier la structure de l'objet après instanciation. 
    context "After instanciation" do
        subject{Netlist::Port.new("test_pot_in", :in)}

        it 'is a Port class object' do 
            expect(subject).to be_kind_of Netlist::Port
        end

        it 'contains a name' do
            expect(subject.name).to be_kind_of String
        end

        it 'is part of a circuit class object' do
            expect(subject.partof).to be_kind_of(Netlist::Circuit).or eq(nil)
        end

        it 'has a direction' do
            expect(subject.direction).to eq(:in).or eq(:out)
        end

        it 'has a fanin' do
            expect(subject.fanin).to eq(nil).or be_kind_of(Netlist::Port)
        end

        it 'has a fanout' do
            expect(subject.fanout).to be_kind_of Array
        end

    end
    
    # TODO : Vérifier l'effet de la fonction de liaison "<="
    context "After wiring function" do
        before(:all) do 
            @global_in_port = Netlist::Port.new("global_in_port", :in)
            @global_out_port = Netlist::Port.new("global_out_port", :out)
            @in_port = Netlist::Port.new("in_port", :in)
            @out_port = Netlist::Port.new("out_port", :out)

            # Allowing context detection by wiring function
            @circ = Netlist::Circuit.new("test_circ")
            @global_in_port.partof = @circ
            @global_out_port.partof = @circ
            @comp = Netlist::Circuit.new("test_comp")
            @circ << @comp
            @comp << @in_port
            @comp << @out_port
        end

        it ":out <= :in" do
            expect{@out_port <= @in_port}.to raise_error
        end

        it ":in <= :out" do 
            @in_port <= @out_port
            expect(@out_port.fanout).not_to be_empty
            expect(@in_port.fanin).not_to eq(nil)
            expect(@out_port.fanout).to include(@in_port)
            expect(@in_port.fanin).to eq(@out_port)
        end

        it ":out (global) <= :out" do
            @global_out_port <= @out_port
            expect(@out_port.fanout).not_to be_empty
            expect(@global_out_port.fanin).not_to eq(nil)
            expect(@out_port.fanout).to include(@global_out_port)
            expect(@global_out_port.fanin).to eq(@out_port)
        end

        it "unplug" do 
          @in_port.unplug2(@out_port.get_full_name)
          expect(@in_port.fanin).to eq(nil)
          expect(@out_port.fanout).not_to include(@in_port)
        end

        it ":in <= :in (global)" do
            @in_port <= @global_in_port
            expect(@global_in_port.fanout).not_to be_empty
            expect(@in_port.fanin).not_to eq(nil)
            expect(@global_in_port.fanout).to include(@in_port)
            expect(@in_port.fanin).to eq(@global_in_port) 
        end

    end
end