module SDF
  
  def self.annotate nl, sdf_path, fun: :max, col: :typ
    ast = Parser.new.parse(sdf_path)
    annotator = Annotator.new(nl, fun, col: col)
    ast.accept(annotator)
  end

  def self.nullify sdf_path, modified_path
    ast = Parser.new.parse(sdf_path)
    nullifyer = NullifyRoutingDelays.new
    ast.accept(nullifyer)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end

  def self.add_noise sdf_path, modified_path
    ast = Parser.new.parse(sdf_path)
    noise_adder = NoiseAdder.new
    ast.accept(noise_adder)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end

  def self.simplify sdf_path, modified_path
    ast = Parser.new.parse(sdf_path)
    simplifyer = SimplifierVisitor.new
    ast.accept(simplifyer)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end

  def self.simplifyRF sdf_path, modified_path
    ast = Parser.new.parse(sdf_path)
    simplifyer = SimplifierRFVisitor.new
    ast.accept(simplifyer)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end

  def self.simplifyRFIO sdf_path, modified_path
    ast = Parser.new.parse(sdf_path)
    simplifyer = SimplifierRFIOVisitor.new
    ast.accept(simplifyer)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end

  def self.simplifyRFIOLastVal sdf_path, modified_path
    ast = Parser.new.parse(sdf_path)
    simplifyer = SimplifierRFIOLastValVisitor.new
    ast.accept(simplifyer)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end
end