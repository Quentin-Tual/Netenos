
module ActivityLog

  class Log 
    attr_reader :filepath

    def initialize filepath
      @filepath = filepath
      @trace = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      load_from(filepath)
    end

    def load_from path
      # Loads an activity log from the given 'path' argument
      
      File.foreach(path) do |line|
        line = line.gsub(/(cycle=|time=|signal=|edge=)/,'')
        add(*line.chomp.split(' '))
      end
    end

    def add cycle, time, sig, edge
      # Stores the passed arguments into the 'trace' attribute 
      
      cycle = cycle.to_i
      @trace[cycle.to_i][sig][time.to_i] = edge
    end

    def anomaly? cycle, sig
      # Returns true if an anomaly is registered on the passed 'signal' in the passed 'cycle'
      
      !@trace.dig(cycle, sig).empty?
    end

    def anomaly_length cycle, sig
      # Returns the duration of the longest anomaly registered on the passed 'signal' in the passed 'cycle'
      
      if anomaly?(cycle,sig)
        edges = @trace[cycle][sig]
        edges.each_slice(2).collect do |r, f|
          if r[1] == "RISE" && f[1] == "FALL"
            f[0] - r[0] 
          else
            raise "Error: Unexpected transition configuration #{r}#{f} on signal #{sig} in cycle #{cycle}, expecting RISE then FALL."
          end
        end.max # or .sum ? Could be an interesting choice too, but changes the detection assumption and algorithm 
      else
        0
      end
    end

  end

  class LogDetector
    
    def initialize log, stim_path, nb_outputs
      @log = log
      @stim_targets = {}
      @TMP_FILEPATH = "#{$TMP_PATH}/#{File.basename(stim_path)}.tmp"
      @nb_outputs = nb_outputs
      @nb_inputs = 0
      load_stim_from(stim_path)
    end

    def load_stim_from stim_path
      # Loads HTPG TVPs from a file with their associated target signal and output.

      @nb_inputs = `head -1 #{stim_path}`.split(';')[2].to_i

      `tail -n +3 #{stim_path} > #{@TMP_FILEPATH}`
      
      File.foreach(@TMP_FILEPATH).each_slice(3).with_index do |(comment,v0,v1), stim_i|

        [comment,v0,v1].map(&:chomp!)

        targets = comment.tr(' ','').gsub(/(s=|o=|#|\n)/,'')
        targets = targets.split(';').collect{|e| e.split(',')}
        
        v0.chomp!
        v1.chomp!

        @stim_targets[stim_i] = [targets, v0, v1]
      end
    end

    # def analyze
    #   # Returns a list of anomaly length, one for each TVP, each anomaly length is associated to the targeted signals and outputs 

    #   anomaly_distrib = Hash.new {|h,k| h[k] = []}
      
    #   @stim_targets.each do |stim_i, (targets,v0,v1)|
    #     targeted_outputs = targets.collect{|s,o| o}
    #     targeted_outputs.each do |o|
    #       anomaly_distrib[o] << @log.anomaly_length((stim_i+1)*2, o)
    #     end
    #   end

    #   # val_list = anomaly_distrib.values.flatten
    #   # mean_anomaly = val_list.sum(0.0) / val_list.length 
    #   anomaly_distrib
    # end

    def generate_gnuplot_data path=@log.filepath
      anomaly_distrib = []

      @nb_outputs.times do |op_i|
        @stim_targets.each do |stim_i, (targets, v0, v1)|
          anomaly_distrib << "#{op_i} #{stim_i} #{@log.anomaly_length((stim_i+1)*2, "o#{op_i}")}"
        end
        anomaly_distrib << ""
      end

      txt = anomaly_distrib.join("\n")
      File.write("#{path}.data", txt)
    end
  
    def generate_filtered_gnuplot_data path=@log.filepath
       anomaly_distrib = []

      @nb_outputs.times do |op_i|
        @stim_targets.each do |stim_i, (targets, v0, v1)|
          if targets.any?{|t| t.last == "o#{op_i}"}
            anomaly_distrib << "#{op_i} #{stim_i} #{@log.anomaly_length((stim_i+1)*2, "o#{op_i}")}"
          end
        end
        anomaly_distrib << ""
      end

      txt = anomaly_distrib.join("\n")
      File.write("#{path}_filtered.data", txt)
    end

    def gen_gnuplot_script path=@log.filepath
      "set title \"Anomaly length for each output, through an HTPG test.\"
      set xyplane at 0
      set xlabel \"Output ID\"
      set ylabel \"TVP ID\"
      set zlabel \"Anomaly \nlength (ps)\"

      set xrange [-0.5:#{@nb_outputs.to_i}.5]
      set xrange [-0.5:#{@nb_outputs.to_i}.5]

      set border linewidth 2.0

      set grid

      set term svg
      set output \"filtered.svg\"
      splot for [i=0:#{@nb_outputs.to_i}] \"activity.log_filtered.data\" using (i):2:($1==i?$3:1/0) title sprintf(\"o%d\", i)"
    end

    def get_anomaly_length_distrib
       anomaly_distrib = []

      @nb_outputs.times do |op_i|
        @stim_targets.each do |stim_i, (targets, v0, v1)|
          if targets.any?{|t| t.last == "o#{op_i}"}
            anomaly_distrib << @log.anomaly_length((stim_i+1)*2, "o#{op_i}")
          end
        end
      end

      anomaly_distrib
    end

    def get_anomaly_length_dist_by_outputs
      anomaly_distrib = Hash.new {|h,k| h[k] = []}

      @nb_outputs.times do |op_i|
        @stim_targets.each do |stim_i, (targets, v0, v1)|
          targets.select{|s,o| o == "o#{op_i}"}.each do |s, o|
            anomaly_distrib[o] << [@log.anomaly_length((stim_i+1)*2, "o#{op_i}"), stim_i]
          end
        end
      end

      anomaly_distrib
    end

    def get_mean a
      a.sum(0.0) / a.length
    end

    def compute_stddev anomaly_dist
      a = anomaly_dist
      m = get_mean a
      s = a.sum(0.0) {|e| (e - m) ** 2}
      v = s / (a.size - 1)
      Math.sqrt(v)
    end

    def dist2mean_distrib anomaly_dist, m
      # m = get_mean(anomaly_dist)
      anomaly_dist.collect{|ano_duration, stim_i| [(ano_duration - m).abs, stim_i]}
    end

    def get_suspects_index a_dist, deg = 1 # deg is the multiplier of stddev as a distance of the mean 
      values = a_dist.collect(&:first)
      a_mean = get_mean(values)
      a_stddev = compute_stddev(values)
      
      distance_distrib = dist2mean_distrib(a_dist, a_mean)
      res = []
      distance_distrib.each do |ano_duration, stim_i| 
        if ano_duration > a_stddev*deg
          res << [ano_duration, stim_i]
        else
          next
        end
      end
      res
    end 

    def get_suspects_by_outputs deg=1
      anomaly_len_dist_by_output = get_anomaly_length_dist_by_outputs
      anomaly_len_dist_by_output.each_with_object(Hash.new) do |(o,dist), h|
        h[o] = get_suspects_index(dist, deg)
      end
    end
  end
end