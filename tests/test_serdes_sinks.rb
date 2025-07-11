require_relative '../lib/netenos'

BLIF_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/alu4.blif"
DELAY_MODEL = :int_multi

Dir.chdir("tests/tmp") do 
  # Charger un circuit blif dans la variable 'circ'
  blif_loader = Converter::ConvBlif2Netlist.new
  blif_loader.gen_genlib
  circ = blif_loader.convert(BLIF_PATH)
  # Enregistrer le nom des sinks pour chaque porte de 'circ' dans 'sinks'
  sinks = circ.components.each_with_object(Hash.new) do |comp, h|
    h[comp.name] = comp.get_sink_gates.collect(&:name)
  end
  circ.get_inputs.each do |inp|
    sinks[inp.name] = inp.get_sink_gates.collect(&:name)
  end
  circ.constants.each do |const|
    sinks[const.name] = const.get_sink_gates.collect(&:name)
  end
  # Sérialiser le circuit 'circ' dans le fichier 'circ.sexp'
  ser = Serializer.new
  ser.serialize(circ)
  ser.save_as("#{circ.name}.sexp")
  # Désérialiser le fichier 'circ.sexp' dans la variable 'circ2'
  circ2 = Deserializer.new.deserialize("#{circ.name}.sexp")
  # Comparer 'sinks' et les sinks de 'circ2'
  comp_diff = circ2.components.any? { |comp| sinks[comp.name] != comp.get_sink_gates.collect(&:name) }
  inp_diff = circ2.get_inputs.any? { |inp| sinks[inp.name] != inp.get_sink_gates.collect(&:name)}
  const_diff = circ.constants.any? { |const| sinks[const.name] != const.get_sink_gates.collect(&:name) }
  if comp_diff or inp_diff or const_diff
    # Si il existe une différence renvoyer une erreur
    raise "Test Failed ! Deep copy does not properly conserve node sinks"
  else
    # Sinon indiquer la validité
    puts "Test validated. Serialization properly conserves node sinks"
  end  

  circ2.getNetlistInformations(DELAY_MODEL)
end