module AtetaAddOn

  def self.generate(nl, ht_delay, delay_model, path: "#{nl.name}.txt", forbidden_vectors: [], explicit: true, bin_stim_vec: false)
    generator = Ateta.new(nl, ht_delay, delay_model)
    vec_list = generator.generate_stim(forbidden_vectors)
    if explicit
      generator.save_explicit(path, binStimVec: bin_stim_vec)
    else
      Converter::GenStim.new(nl).save_vec_list(path, vec_list, bin_stim_vec: bin_stim_vec)
    end
  end
  
end