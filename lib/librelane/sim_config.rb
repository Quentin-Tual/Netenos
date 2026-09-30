# frozen_string_literal: true

module Librelane
  # Contains file paths to the verilog and sdf files of a given placed and routed circuit.
  class PnrFiles
    attr_reader :v_file, :sdf_file

    def initialize(netlist, v_file, sdf_file)
      @netlist = netlist
      @v_file = v_file
      @sdf_file = sdf_file

      raise 'Incorrect paths' unless valid?
    end

    def valid?
      File.file?(@v_file) && File.file?(@sdf_file)
    end
  end

  # Contains the simulation parameters (path of the stimulation file, testbench file, period value, full wavetrace opt)
  class SimParams
    def initialize(stim_path, tb_path, period, full_traces: true)
      @stim_path = stim_path
      @tb_path = tb_path
      @period = period
      @full_traces = full_traces

      raise 'Incorrect paths' unless valid?
    end

    def valid?
      File.file?(@stim_path) && File.file?(@tb_path)
    end
  end

  # Contains the paths where to store the outputs
  class SimOutputs
    def initialize(activity_log_path, vcd_path)
      @activity_log_path = activity_log_path
      @vcd_path = vcd_path

      raise 'Incorrect paths' unless valid?
    end

    def valid?
      File.file?(@activity_log_path) && File.file?(@vcd_path)
    end
  end

  # Contains the circuit name, the paths to the verilog and sdf files, the path to the testbench and a trace option.
  class SimConfig
    attr_reader :circ_name, :ref_nl, :ref_v, :ref_sdf, :ut_nl, :ut_v, :ut_sdf, :stim_path, :tb_path, :period,
                :full_traces, :activity_log_path, :vcd_path

    def initialize(ref_pnr_files, ut_pnr_files, sim_params, sim_outputs) # rubocop:disable Metrics/MethodLength
      # Circuits
      @circ_name = ref_pnr_files.netlist.name
      @ref_nl = ref_pnr_files.netlist
      @ref_v = ref_pnr_files.v_file
      @ref_sdf = ref_pnr_files.sdf_file
      @ut_nl = ut_pnr_files.netlist
      @ut_v = ut_pnr_files.v_file
      @ut_sdf = ut_pnr_files.sdf_file

      # Simulation parameters
      @stim_path = sim_params.stim_path
      @tb_path = sim_params.tb_path
      @period = sim_params.period
      @full_traces = sim_params.full_traces

      # Simulation output paths
      @activity_log_path = sim_outputs.activity_log_path
      @vcd_path = sim_outputs.vcd_path
    end
  end
end
