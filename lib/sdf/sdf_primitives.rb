module SDF
  
  def self.annotate nl, sdf_path, fun: :max, col: :typ
    ast = Parser.new.parse(sdf_path)
    annotator = Annotator.new(nl, fun, col: col)
    ast.accept(annotator)
  end

  def self.apply_visitor sdf_path, visitor
    ast = Parser.new.parse(sdf_path)
    ast.accept(visitor)
  end

  def self.visit_n_write sdf_path, modified_path, visitor
    ast = Parser.new.parse(sdf_path)
    ast.accept(visitor)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end

  def self.nullify sdf_path, modified_path
    nullifyer = NullifyRoutingDelays.new
    visit_n_write(sdf_path, modified_path, nullifyer)
  end

  def self.add_noise sdf_path, modified_path
    noise_adder = NoiseAdder.new
    visit_n_write(sdf_path, modified_path, noise_adder)
  end

  def self.simplify sdf_path, modified_path
    simplifyer = SimplifierVisitor.new
    visit_n_write(sdf_path, modified_path, simplifyer)
  end

  def self.simplifyRF sdf_path, modified_path
    ast = Parser.new.parse(sdf_path)
    simplifyer = SimplifierRFVisitor.new
    ast.accept(simplifyer)
    deparser = Deparser.new(modified_path)
    ast.accept(deparser)
  end

  def self.simplifyRFIO sdf_path, modified_path
    simplifyer = SimplifierRFIOVisitor.new
    visit_n_write(sdf_path, modified_path, simplifyer)
  end

  def self.simplifyRFIOLastVal sdf_path, modified_path
    simplifyer = SimplifierRFIOLastValVisitor.new
    visit_n_write(sdf_path, modified_path, simplifyer)
  end

  def self.generate_dly_db c, sdf_path, inserted_gates: []
    visitor = SDF::DelayGenerator.new(c,:typ, inserted_gates: inserted_gates)
    apply_visitor(sdf_path,visitor)
  end

end