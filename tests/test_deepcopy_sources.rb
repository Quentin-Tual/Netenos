require_relative '../lib/netenos'

BLIF_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/apex5.blif"
DELAY_MODEL = :int_multi

Dir.chdir("tests/tmp") do 
  # Charger un circuit blif dans la variable 'circ'
  blif_loader = Converter::ConvBlif2Netlist.new
  blif_loader.gen_genlib
  circ = blif_loader.convert(BLIF_PATH)
  # Enregistrer le nom des sources pour chaque porte de 'circ' dans 'sources'
  sources = circ.components.each_with_object(Hash.new) do |comp, h|
    h[comp.name] = comp.get_source_gates.collect{|g| g}
  end
  circ.get_outputs.each do |outp|
    sources[outp.name] = outp.get_source_gates
  end
  # Deep copy du circuit
  circ2 = circ.deep_copy
  # Comparer 'sources' et les sources de 'circ2'
  comp_diff = circ2.components.any? { |comp| sources[comp.name] == comp.get_source_gates.collect{|g| g} }
  outp_diff = circ2.get_outputs.any? { |comp| sources[comp.name] == comp.get_source_gates}
  if comp_diff or outp_diff
    # Si il existe une différence renvoyer une erreur
    raise "Test Failed ! Deep copy does not properly conserve node sources comp : #{comp_diff}; outp: : #{outp_diff}"
  else
    # Sinon indiquer la validité
    puts "Test validated. Serialization properly conserves node sources"
  end  

  circ2.getNetlistInformations(DELAY_MODEL)
end