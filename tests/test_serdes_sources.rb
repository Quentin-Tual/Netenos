require_relative '../lib/netenos'

BLIF_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/alu4.blif"
DELAY_MODEL = :int_multi

Dir.chdir("tests/tmp") do 
  # Charger un circuit blif dans la variable 'circ'
  blif_loader = Converter::ConvBlif2Netlist.new
  blif_loader.gen_genlib
  circ = blif_loader.convert(BLIF_PATH)
  # Enregistrer le nom des sources pour chaque porte de 'circ' dans 'sources'
  sources = circ.components.each_with_object(Hash.new) do |comp, h|
    h[comp.name] = comp.get_source_gates.collect{|g| g.name}
  end
  circ.get_outputs.each do |outp|
    sources[outp.name] = outp.get_source_gates.name
  end
  # Sérialiser le circuit 'circ' dans le fichier 'circ.sexp'
  ser = Serializer.new
  ser.serialize(circ)
  ser.save_as("#{circ.name}.sexp")
  # Désérialiser le fichier 'circ.sexp' dans la variable 'circ2'
  circ2 = Deserializer.new.deserialize("#{circ.name}.sexp")
  # Comparer 'sources' et les sources de 'circ2'
  comp_diff = circ2.components.any? { |comp| sources[comp.name] != comp.get_source_gates.collect{|g| g.name} }
  outp_diff = circ2.get_outputs.any? { |comp| sources[comp.name] != comp.get_source_gates.name}
  if comp_diff or outp_diff
    # Si il existe une différence renvoyer une erreur
    raise "Test Failed ! Deep copy does not properly conserve node sources"
  else
    # Sinon indiquer la validité
    puts "Test validated. Serialization properly conserves node sources"
  end  

  circ2.getNetlistInformations(DELAY_MODEL)
end