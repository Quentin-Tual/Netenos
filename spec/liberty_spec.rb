

require_relative '../lib/netenos'

describe Liberty::FunLexer do
  context 'Lexifying (A1&A2) | (!B1_N)' do
    subject(:expr) {"(A1&A2) | (!B1_N)"}
    subject(:tokens) {Liberty::FunLexer.new.tokenize(expr)}
    subject(:expected) {
      [
        Liberty::Token.new(:lpar,'('),
        Liberty::Token.new(:ident,'A1'),
        Liberty::Token.new(:and,'&'),
        Liberty::Token.new(:ident,'A2'),
        Liberty::Token.new(:rpar,')'),
        Liberty::Token.new(:or,'|'),
        Liberty::Token.new(:lpar,'('),
        Liberty::Token.new(:not,'!'),
        Liberty::Token.new(:ident,'B1_N'),
        Liberty::Token.new(:rpar,')')
      ]
    }
    it "gives the correct lexems" do
      tokens == expected
    end
  end
end

describe Liberty::FunParser do
  subject(:expr) {"(A1&A2) | (!B1_N)"}
  subject(:ast) {Liberty::FunParser.new.parse(expr)}
  subject(:expected) {
    Bexp::Or.new(
      Bexp::And.new(
        Bexp::Operand.new("A1"),
        Bexp::Operand.new("A2")
      ),
      Bexp::Not.new(
        Bexp::Operand.new("B1_N")
      )
    )
  }
  describe "Parsing (A1&A2) | (!B1_N)" do
    it "does not raise error" do
      expect{uut = ast}.not_to raise_error
      # expect(ast).to be_kind_of Liberty::Operator 
    end
    it "gives the correct AST" do
      obtained = ast
      ref = expected
      
      expect(obtained.class).to eq(ref.class)
      expect(obtained.operands.length).to eq(ref.operands.length)
      expect(obtained.operands[0].class).to eq(ref.operands[0].class)
      expect(obtained.operands[1].class).to eq(ref.operands[1].class)
      expect(obtained.operands[0].operands[0].class).to eq(ref.operands[0].operands[0].class)
      expect(obtained.operands[0].operands[1].class).to eq(ref.operands[0].operands[1].class)
      expect(obtained.operands[1].operands[0].class).to eq(ref.operands[1].operands[0].class)

      expect(obtained.operands[0].operands[0].name).to eq(ref.operands[0].operands[0].name)
      expect(obtained.operands[0].operands[1].name).to eq(ref.operands[0].operands[1].name)
      expect(obtained.operands[1].operands[0].name).to eq(ref.operands[1].operands[0].name)
    end
  end

  context "Converting (A1&A2) | (!B1_N) to SMT" do

    it "does not raise error" do 
      expect{ast.accept(Bexp::SMTConverter.new)}.not_to raise_error
    end

    it "gives (or (and A1 A2) not(B1_N))" do
      expect(ast.accept(Bexp::SMTConverter.new)).to eq(
        ['(','or','(','and','A1', 'A2',')','(','not','B1_N',')',')']
      )
    end
  end
end

