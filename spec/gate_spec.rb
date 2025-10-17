require_relative '../lib/netlist'

RSpec.describe Netlist::And do

    context "After instanciation" do
    # * : On considère que si les tests sont validés sur cette classe, ils le sont aussi sur les classes similaires dont seul le nom de la classe change (OR, XOR, ...). 
        
        subject{Netlist::And2.new "g1"}

        before(:all) do
            @in_port1 = Netlist::Port.new("i1", :in)
            @out_port = Netlist::Port.new("o1", :out)
        end 

        it "is a Gate class object" do
            expect(subject.ports).to be_kind_of Hash
            expect(subject.ports[:in]).not_to be_empty
            expect(subject.ports[:out]).not_to be_empty
            expect(subject.ports[:in].length).to eq(2)
            expect(subject.ports[:out].length).to eq(1)
        end

        it "can't have more than 2 input ports and 1 output port" do
            subject.get_inputs.each{|p| expect(p.partof).to eq(subject)}
            subject.get_outputs.each{|p| expect(p.partof).to eq(subject)}

            expect{subject << @in_port1}.to raise_error
            expect{subject << @out_port}.to raise_error
        end

    end
end

RSpec.describe Netlist::Not do

    subject{Netlist::Not.new "g1"}

        before(:all) do
            @in_port1 = Netlist::Port.new("i1", :in)
            @in_port2 = Netlist::Port.new("i2", :in)
            @out_port = Netlist::Port.new("o1", :out)
        end 

        it "is a Gate class object" do
            expect(subject.ports).to be_kind_of Hash
            expect(subject.ports[:in]).not_to be_empty
            expect(subject.ports[:out]).not_to be_empty
            expect(subject.ports[:in].length).to eq(1)
            expect(subject.ports[:out].length).to eq(1)
        end

        it "can't have more than 1 port in and 1 port out" do
            subject.get_inputs.each{|p| expect(p.partof).to eq(subject)}
            subject.get_outputs.each{|p| expect(p.partof).to eq(subject)}

            expect {subject << @in_port1}.to raise_error
            expect {subject << @out_port}.to raise_error
        end
end