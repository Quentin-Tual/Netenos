# frozen_string_literal: true

module Converter
  def self.gen_pnr_comp_testbench(sim_config)
    tb_generator = Converter::GenPnrCompTestbench.new(sim_config.ref_nl, sim_config.ut_nl)
    tb_generator.gen_testbench(
      sim_config.circ_name,
      sim_config.stim_path,
      sim_config.period,
      path: sim_config.tb_path,
      full_traces: sim_config.full_traces
    )
  end
end
