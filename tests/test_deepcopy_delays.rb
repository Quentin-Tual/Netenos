require_relative '../lib/netenos'

BLIF_PATH = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/f51m.blif"
DELAY_MODEL = :int_multi

Dir.chdir("tests/tmp") do 
  # Charger un circuit blif dans la variable 'circ'
  blif_loader = Converter::ConvBlif2Netlist.new
  blif_loader.gen_genlib
  circ = blif_loader.convert(BLIF_PATH)
  # Enregistrer les délais pour chaque porte de 'circ' dans 'delays_circ'
  delays_circ = circ.components.each_with_object(Hash.new) do |comp, h|
    h[comp.name] = comp.propag_time[DELAY_MODEL]
  end
  # Faire une deep copy de 'circ' dans la variable 'circ2'
  circ2 = circ.deep_copy
  # Comparer 'delays_circ' et 'delays_circ2'
  if circ2.components.any? { |comp| delays_circ[comp.name] != comp.propag_time[DELAY_MODEL] }
    # Si il existe une différence renvoyer une erreur
    raise "Test Failed ! Deep copy does not properly conserve gate delays"
  else
    # Sinon indiquer la validité
    puts "Test validated. Serialization properly conserves gate delays"
  end  
end