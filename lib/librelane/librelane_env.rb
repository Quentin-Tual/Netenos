# frozen_string_literal: true

require 'English'
require 'fileutils'
require 'open3'
require 'pathname'
require 'shellwords'
# Minitar, Verilog, SDF, BlifRenamer, ActivityLog, AtetaAddOn, Converter...
# sont chargés ailleurs, comme dans la version précédente.

module Librelane
  # ---------------------------------------------------------------------------
  # Layout : source unique de vérité pour l'arborescence de librelane_env/.
  # Toutes les méthodes renvoient des Pathname ABSOLUS.
  # ---------------------------------------------------------------------------
  class Layout
    attr_reader :env_dir

    def initialize(base_dir = Dir.pwd)
      # Absolu dès la construction : plus de dépendance au répertoire courant.
      @env_dir = Pathname(base_dir).expand_path / 'librelane_env'
    end

    def base_dir = env_dir.parent

    # Rend absolu un chemin éventuellement relatif (relatif à env_dir,
    # comme à l'époque où tout tournait dans Dir.chdir(env_dir)).
    def abs(path) = Pathname(path).expand_path(env_dir)

    # Chemin relatif à env_dir (pour les variables d'env lues par les templates).
    def rel(path) = abs(path).relative_path_from(env_dir)

    # --- entrées / templates
    def netlist_dir     = env_dir / 'netlist'
    def blif(name)      = netlist_dir / name
    def synth_template  = env_dir / 'synth' / 'template_synth.abc'
    def synth_script    = env_dir / 'synth' / 'synth.abc'
    def synth_log       = env_dir / 'synth' / 'yosys-abc.log'
    def lane_dir        = env_dir / 'librelane'
    def runs_dir        = lane_dir / 'runs'
    def config_template = lane_dir / 'template_config.json'
    def config          = lane_dir / 'config.json'
    def insert_template = lane_dir / 'template_insert_config.json'
    def insert_config   = lane_dir / 'insert_config.json'
    def tb(circ)        = env_dir / 'tb' / "tb_#{circ}.v"

    # --- résultats
    def made_dir(circ) = env_dir / 'made' / circ
    def pnr_v(circ)    = made_dir(circ) / "#{circ}_pnr.v"
    def pnr_sdf(circ)  = made_dir(circ) / "#{circ}_pnr.sdf"
    def stim(circ)     = made_dir(circ) / "#{circ}.stim"

    # Variantes attaquées, SANS extension : .../<circ>_apnr_<sig>
    # (c'est aussi le nom du dossier de simulation de la variante)
    def apnr_variants(circ)
      made_dir(circ).glob("#{circ}_apnr_*.v").sort.map { |p| p.sub_ext('') }
    end
  end

  # ---------------------------------------------------------------------------
  # Pdk : fichiers Verilog du PDK sky130.
  # ---------------------------------------------------------------------------
  Pdk = Struct.new(:root, :scl_target) do
    # sky130_ef_io, sky130_fd_io
    def io_verilog  = Pathname(root) / 'sky130A/libs.ref/sky130_fd_io/verilog'
    # primitives.v et <scl_target>.v
    def scl_verilog = Pathname(root) / "sky130A/libs.ref/#{scl_target}/verilog"
  end

  # ---------------------------------------------------------------------------

  class InsertionError < StandardError; end

  class LibrelaneEnv
    FP_CORE_UTIL_VALUES = [1, 5, 10, 20, 50].freeze
    # FP_CORE_UTIL_VALUES = [50, 20, 10, 5, 1].freeze
    SDF_CORNER = 'nom_tt_025C_1v80'
    TEMPLATE_TAR = Pathname(__dir__) / 'template_env.tar'

    attr_reader :layout, :pdk, :circ_name, :fp_core_util

    # pwd peut être relatif : il est rendu absolu ici, une fois pour toutes.
    def initialize(lblane_config, pwd = '.', circ_name: nil)
      @layout = Layout.new(pwd)
      @dly_mdl = :sdf
      @lblane_config = lblane_config
      @fp_core_util = FP_CORE_UTIL_VALUES.first
      @circ_name = circ_name

      check_install # remplit @nix_shell et @pdk
      check_dirs

      excluded_cells = "[#{lblane_config.excluded_cells.map { |name| "\"#{name}\"" }.join(",\n")}]"
      @env = {
        'LB_LANE' => @layout.runs_dir.to_s,
        'PDK' => @pdk.root.to_s,
        'FP_CORE_UTIL' => @fp_core_util.to_s,
        'SCL_TARGET' => @lblane_config.scl_target,
        'PERIOD' => @lblane_config.period.to_s,
        'EXTRA_EXCLUDED_CELLS' => excluded_cells
      }
      @env['CIRC_NAME'] = circ_name if circ_name
    end

    # -------------------------------------------------------------------------
    # Flot principal
    # -------------------------------------------------------------------------

    # def run_full_flow(blif_path)
    #   pnr_files = synth_n_pnr(blif_path)
    #   stim_path = gen_ateta_stim(@circ_name)
    #   params = Librelane::SimParams.new(stim_path, env.layout.tb(@circ_name).to_s, 100, full_traces: true)
    #   sim_config = Librelane::SimConfig.new(pnr_files, nil, params, nil)
    #   sim_all_apnr2(sim_config)
    # end

    def synth_n_pnr(blif_path, fp_core_utils: FP_CORE_UTIL_VALUES)
      synth_only(blif_path)
      place_and_route(fp_core_utils: fp_core_utils)
    end

    # Public: PnR (first valid value of the list) + save of the results
    def place_and_route(fp_core_utils: FP_CORE_UTIL_VALUES)
      pnr(fp_core_utils)
      save_last_run_files("#{@circ_name}_pnr") # keep the argument you currently pass
    end

    # Retourne un Librelane::PnrFiles
    # def synth_n_pnr(blif_path, fp_core_utils: FP_CORE_UTIL_VALUES)
    #   process_blif_input(blif_path)
    #   synth
    #   pnr(fp_core_utils: fp_core_utils)
    #   save_last_run_files("#{@circ_name}_pnr")
    # end

    def synth_only(blif_path)
      process_blif_input(blif_path)
      synth
    end

    def insert_buf_and_finalize(attacked_sig, inserted_std_cell = nil)
      puts ' > Attack place and route'
      circ = require_circ!
      inserted_std_cell ||= "#{@lblane_config.scl_target}__buf_8"

      last_drt = last_run_dir.glob('*detailedrouting*').max
      if last_drt.nil?
        raise 'No detailed routing step found in last run directory, previous run was not a pnr run or it was not fully completed'
      end

      # Variables locales : on ne pollue plus @env pour les appels suivants.
      env = @env.merge('ATTACKED_SIG' => attacked_sig, 'INSERTED_STD_CELL' => inserted_std_cell)
      run!('envsubst', in: @layout.insert_template, out: @layout.insert_config, env: env)

      run_librelane(@layout.insert_config,
                    '--with-initial-state', last_drt / 'state_out.json',
                    '--from', 'Odb.InsertECOBuffers')

      unless last_run_success?
        raise InsertionError,
              'Insertion failed, check and modify PnR configuration if required then try again'
      end

      save_last_run_files("#{circ}_apnr_#{attacked_sig.tr('/', '_')}")
    end

    # -------------------------------------------------------------------------
    # Génération de stimuli
    # -------------------------------------------------------------------------

    def gen_ateta_stim(circ_name, inserted_std_cell: nil, fun: :max)
      circ = use_circ!(circ_name)

      init_circ = Verilog.load_netlist(get_pnr_v)
      SDF.annotate(init_circ, get_pnr_sdf, fun: fun)
      ht_dly = init_circ.get_comp_min_delay(@dly_mdl)

      generator = AtetaAddOn::AtetaLibrelane.new(
        self, init_circ, ht_dly, @dly_mdl,
        inserted_std_cell: inserted_std_cell
      )
      generator.generate_stim
      FileUtils.mv('htpg_time_report.txt', @layout.made_dir(circ_name) / 'htpg_time_report.txt')
      path = generator.save_explicit(stim_output_path(circ), binStimVec: true)
      Pathname.new(path).realpath
    end

    # Removes the altered variants (netlist, sdf, simulation dir) and the stimulus file
    def discard_variants(circ = require_circ!)
      @layout.apnr_variants(circ).each do |stem|
        FileUtils.rm_rf(stem)
        FileUtils.rm_f(["#{stem}.v", "#{stem}.sdf"])
      end
      FileUtils.rm_f(@layout.stim(circ))
    end

    def gen_htpg_transport_dly_stim(inserted_std_cell: nil, risky_signals: [], circ_name: nil)
      gen_htpg_stim(:pure, circ_name, inserted_std_cell: inserted_std_cell, risky_signals: risky_signals)
    end

    def gen_htpg_rec_stim(inserted_std_cell: nil, risky_signals: [], circ_name: nil)
      gen_htpg_stim(:rec, circ_name, inserted_std_cell: inserted_std_cell, risky_signals: risky_signals)
    end

    # -------------------------------------------------------------------------
    # Accès aux fichiers (chemins ABSOLUS, valables quel que soit le cwd)
    # -------------------------------------------------------------------------

    def get_pnr_v   = @layout.pnr_v(require_circ!).to_s
    def get_pnr_sdf = @layout.pnr_sdf(require_circ!).to_s

    def get_last_run_path = last_run_dir

    def get_last_run_v
      (last_run_dir / "final/nl/#{require_circ!}.nl.v").to_s
    end

    def get_last_run_sdf
      (last_run_dir / "final/sdf/#{SDF_CORNER}/#{require_circ!}__#{SDF_CORNER}.sdf").to_s
    end

    def delete_last_run
      # last_run_dir est toujours un enfant direct de runs_dir
      FileUtils.rm_rf(last_run_dir)
    end

    # -------------------------------------------------------------------------
    # Simulation
    # -------------------------------------------------------------------------

    # Simulation de comparaison de 2 circuits. Tout se passe dans le dossier
    # du activity.log : plus de `mv` à la fin, plus de chdir.
    # sim_config.* doit contenir des chemins absolus (ou relatifs à env_dir).
    def compare2_sim(sim_config)
      sim_dir = @layout.abs(sim_config.activity_log_path).dirname.tap(&:mkpath)
      opt = sim_config.full_traces ? ['-voptargs=+acc'] : []
      sim = ->(*cmd) { run!(*cmd, chdir: sim_dir) }

      sim.call('vlib', 'sky130')
      sim.call('vlog', '-work', 'sky130', @pdk.io_verilog / 'sky130_ef_io_fixed.v')
      sim.call('vlog', '-work', 'sky130', @pdk.io_verilog / 'sky130_fd_io_fixed.v')
      sim.call('vlog', '-work', 'sky130', @pdk.scl_verilog / 'primitives_fixed.v')
      sim.call('vlog', '-work', 'sky130', @pdk.scl_verilog / "#{@lblane_config.scl_target}_fixed.v")
      sim.call('vlib', 'work')
      sim.call('vlog', @layout.abs(sim_config.ref_v))
      sim.call('vlog', @layout.abs(sim_config.ut_v))
      sim.call('vlog', '-sv', @layout.abs(sim_config.tb_path))
      sim.call('vsim', *opt, '-c', '-L', 'sky130', '+transport_int_delays',
               '-sdftyp', "pnr_dut=#{@layout.abs(sim_config.ref_sdf)}",
               '-sdftyp', "a_pnr_dut=#{@layout.abs(sim_config.ut_sdf)}",
               "tb_#{sim_config.circ_name}", '-sdfnoerror', '+sdf_report_unannotated_insts',
               '-do', 'run -all')

      # Si le config demande d'autres noms/dossiers que ceux produits par vsim
      move_output(sim_dir / 'activity.log', sim_config.activity_log_path)
      move_output(sim_dir / "tb_#{sim_config.circ_name}.vcd", sim_config.vcd_path)
    end

    def simulate(sim_config)
      sim_config.update_tb_path(@layout.abs(sim_config.tb_path))
      Converter.gen_pnr_comp_testbench(sim_config)
      compare2_sim(sim_config)

      filtered_logs_path = analyze_logs(
        sim_config.circ_name,
        @layout.abs(sim_config.stim_path),
        sim_config.ref_nl.get_nb_outputs,
        @layout.abs(sim_config.activity_log_path)
      )
      sim_config.add_filtered_activity_log_path(filtered_logs_path)
    end

    def sim_all_apnr2(sim_config)
      circ = sim_config.circ_name
      sim_config.add_made_dir(@layout.made_dir(@circ_name))
      variants = @layout.apnr_variants(circ)
      raise "No altered circuits found matching #{@layout.made_dir(circ) / "#{circ}_apnr_*.v"}" if variants.empty?

      variants.each do |apnr| # apnr = chemin sans extension, aussi dossier de sortie
        apnr.mkpath

        ut_nl = Verilog.load_netlist("#{apnr}.v")
        ut_pnr_files = PnrFiles.new(ut_nl, "#{apnr}.v", "#{apnr}.sdf")
        sim_outputs = SimOutputs.new("#{apnr}/activity.log", "#{apnr}/tb_#{circ}.vcd")

        simulate(sim_config.add_ut_pnr_files(ut_pnr_files).add_sim_outputs(sim_outputs))
      end
    end

    # ActivityLog::Log écrit ses fichiers à côté de 'activity.log' avec des
    # noms dérivés du chemin fourni. Tant que je ne connais pas cette lib,
    # je garde un chdir LOCAL et en forme de bloc (restauré automatiquement).
    def analyze_logs(circ_name, stim_path, nb_outputs, activity_log_path)
      Dir.chdir(@layout.abs(activity_log_path).dirname) do
        log = ActivityLog::Log.new('activity.log')
        detector = ActivityLog::LogDetector.new(log, stim_path, nb_outputs)
        detector.generate_gnuplot_data
        detector.generate_filtered_gnuplot_data

        File.rename('activity.log', 'activity_pnr1Xapnr.log')
        File.rename('activity.log.data', 'activity_pnr1Xapnr.log.data')
        File.rename('activity.log_filtered.data', 'activity_pnr1Xapnr.log_filtered.data')
        File.rename("tb_#{circ_name}.vcd", "tb_#{circ_name}_pnr1Xapnr.vcd")
        Pathname.new('activity_pnr1Xapnr.log_filtered.data').realpath
      end
    end

    private

    # -------------------------------------------------------------------------
    # Helpers généraux
    # -------------------------------------------------------------------------

    # Lance une commande SANS shell (pas de souci d'espaces ni d'injection),
    # lève une exception en cas d'échec.
    #   run!('envsubst', in: template, out: dest)
    #   run!('vlib', 'sky130', chdir: dir)
    def run!(*cmd, chdir: nil, env: @env, **redirects)
      opts = redirects.transform_values { |v| v.is_a?(Pathname) ? v.to_s : v }
      opts[:chdir] = chdir.to_s if chdir
      args = cmd.map(&:to_s)

      return if system(env, *args, **opts)

      raise "Command failed (exit status #{$CHILD_STATUS&.exitstatus.inspect}): #{args.shelljoin}"
    end

    # Lance `librelane <args>` dans le nix-shell, depuis env_dir
    # (les templates de config utilisent des chemins relatifs à env_dir).
    def run_librelane(*args)
      $stdout.sync = true
      cmd = Shellwords.join(['librelane', *args.map(&:to_s)])
      IO.popen([{}, 'nix-shell', @nix_shell.to_s, '--run', cmd, { chdir: @layout.env_dir.to_s }], 'r') do |io|
        io.each_line { |line| puts line }
      end
    end

    # Exécute une commande dans le nix-shell et renvoie sa sortie (strip).
    def nix_capture(*cmd)
      out, status = Open3.capture2('nix-shell', @nix_shell.to_s, '--run', Shellwords.join(cmd.map(&:to_s)))
      raise "nix-shell command failed: #{cmd.join(' ')}" unless status.success?

      out.strip
    end

    def command_exists?(name)
      ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).any? do |dir|
        File.executable?(File.join(dir, name))
      end
    end

    def move_output(src, dst)
      src = Pathname(src)
      dst = @layout.abs(dst)
      return if src == dst

      dst.dirname.mkpath
      FileUtils.mv(src, dst)
    end

    # -------------------------------------------------------------------------
    # État : nom du circuit courant
    # -------------------------------------------------------------------------

    def require_circ!
      @circ_name or raise 'No circuit selected: call synth_n_pnr / synth_only / gen_ateta_stim first'
    end

    # Fixe @circ_name si fourni, sinon vérifie qu'il existe déjà.
    def use_circ!(circ_name)
      @circ_name = circ_name if circ_name
      require_circ!
    end

    # -------------------------------------------------------------------------
    # Installation / PDK
    # -------------------------------------------------------------------------

    def check_install
      @nix_shell = locate_nix_shell
      @pdk = Pdk.new(locate_pdk_root, @lblane_config.scl_target)

      unless command_exists?('yosys-abc')
        raise 'No Yosys ABC found, please see : https://github.com/YosysHQ/oss-cad-suite-build'
      end
      raise "Check Questasim installation, command 'vsim' not found in PATH" unless command_exists?('vsim')

      fix_pdk
    end

    # Variable d'environnement LIBRELANE_SHELL_NIX pour éviter le `find $HOME`.
    def locate_nix_shell
      from_env = ENV.fetch('LIBRELANE_SHELL_NIX', '')
      return Pathname(from_env) unless from_env.empty?

      out, = Open3.capture3('find', Dir.home, '-wholename', '*librelane/shell.nix', '-print', '-quit')
      if out.strip.empty?
        raise 'No Nix based LibreLane installation found, please see : https://librelane.readthedocs.io/en/stable/installation/index.html'
      end

      Pathname(out.strip)
    end

    def locate_pdk_root
      # ATTENTION : l'ancien code faisait un `eval` de la sortie de `ciel ls`.
      # Ici on prend le premier mot de la dernière ligne non vide : à vérifier
      # avec la sortie réelle de `ciel ls --pdk sky130` sur votre machine.
      listing = nix_capture('ciel', 'ls', '--pdk', 'sky130')
      version = listing.lines.map(&:strip).reject(&:empty?).last.to_s.split.first
      version.delete!('[]""')
      raise 'Could not determine sky130 version from `ciel ls`' if version.nil?

      root = nix_capture('ciel', 'path', '--pdk', 'sky130', version)
      if root.empty?
        raise 'No Skywater 130nm PDK found with Ciel from Nix based LibreLane installation, please see : https://librelane.readthedocs.io/en/stable/installation/index.html'
      end

      Pathname(root)
    end

    # Les primitives Verilog du PDK utilisent `default_nettype none, ce qui gêne
    # la simulation : on génère des copies *_fixed.v.
    def fix_pdk
      [@pdk.io_verilog, @pdk.scl_verilog].each do |dir|
        raise "PDK Verilog directory not found: #{dir}" unless dir.directory?

        if dir.glob('*_fixed.v').any?
          puts "> INFO : PDK Verilog files already fixed in #{dir}"
          next
        end

        puts "> INFO : Fixing PDK Verilog files in #{dir}"
        dir.glob('*.v').each do |src|
          fixed = src.binread.gsub('`default_nettype none', '`default_nettype wire')
          (dir / "#{src.basename('.v')}_fixed.v").binwrite(fixed)
        end
      end
    end

    # Déploie le template si librelane_env/ n'existe pas encore.
    def check_dirs
      return if @layout.env_dir.directory?

      Minitar.unpack(TEMPLATE_TAR.to_s, @layout.base_dir.to_s)
      FileUtils.mv(@layout.base_dir / 'template_env', @layout.env_dir)
    end

    # -------------------------------------------------------------------------
    # Entrée BLIF -> synthèse
    # -------------------------------------------------------------------------

    def process_blif_input(blif_path)
      blif = Pathname(blif_path).expand_path # relatif au cwd de l'appelant
      @circ_name = blif.basename.to_s.split('.').first
      dest = @layout.blif(blif.basename)

      FileUtils.cp(blif, dest) unless dest.exist? && blif.realpath == dest.realpath

      @env.merge!(
        'BLIF_NAME' => blif.basename.to_s,
        # Relatif à env_dir : les templates (synth.abc, config.json) sont
        # évalués avec env_dir comme répertoire courant.
        'BLIF_PATH' => @layout.rel(dest).to_s,
        'CIRC_NAME' => @circ_name
      )
      BlifRenamer.new.rename(dest.to_s) unless Pathname("#{dest}.bak").exist?
    end

    def synth
      puts ' > BLIF to Verilog conversion'

      run!('envsubst', in: @layout.synth_template, out: @layout.synth_script)
      # La sortie bruyante d'abc va dans un log plutôt que d'être perdue.
      run!('yosys-abc', '-f', @layout.rel(@layout.synth_script),
           chdir: @layout.env_dir, out: @layout.synth_log)
    end

    # -------------------------------------------------------------------------
    # Place & route
    # -------------------------------------------------------------------------

    def pnr(fp_core_utils)
      puts ' > Place and route'

      fp_core_utils.each do |val|
        @fp_core_util = val
        @env['FP_CORE_UTIL'] = val.to_s

        run!('envsubst', in: @layout.config_template, out: @layout.config)
        run_librelane(@layout.config)

        return nil if last_run_success?
      end

      raise "No valid configuration found to place and route the circuit #{@circ_name}"
    end

    # Dernier run = dossier le plus récent de runs/.
    # (Pour un choix déterministe, voir l'option --run-tag de librelane.)
    def last_run_dir
      runs_dir = @layout.runs_dir
      candidates = runs_dir.directory? ? runs_dir.children.select(&:directory?) : []
      run = candidates.max_by(&:mtime)
      raise "No last run directory found at #{runs_dir}" if run.nil?

      run
    end

    def last_run_success?
      File.empty?(last_run_dir / 'error.log')
    end

    # -------------------------------------------------------------------------
    # Sauvegarde des résultats d'un run
    # -------------------------------------------------------------------------

    # Copie netlist + SDF du dernier run vers made/<circ>/<name>.{v,sdf},
    # renomme le module, et renvoie un Librelane::PnrFiles.
    def save_last_run_files(name)
      run = last_run_dir

      netlists = run.glob('final/nl/*.nl.v')
      unless netlists.size == 1
        raise "Exactly one netlist expected after PnR, found #{netlists.size} in #{run / 'final/nl'}"
      end

      nl_path = netlists.first
      circ = nl_path.basename('.nl.v').to_s

      sdf_path = run.glob("final/sdf/#{SDF_CORNER}/*__#{SDF_CORNER}.sdf").first
      raise "SDF file not found in #{run / "final/sdf/#{SDF_CORNER}"}" if sdf_path.nil?

      out_dir = @layout.made_dir(circ).tap(&:mkpath)
      v_out = out_dir / "#{name}.v"
      sdf_out = out_dir / "#{name}.sdf"
      FileUtils.cp(nl_path, v_out)
      FileUtils.cp(sdf_path, sdf_out)
      rename_altered_module(name, circ, v_out, sdf_out)

      nl = Verilog.load_netlist(v_out.to_s)
      Librelane::PnrFiles.new(nl, v_out.to_s, sdf_out.to_s)
    end

    # Équivalent des deux `sed -i` d'origine.
    def rename_altered_module(new_name, circ, v_path, sdf_path)
      v_path = Pathname(v_path)
      v_path.write(v_path.read.gsub(/module \w+/) { "module #{new_name}" })

      sdf_path = Pathname(sdf_path)
      sdf = sdf_path.read
                    .gsub(/DESIGN ".+"/) { %(DESIGN "#{new_name}") }
                    .gsub(/CELLTYPE ".*#{Regexp.escape(circ)}"/) { %(CELLTYPE "#{new_name}") }
      sdf_path.write(sdf)
    end

    # -------------------------------------------------------------------------
    # Stimuli HTPG (partie commune)
    # -------------------------------------------------------------------------

    def stim_output_path(circ)
      @layout.made_dir(circ).mkpath
      @layout.stim(circ).to_s
    end

    def gen_htpg_stim(smt_format, circ_name, inserted_std_cell:, risky_signals:)
      circ = use_circ!(circ_name)

      init_circ = Verilog.load_netlist(get_pnr_v)
      init_dly_db = SDF.generate_dly_db(init_circ, get_pnr_sdf)
      ht_dly = init_circ.get_comp_min_delay(:sdf, dly_db: init_dly_db)

      generator = AtetaAddOn::HtpgLibrelane.new(
        self, init_circ, ht_dly, init_dly_db,
        smt_format: smt_format,
        inserted_std_cell: inserted_std_cell,
        risky_signals: risky_signals
      )
      generator.generate_stim
      generator.save_explicit(stim_output_path(circ), binStimVec: true)
    end
  end
end
