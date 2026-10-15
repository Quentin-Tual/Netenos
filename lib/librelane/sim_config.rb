# frozen_string_literal: true

module Librelane
  # Contains file paths to the verilog and sdf files of a given placed and routed circuit.
  class PnrFiles
    attr_reader :netlist, :v_file, :sdf_file

    def initialize(netlist, v_file, sdf_file)
      @netlist = netlist
      @v_file = v_file
      @sdf_file = sdf_file

      raise 'Incorrect paths' unless valid?
    end

    private

    def valid?
      File.file?(@v_file) && File.file?(@sdf_file)
    end
  end

  # Contains the simulation parameters (path of the stimulation file, testbench file, period value, full wavetrace opt)
  class SimParams
    attr_reader :stim_path, :tb_path, :period, :full_traces

    def initialize(stim_path, tb_path, period, full_traces: true)
      @stim_path = stim_path
      @tb_path = tb_path
      @period = period
      @full_traces = full_traces

      raise "Incorrect paths #{@stim_path} with PWD : #{Dir.pwd}" unless File.file?(@stim_path)
    end

    def update_tb_path(new_path)
      @tb_path = new_path
    end
    # private

    # def valid?
    #    # && File.file?(@tb_path)
    # end
  end

  # Contains the paths where to store the outputs
  class SimOutputs
    attr_reader :activity_log_path, :vcd_path, :filtered_activity_log_path

    def initialize(activity_log_path, vcd_path)
      @activity_log_path = activity_log_path
      @vcd_path = vcd_path

      # raise 'Incorrect paths' unless valid?
    end

    def add_filtered_activity_log_path(path)
      @filtered_activity_log_path = path
    end

    private

    def valid?
      File.file?(@activity_log_path) && File.file?(@vcd_path)
    end
  end

  # Contains the circuit name, the paths to the verilog and sdf files, the path to the testbench and a trace option.
  class SimConfig
    attr_reader :circ_name, :made_dir

    def initialize(ref_pnr_files, ut_pnr_files, sim_params, sim_outputs)
      # Circuits
      @circ_name = ref_pnr_files.netlist.name.split('_').first
      @ref_pnr_files = ref_pnr_files
      @ut_pnr_files = ut_pnr_files
      # unless ut_pnr_files.nil?
      #   @ut_nl = ut_pnr_files.netlist
      #   @ut_v = ut_pnr_files.v_file
      #   @ut_sdf = ut_pnr_files.sdf_file
      # end

      # Simulation parameters
      @sim_params = sim_params
      # @stim_path = sim_params.stim_path
      # @tb_path = sim_params.tb_path
      # @period = sim_params.period
      # @full_traces = sim_params.full_traces

      # Simulation output paths
      @sim_outputs = sim_outputs
      # @activity_log_path = sim_outputs.activity_log_path
      # @vcd_path = sim_outputs.vcd_path
    end

    def add_ut_pnr_files(ut_pnr_files)
      SimConfig.new(@ref_pnr_files, ut_pnr_files, @sim_params, @sim_outputs)
    end

    def add_sim_outputs(sim_outputs)
      SimConfig.new(@ref_pnr_files, @ut_pnr_files, @sim_params, sim_outputs)
    end

    def update_tb_path(new_path)
      @sim_params.update_tb_path(new_path)
    end

    def add_filtered_activity_log_path(path)
      @sim_outputs.add_filtered_activity_log_path(path)
    end

    def add_made_dir(path)
      @made_dir = path
    end

    def ref_nl
      @ref_pnr_files.netlist
    end

    def ref_v
      @ref_pnr_files.v_file
    end

    def ref_sdf
      @ref_pnr_files.sdf_file
    end

    def ut_nl
      @ut_pnr_files.netlist
    end

    def ut_v
      @ut_pnr_files.v_file
    end

    def ut_sdf
      @ut_pnr_files.sdf_file
    end

    def stim_path
      @sim_params.stim_path
    end

    def tb_path
      @sim_params.tb_path
    end

    def period
      @sim_params.period
    end

    def full_traces
      @sim_params.full_traces
    end

    def activity_log_path
      @sim_outputs.activity_log_path
    end

    def vcd_path
      @sim_outputs.vcd_path
    end

    def filtered_activity_log_path
      @sim_outputs.filtered_activity_log_path
    end
  end

  # Containes parameters for a librelane run
  class LibrelaneConfig
    attr_accessor :period, :fp_core_util, :scl_target, :excluded_cells

    def initialize(blif_file, period, scl_target: 'sky130_fd_sc_hd', excluded_cells: [])
      @blif_file = blif_file
      @period = period
      @scl_target = scl_target
      @excluded_cells = excluded_cells

      raise "Invalid path #{@blif_file}" unless valid?
    end

    private

    def valid?
      File.file?(@blif_file)
    end
  end
end
