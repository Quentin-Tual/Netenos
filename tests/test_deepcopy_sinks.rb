require_relative '../lib/netenos'

BLIF_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/apex2.blif"
DELAY_MODEL = :int_multi

Dir.chdir("tests/tmp") do 
  # Charger un circuit blif dans la variable 'circ'
  blif_loader = Converter::ConvBlif2Netlist.new
  blif_loader.gen_genlib
  circ = blif_loader.convert(BLIF_PATH)
  # Enregistrer le nom des sinks pour chaque porte de 'circ' dans 'sinks'
  sinks = circ.components.each_with_object(Hash.new) do |comp, h|
    h[comp.name] = comp.get_sink_gates.collect(&:object_id)
  end
  circ.get_inputs.each do |inp|
    sinks[inp.name] = inp.get_sink_gates.collect(&:object_id)
  end
  circ.constants.each do |const|
    sinks[const.name] = const.get_sink_gates.collect(&:object_id)
  end
  # Deep copy du circuit
  circ2 = circ.deep_copy
  # Comparer 'sinks' et les sinks de 'circ2'
  comp_diff = circ2.components.any? { |comp| sinks[comp.name] == comp.get_sink_gates.collect(&:object_id) }
  outp_diff = circ2.get_inputs.any? { |inp| sinks[inp.name] == inp.get_sink_gates.collect(&:object_id) }
  const_diff = circ2.constants.any? { |const| sinks[const.name] == const.get_sink_gates.collect(&:object_id) }
  if comp_diff or outp_diff or const_diff
    # Si il existe une différence renvoyer une erreur
    raise "Test Failed ! Deep copy does not properly conserve node sinks comp : #{comp_diff}; outp: : #{outp_diff}, const: #{const_diff}"
  else
    # Sinon indiquer la validité
    puts "Test validated. Serialization properly conserves node sinks"
  end  

  circ2.getNetlistInformations(DELAY_MODEL)
end