# frozen_string_literal: true

module Librelane
  # Fetches and analyzes the files of a librelane env after sim_all_pnr step and reports detections
  class DetectionReporter
    def initialize(sim_config, made_dir)
      @sim_config = sim_config
      @nl = sim_config.ref_nl
      @circ_name = sim_config.circ_name
      raise "Expecting a Pathname object, got a #{made_dir.class}" unless made_dir.is_a? Pathname

      @circ_dir = made_dir
      # @logfile = sim_config.filtered_activity_log_path
      @detections = {
        direct: 0,
        indirect: 0,
        combined: 0,
        alterations: 0
      }
    end

    def detection_report(sim_config)
      # tvp_id = 0
      # dly_db = SDF.generate_dly_db(nl, sim_config.ref_sdf)
      # min_dly = get_comp_min_delay(:sdf, dly_db: dly_db)

      file_enum = File.foreach(sim_config.stim_path).drop(2)
      file_enum.each_slice(3).with_index do |(line_t, _, _), tvp_id|
        detection_for_tvp(line_t, tvp_id) # fills @detections
      end

      # Ecrire les résultats calculés
      wd = @sim_config.made_dir.realpath
      res_path = wd / 'detection_report.json'
      File.write(res_path, JSON.pretty_generate(@detections))
    end

    def detected?(logfile, pattern)
      File.foreach(logfile).any? { |line| line.match?(pattern) }
    end

    def detection_for_tvp(line_t, tvp_id)
      targets = parse_targets(line_t)
      # Pour chaque cible
      targets.each do |t_sig, t_o|
        logfile_path = fetch_logfile(t_sig)
        # Fetch and read activity data file
        # Direct detection : one line (detected with the TVP associated to the altered signal) or zero (not detected)
        # direct_miss = run!('grep', '-E', "\"^#{t_o} #{tvp_id} 0\"", @logfile.to_s)
        direct = detected?(logfile_path, /\A#{Regexp.escape(t_o)} #{tvp_id} [1-9]\d*/)
        # Indirect detection : one or more lines (detected), zero line (not detected)
        # indirect_miss = run!('grep', '-E', '"^[0-9]+ [0-9]+ 0"', @logfile.to_s)
        indirect = detected?(logfile_path, /\A\d+ \d+ [1-9]\d*/)
        # Count the direct, indirect and cumulated detections
        # direct = direct_detections.split("\n").length.positive?
        # indirect = indirect_detections.split("\n").length.positive?

        update_detection_counters(direct, indirect)
      end
    end

    def parse_targets(line_t)
      targets = line_t.delete_prefix('# ').split(';')
      targets.collect do |target|
        t_sig, t_o = target.split(',')
        t_sig.strip!
        t_sig.delete_prefix!('s=')
        t_o.strip!
        t_o.delete_prefix!('o=o')
        [t_sig, t_o]
      end
    end

    def update_detection_counters(direct, indirect)
      @detections[:direct] += 1 if direct
      @detections[:indirect] += 1 if indirect
      @detections[:combined] += 1 if direct || indirect
    end

    def target_dir(t_sig)
      sig_pdk_name = Librelane.get_pdk_name(t_sig, @nl)
      found = @circ_dir.glob("#{circ_name}_apnr_#{sig_pdk_name}")
      raise "Multiple logfile identified for target #{sig_pdk_name} (#{t_sig})" if found.length > 1
      raise "No logfile found for target #{sig_pdk_name} (#{t_sig})" if found.empty?

      found.first.realpath
    end

    def fetch_logfile(t_sig)
      sig_pdk_name = Librelane.get_pdk_name(t_sig, @nl)
      found = @circ_dir.glob("#{@circ_name}_apnr_#{sig_pdk_name}/*_filtered.data")
      raise "Multiple logfile identified for target #{sig_pdk_name} (#{t_sig})" if found.length > 1
      raise "No logfile found for target #{sig_pdk_name} (#{t_sig})" if found.empty?

      found.first.realpath
    end

    # private

    # # Lance une commande SANS shell (pas de souci d'espaces ni d'injection),
    # # lève une exception en cas d'échec.
    # #   run!('envsubst', in: template, out: dest)
    # #   run!('vlib', 'sky130', chdir: dir)
    # def run!(*cmd, chdir: nil, env: {}, **redirects)
    #   opts = redirects.transform_values { |v| v.is_a?(Pathname) ? v.to_s : v }
    #   opts[:chdir] = chdir.to_s if chdir
    #   args = cmd.map(&:to_s)

    #   return if system(env, *args, **opts)

    #   raise "Command failed (exit status #{$CHILD_STATUS&.exitstatus.inspect}): #{args.inspect}"
    # end
  end
end
