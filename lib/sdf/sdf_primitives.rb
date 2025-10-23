module SDF
  
  def self.annotate nl, sdf_path 
    ast = SDF::Parser.new.parse(sdf_path)
    annotator = SDF::Annotator.new(nl, :max)
    ast.accept(annotator)
  end

end