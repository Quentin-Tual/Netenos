require 'English'
module Librelane
  class LibrelaneEnv
    def initialize(pwd = '.', scl_target: 'sky130_fd_sc_hd', excluded_cells: [])
      @PWD = pwd
      @DLY_MDL = :sdf

      # Check if librelane is accessible through nix
      # if yes fetch all paths required (pdk, librelane .nix file)
      check_install
      # Check if required directories are existing, else create them
      check_dirs

      excluded_cells = "[#{excluded_cells.collect { |name| "\"#{name}\"" }.join(",\n")}]"
      @env = {
        'SCL_TARGET' => (@SCL_TARGET = scl_target),
        'LB_LANE' => (@LB_LANE = 'librelane/runs'),
        'PDK' => @PDK,
        'EXTRA_EXCLUDED_CELLS' => (@EXCLUDED_CELLS = excluded_cells)
      }
    end

    def synth_n_pnr(blif_path)
      Dir.chdir('librelane_env') do
        process_blif_input(blif_path)
        synth
        pnr
        save_last_run_files("#{@circ_name}_pnr")
        @v_pnr = "made/#{@circ_name}/#{@circ_name}_pnr.v"
        @sdf_pnr = "made/#{@circ_name}/#{@circ_name}_pnr.sdf"
      end
    end

    def process_blif_input(blif_path)
      @env['BLIF_NAME'] = @blif_name = blif_path.split('/').last
      FileUtils.cp(blif_path, "netlist/#{@blif_name}")
      @env['BLIF_PATH'] = @blif_path = "netlist/#{@blif_name}"
      @env['CIRC_NAME'] = @circ_name = @blif_name.split('.').first
      BlifRenamer.new.rename(@blif_path) unless File.exist?("#{@blif_path}.bak")
    end

    def synth_only(blif_path)
      Dir.chdir('librelane_env') do
        process_blif_input(blif_path)
        synth
      end
    end

    def gen_ateta_stim(inserted_std_cell: nil)
      Dir.chdir('librelane_env') do
        init_circ = Verilog.load_netlist(get_pnr_v)
        SDF.annotate(init_circ, get_pnr_sdf)
        ht_dly = init_circ.get_comp_min_delay(@DLY_MDL)

        generator = AtetaAddOn::AtetaLibrelane.new(self, init_circ, ht_dly, @DLY_MDL,
                                                   inserted_std_cell: inserted_std_cell)
        generator.generate_stim
        generator.save_explicit("made/#{@circ_name}/#{@circ_name}.stim", binStimVec: true)
      end
    end

    def gen_htpg_transport_dly_stim(inserted_std_cell: nil, risky_signals: [])
      Dir.chdir('librelane_env') do
        init_circ = Verilog.load_netlist(get_pnr_v)
        init_dly_db = SDF.generate_dly_db(init_circ, get_pnr_sdf)
        ht_dly = init_circ.get_comp_min_delay(:sdf, dly_db: init_dly_db)

        generator = AtetaAddOn::HtpgLibrelane.new(
          self,
          init_circ,
          ht_dly,
          init_dly_db,
          smt_format: :pure,
          inserted_std_cell: inserted_std_cell,
          risky_signals: risky_signals
        )
        generator.generate_stim
        generator.save_explicit("made/#{@circ_name}/#{@circ_name}.stim", binStimVec: true)
      end
    end

    def gen_htpg_rec_stim(inserted_std_cell: nil, risky_signals: [])
      Dir.chdir('librelane_env') do
        init_circ = Verilog.load_netlist(get_pnr_v)
        init_dly_db = SDF.generate_dly_db(init_circ, get_pnr_sdf)
        ht_dly = init_circ.get_comp_min_delay(:sdf, dly_db: init_dly_db)

        generator = AtetaAddOn::HtpgLibrelane.new(
          self,
          init_circ,
          ht_dly,
          init_dly_db,
          smt_format: :rec,
          inserted_std_cell: inserted_std_cell,
          risky_signals: risky_signals
        )
        generator.generate_stim
        generator.save_explicit("made/#{@circ_name}/#{@circ_name}.stim", binStimVec: true)
      end
    end

    def insert_buf_and_finalize(attacked_sig, inserted_std_cell = "#{@SCL_TARGET}__buf_8")
      puts ' > Attack place and route'

      inserted_std_cell = "#{@SCL_TARGET}__buf_8" if inserted_std_cell.nil?

      # Dir.chdir('librelane_env') do
      last_run_path = get_last_run_path
      last_drt_path = Dir["#{last_run_path}/*detailedrouting*"].last

      if last_drt_path.empty?
        raise 'No detailed routing step found in last run directory, previous run was not a pnr run or it was no fully completed'
      end

      @env['ATTACKED_SIG'] = attacked_sig
      @env['INSERTED_STD_CELL'] = inserted_std_cell

      cmd = 'envsubst < librelane/template_insert_config.json > librelane/insert_config.json'
      system(@env, cmd)

      STDOUT.sync = true
      IO.popen(
        "nix-shell #{@LBLANE_NIX} --run \"librelane ./librelane/insert_config.json --with-initial-state #{last_drt_path}/state_out.json --from Odb.InsertECOBuffers\"", 'r+'
      ) do |f|
        puts f.gets until f.eof?
      end

      attacked_sig_name = attacked_sig.tr('/', '_')
      save_last_run_files("#{@circ_name}_apnr_#{attacked_sig_name}")
      # end
    end

    def get_pnr_v
      "made/#{@circ_name}/#{@circ_name}_pnr.v"
    end

    def get_pnr_sdf
      "made/#{@circ_name}/#{@circ_name}_pnr.sdf"
    end

    # def load_netlist v_file

    # end

    # def load_dly_db sdf_file

    # end

    def get_last_run_path
      last_run_dir = `ls -t #{@LB_LANE} | head -1 | tr -d '\n'`
      @LB_LANE + '/' + last_run_dir
    end

    def get_last_run_v
      get_last_run_path + "/final/nl/#{@circ_name}.nl.v"
    end

    def get_last_run_sdf
      get_last_run_path + "/final/sdf/nom_tt_025C_1v80/#{@circ_name}__nom_tt_025C_1v80.sdf"
    end

    def delete_last_run
      last_run_dir = get_last_run_path
      `rm -r #{last_run_dir}`
    end

    def run_sim(circ_name, mapped, ref_pnr, ut_pnr, tb_path, full_traces: false)
      opt = if full_traces
              '-voptargs="+acc"'
            else
              ''
            end
      cmds = [
        'vlib sky130',
        "vlog -work sky130 #{@PDK_V_FILES}/primitives_fixed.v",
        "vlog -work sky130 #{@PDK_V_FILES}/#{@SCL_TARGET}_fixed.v",
        "vlog -work sky130 #{@PDK_V_FILES2}/sky130_ef_io_fixed.v",
        "vlog -work sky130 #{@PDK_V_FILES2}/sky130_fd_io_fixed.v",
        'vlog work',
        "vlog #{mapped}.v",
        "vlog #{ref_pnr}.v",
        "vlog #{ut_pnr}.v",
        "vlog -v #{tb_path}",
        "vsim #{opt} -c -L sky130 +transport_int_delays -sdftyp mapped_dut=#{mapped}.sdf -sdftyp pnr_dut=#{ref_pnr}.sdf -sdftyp a_pnr_dut=#{ut_pnr}.sdf tb_#{circ_name} -sdfnoerror +sdf_report_unannotated_insts -do \"run -all\"" # rubocop:disable Layout/LineLength
      ]
      cmds.each do |cmd|
        system(cmd)
        raise "Error encountered during simulation : '#{$?}'" if $CHILD_STATUS.existatus.positive?
        # correspond à $?.existatus > 0
      end
    end

    def analyze_logs(circ_name, stim_path, nb_outputs)
      log = ActivityLog::Log.new('activity.log')
      detector = ActivityLog::LogDetector.new(log, stim_path, nb_outputs)
      detector.generate_gnuplot_data
      detector.generate_filtered_gnuplot_data

      File.rename('activity.log', 'activity_pnr1Xapnr.log')
      File.rename('activity.log.data', 'activity_pnr1Xapnr.log.data')
      File.rename('activity.log_filtered.data', 'activity_pnr1Xapnr.log_filtered.data')
      File.rename("tb_#{circ_name}.vcd", "tb_#{circ_name}_pnr1Xapnr.vcd")
    end

    def sim_only(pnr_path, apnr_path, stim_path, period: 10)
      pnr = Verilog.load_netlist("#{pnr_path}.v")
      apnr = Verilog.load_netlist("#{apnr_path}.v")
      tb_path = "tb/tb_#{pnr.name}.v"
      circ_name = pnr.name

      tb_generator = Converter::GenRealflowTestbench.new(pnr, pnr, apnr)
      tb_generator.gen_testbench(pnr.name, stim_path, period, path: tb_path, full_traces: true)

      run_sim(circ_name, pnr_path, pnr_path, apnr_path, tb_path, full_traces: true)
      `mv activity.log #{apnr_path}/activity.log`
      `mv tb_#{circ_name}.vcd #{apnr}/tb_#{circ_name}.vcd`

      analyze_logs(circ_name, stim_path, pnr.nb_outputs)
    end

    def sim_all_apnr(circ_name = @circ_name, stim_path: "made/#{circ_name}/#{circ_name}.stim", period: 100)
      # Check if pwd is a dir named "librelane_env" if not chdir in it, raise if an error occurs

      altered_circuits = Dir["made/#{circ_name}/apnr_*.v"].collect { |path| path.delete_suffix('.v') }

      pnr = "made/#{circ_name}/#{circ_name}_pnr"
      stim_path = File.expand_path(stim_path)

      raise "File #{stim_path} does not exist." unless File.exist?(stim_path)

      altered_circuits.each do |apnr|
        Dir.mkdir(apnr) unless Dir.exist?(apnr)
        sim_only(pnr, apnr, stim_path, period)
      end
    end

    private

    def check_install
      @LBLANE_NIX = `find $HOME -wholename "*librelane/shell.nix" -print -quit`.delete_suffix("\n")
      if @LBLANE_NIX.empty?
        raise 'No Nix based LibreLane installation found, please see : https://librelane.readthedocs.io/en/stable/installation/index.html'
      end

      sky130_v = (eval `nix-shell #{@LBLANE_NIX} --run "ciel ls --pdk sky130"`).last
      @PDK = `nix-shell #{@LBLANE_NIX} --run "ciel path --pdk sky130 #{sky130_v}"`
      if @PDK.empty?
        raise 'No Skywater 130nm PDK found with Ciel from Nix based LibreLane installation, please see : https://librelane.readthedocs.io/en/stable/installation/index.html'
      end

      @PDK_V_FILES = "#{@PDK}/sky130B/libs.ref/sky130_fd_io/verilog"
      @PDK_V_FILES2 = "#{@PDK}/sky130B/libs.ref/#{@SCL_TARGET}/verilog"

      if `which yosys-abc`.empty?
        raise 'No Yosys ABC found, please see : https://github.com/YosysHQ/oss-cad-suite-build'
      end

      res = `vsim -version`
      raise "Check Questasim installation, command 'vsim' returned : #{res}" if res.include?('not found')

      fix_pdk
    end

    def fix_pdk_files(p)
      files2fix = `ls #{p}`.split("\n")
      files2fix.each do |f|
        system("sed 's/`default_nettype none/`default_nettype wire/g' #{p}/#{f} > #{p}/#{f.delete_suffix('.v')}_fixed.v")
      end
    end

    def fix_pdk
      paths = ["#{@PDK}/sky130B/libs.ref/sky130_fd_io/verilog", "#{@PDK}/sky130B/libs.ref/#{@SCL_TARGET}/verilog"]

      paths.each do |p|
        if `ls #{p} | grep "_fixed.v"`.empty?
          puts "> INFO : Fixing PDK Verilog files in #{p}"
          fix_pdk_files p
        else
          puts '> INFO : PDK Verilog files already fixed'
          return 0
        end
      end
    end

    def check_dirs
      # Deploy template_env
      return if Dir.exist?("#{@PWD}/librelane_env")

      template_dir_path = "#{File.dirname(__FILE__)}/template_env.tar"
      Minitar.unpack(template_dir_path, @PWD)
      FileUtils.mv("#{@PWD}/template_env", "#{@PWD}/librelane_env")
    end

    def synth
      puts ' > BLIF to Verilog conversion'

      cmd = 'envsubst < synth/template_synth.abc > synth/synth.abc'
      system(@env, cmd)
      `yosys-abc -f synth/synth.abc`
    end

    def pnr
      puts ' > Place and route'
      cmd = 'envsubst < librelane/template_config.json > librelane/config.json'
      system(@env, cmd)

      STDOUT.sync = true
      IO.popen("nix-shell #{@LBLANE_NIX} --run \"librelane librelane/config.json\"", 'r+') do |f|
        puts f.gets until f.eof?
      end
      # `nix-shell #{$LBLANE_NIX} --run "librelane --run-tag attacked_run librelane/config.json"`
    end

    def save_last_run_files(name = 'pnr')
      last_run_path = get_last_run_path
      nl_path = last_run_path + "/final/nl/#{@circ_name}.nl.v"
      sdf_path = last_run_path + "/final/sdf/nom_tt_025C_1v80/#{@circ_name}__nom_tt_025C_1v80.sdf"
      save_path = "made/#{@circ_name}"
      Dir.mkdir(save_path) unless Dir.exist?(save_path)
      v_save_path = save_path + "/#{name}.v"
      sdf_save_path = save_path + "/#{name}.sdf"
      FileUtils.cp(nl_path, v_save_path)
      FileUtils.cp(sdf_path, sdf_save_path)
      rename_altered_module(name, v_save_path, sdf_save_path)
    end

    def rename_altered_module(new_name, v_path, sdf_path)
      `sed -i --regexp-extended 's/module \\w+/module #{new_name}/' #{v_path}`
      `sed -i --regexp-extended -e 's/DESIGN ".+"/DESIGN "#{new_name}"/' -e 's/CELLTYPE ".*#{@circ_name}"/CELLTYPE "#{new_name}"/' #{sdf_path}`
    end
  end
end
