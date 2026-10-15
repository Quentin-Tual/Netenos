module Librelane
  class ExperimentFullFlow
    Result = Data.define(:pnr_files, :stim_path, :sim_config, :report_path, :fp_core_util)

    def initialize(env:, blif:, period: 10)
      @env = env
      @blif = blif
      @period = period
    end

    def run
      step('synthesis') { @env.synth_only(@blif) }
      circ = @env.circ_name

      pnr_files, stim_path = pnr_and_stimuli(circ)
      sim_config = build_sim_config(pnr_files, stim_path, circ)
      step('simulation') { @env.sim_all_apnr2(sim_config) }

      report = step('detection report') do
        DetectionReporter.new(sim_config, @env.layout.made_dir(circ)).detection_report(sim_config)
      end

      Result.new(pnr_files:, stim_path:, sim_config:, report_path: report, fp_core_util: @env.fp_core_util)
    end

    private

    # Tries each FP_CORE_UTIL once, in order. A value is abandoned if its PnR fails
    # (handled by place_and_route) or if the insertions fail afterwards.
    def pnr_and_stimuli(circ)
      remaining = LibrelaneEnv::FP_CORE_UTIL_VALUES

      loop do
        # Raises "No valid configuration found..." when `remaining` is empty or all values fail
        pnr_files = step('place & route') { @env.place_and_route(fp_core_utils: remaining) }

        begin
          stim_path = step('stimuli + insertions') { @env.gen_ateta_stim(circ) }
          return [pnr_files, stim_path]
        rescue InsertionError => e
          failed = @env.fp_core_util
          warn "Insertion failed with FP_CORE_UTIL=#{failed} (#{e.message}), trying the next value"
          remaining = remaining.drop(remaining.index(failed) + 1)
          @env.discard_variants(circ)
        end
      end
    end

    def build_sim_config(pnr_files, stim_path, circ)
      params = SimParams.new(stim_path, @env.layout.tb(circ).to_s, @period, full_traces: true)
      SimConfig.new(pnr_files, nil, params, nil)
    end

    # Logs the step name and its duration; exceptions propagate unchanged.
    def step(name)
      puts "> #{name}"
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
    ensure
      puts format('  (%.1fs)', Process.clock_gettime(Process::CLOCK_MONOTONIC) - started)
    end
  end
end
