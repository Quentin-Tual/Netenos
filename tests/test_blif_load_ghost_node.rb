require_relative '../lib/netenos'

BLIF_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/apex2.blif"
DELAY_MODEL = :int_multi

Dir.chdir("tests/tmp") do 
  # Charger un circuit blif dans la variable 'circ'
  blif_loader = Converter::ConvBlif2Netlist.new
  blif_loader.gen_genlib
  circ = blif_loader.convert(BLIF_PATH)
  # Enregistrer l'object_id de chaque node (entrées et sorties primaires et de composants) enregistrées dans le circuit
  nodes = Set.new
  circ.get_inputs.each do |inp|
    nodes << inp.object_id
  end

  circ.components.each do |comp|
    comp.get_inputs.each do |inp|
      nodes << inp.object_id
    end
    comp.get_outputs.each do |outp|
      nodes << outp.object_id
    end
  end

  circ.get_outputs.each do |outp|
    nodes << outp.object_id
  end

  circ.constants.each do |const|
    nodes << const.object_id
  end

  # Vérifier que tous les sinks sont bien enregistrées dans 'nodes'
  inp_sink = circ.get_inputs.any? do |inp|
    inp.get_sinks.any? do |sink|
      !(nodes.include?(sink.object_id))
    end
  end

  const_sink = circ.constants.any? do |const|
    const.get_sinks.any? do |sink|
      !(nodes.include?(sink.object_id))
    end
  end

  comp_sink = circ.components.any? do |comp|
    comp.get_output.get_sinks.any? do |sink|
      !(nodes.include?(sink.object_id))
    end
  end

  # Vérifier que toutes les sources sont bien enregistrées dans 'nodes'
  comp_source = circ.components.any? do |comp|
    comp.get_inputs.any? do |inp|
      !(nodes.include?(inp.get_source.object_id))
    end
  end

  outp_source = circ.get_outputs.any? do |outp|
    !(nodes.include?(outp.get_source.object_id))
  end

  raise "Test Failed ! input port sink unknown" if inp_sink
  raise "Test Failed ! constant sink unknwon" if const_sink
  raise "Test Failed ! comp output sink unknown" if comp_sink
  raise "Test Failed ! comp input source unknown" if comp_source
  raise "Test Failed ! output port source unknown" if outp_source

  # if comp_diff or outp_diff
  #   # Si il existe une différence renvoyer une erreur
  #   raise "Test Failed ! Deep copy does not properly conserve node sources"
  # else
    # Sinon indiquer la validité
    puts "Test validated. Serialization properly conserves node sources"
  # end  

  # circ2.getNetlistInformations(DELAY_MODEL)
end