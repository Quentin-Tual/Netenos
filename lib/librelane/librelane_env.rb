module Librelane 
  class LibrelaneEnv
    def initialize pwd = '.', scl_target: "sky130_fd_sc_hd"
      @PWD = pwd
      @DLY_MDL = :sdf

      # Check if librelane is accessible through nix 
      # if yes fetch all paths required (pdk, librelane .nix file)
      check_install
      # Check if required directories are existing, else create them 
      check_dirs

      @env = {
        "SCL_TARGET"  => (@SCL_TARGET = scl_target),
        "LB_LANE"     => (@LB_LANE = "librelane/runs"),
        "PDK"         => @PDK
      }
    end

    def synth_n_pnr blif_path
      Dir.chdir('librelane_env') do 
        process_blif_input(blif_path)
        synth
        pnr
        save_last_run_files
      end
    end

    def process_blif_input blif_path
      @env["BLIF_NAME"] = @blif_name = blif_path.split("/").last
      FileUtils.cp(blif_path, "netlist/#{@blif_name}")
      @env["BLIF_PATH"] = @blif_path = "netlist/#{@blif_name}"
      @env["CIRC_NAME"] = @circ_name = @blif_name.split(".").first
      BlifRenamer.new.rename(@blif_path) unless File.exist?("#{@blif_path}.bak")
    end

    def synth_only blif_path
      Dir.chdir('librelane_env') do    
        process_blif_input(blif_path)
        synth
      end
    end

    def gen_ateta_stim inserted_std_cell: nil
      Dir.chdir('librelane_env') do      
        init_circ = Verilog.load_netlist(get_pnr_v)
        SDF.annotate(init_circ, get_pnr_sdf)
        ht_dly = init_circ.get_comp_min_delay(@DLY_MDL)
        
        generator = AtetaAddOn::AtetaLibrelane.new(self, init_circ, ht_dly, @DLY_MDL, inserted_std_cell: inserted_std_cell)
        generator.generate_stim
        generator.save_explicit("made/#{@circ_name}/#{@circ_name}.stim", binStimVec: true)
      end
    end

    def gen_htpg_transport_dly_stim inserted_std_cell: nil
      Dir.chdir('librelane_env') do
        init_circ = Verilog.load_netlist(get_pnr_v)
        init_dly_db = SDF.generate_dly_db(init_circ, get_pnr_sdf)
        ht_dly = init_circ.get_comp_min_delay(:sdf, dly_db: init_dly_db)
        
        generator = AtetaAddOn::HtpgLibrelane.new(self, init_circ, ht_dly, init_dly_db, smt_format: :pure)
        generator.generate_stim
        generator.save_explicit("made/#{@circ_name}/#{@circ_name}.stim", binStimVec: true)
      end
    end

    def insert_buf_and_finalize attacked_sig, inserted_std_cell = "#{@SCL_TARGET}__buf_8"
      puts " > Attack place and route"

      if inserted_std_cell.nil?
        inserted_std_cell = "#{@SCL_TARGET}__buf_8"
      end

      # Dir.chdir('librelane_env') do 
        last_run_path = get_last_run_path
        last_drt_path = Dir["#{last_run_path}/*detailedrouting*"].last

        if last_drt_path.empty?
          raise "No detailed routing step found in last run directory, previous run was not a pnr run or it was no fully completed"
        end

        @env["ATTACKED_SIG"] = attacked_sig
        @env["INSERTED_STD_CELL"] = inserted_std_cell

        cmd = "envsubst < librelane/template_insert_config.json > librelane/insert_config.json"
        system(@env, cmd)

        STDOUT.sync=true
        IO.popen("nix-shell #{@LBLANE_NIX} --run \"librelane ./librelane/insert_config.json --with-initial-state #{last_drt_path}/state_out.json --from Odb.InsertECOBuffers\"", 'r+'){|f|
          until f.eof? do puts f.gets; end
        }

        attacked_sig_name = attacked_sig.tr('/','-')
        save_last_run_files("apnr-#{attacked_sig_name}")
      # end
    end
    
    def get_pnr_v
      "made/#{@circ_name}/pnr.v"
    end
    
    def get_pnr_sdf
      "made/#{@circ_name}/pnr.sdf"   
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
    
    private 

    def check_install
      @LBLANE_NIX = `find $HOME -wholename "*librelane/shell.nix" -print -quit`.delete_suffix("\n")
      if @LBLANE_NIX.empty?
        raise "No Nix based LibreLane installation found, please see : https://librelane.readthedocs.io/en/stable/installation/index.html"
      end
      sky130_v = (eval `nix-shell #{@LBLANE_NIX} --run "ciel ls --pdk sky130"`).last
      @PDK = `nix-shell #{@LBLANE_NIX} --run "ciel path --pdk sky130 #{sky130_v}"`
      if @PDK.empty?
        raise "No Skywater 130nm PDK found with Ciel from Nix based LibreLane installation, please see : https://librelane.readthedocs.io/en/stable/installation/index.html"
      end

      if `which yosys-abc`.empty?
        raise "No Yosys ABC found, please see : https://github.com/YosysHQ/oss-cad-suite-build"
      end

      fix_pdk
    end

    def fix_pdk_files p
      files2fix = `ls #{p}`.split("\n")
      files2fix.each do |f|
        system("sed 's/`default_nettype none/`default_nettype wire/g' #{p}/#{f} > #{p}/#{f.delete_suffix(".v")}_fixed.v")
      end
    end

    def fix_pdk
      paths = ["#{@PDK}/sky130B/libs.ref/sky130_fd_io/verilog", "#{@PDK}/sky130B/libs.ref/#{@SCL_TARGET}/verilog"]

      paths.each do |p|
        if `ls #{p} | grep "_fixed.v"`.empty?
          puts "> INFO : Fixing PDK Verilog files in #{p}"
          fix_pdk_files p
        else
          puts "> INFO : PDK Verilog files already fixed"
          return 0
        end 
      end
    end

    def check_dirs
      # Deploy template_env
      template_dir_path = File.dirname(__FILE__) + "/template_env"
      FileUtils.cp_r(template_dir_path, @PWD + "/librelane_env") unless Dir.exist?(@PWD + "/librelane_env")
    end

    def synth 
      puts " > BLIF to Verilog conversion"

      cmd = "envsubst < synth/template_synth.abc > synth/synth.abc"
      system(@env, cmd)
      `yosys-abc -f synth/synth.abc`
    end

    def pnr 
      puts " > Place and route"
      cmd = "envsubst < librelane/template_config.json > librelane/config.json"
      system(@env, cmd)

      STDOUT.sync=true
      IO.popen("nix-shell #{@LBLANE_NIX} --run \"librelane librelane/config.json\"", 'r+'){|f|
        until f.eof? do puts f.gets; end
      }
      # `nix-shell #{$LBLANE_NIX} --run "librelane --run-tag attacked_run librelane/config.json"`
    end

    def save_last_run_files name='pnr'
      last_run_path = get_last_run_path
      nl_path = last_run_path + "/final/nl/#{@circ_name}.nl.v"
      sdf_path = last_run_path + "/final/sdf/nom_tt_025C_1v80/#{@circ_name}__nom_tt_025C_1v80.sdf"
      save_path = "made/#{@circ_name}"
      Dir.mkdir(save_path) unless Dir.exist?(save_path)
      FileUtils.cp(nl_path, save_path + "/#{name}.v")
      FileUtils.cp(sdf_path, save_path + "/#{name}.sdf")
    end
  end
end