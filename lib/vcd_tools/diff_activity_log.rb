
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
        return 0
      end
    end

  end

  class LogDetector
    
    def initialize log, stim_path
      @log = log
      @stim_targets = {}
      @TMP_FILEPATH = "#{$TMP_PATH}/#{stim_path}.tmp"
      @nb_outputs = 0
      load_stim_from(stim_path) 
    end

    def load_stim_from stim_path
      # Loads HTPG TVPs from a file with their associated target signal and output.

      @nb_outputs = `head -1 #{stim_path}`.split(';')[2].to_i

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

    def analyze
      # Returns a list of anomaly length, one for each TVP, each anomaly length is associated to the targeted signals and outputs 

      anomaly_distrib = Hash.new {|h,k| h[k] = []}
      
      @stim_targets.each do |stim_i, (targets,v0,v1)|
        targeted_outputs = targets.collect{|s,o| o}
        targeted_outputs.each do |o|
          anomaly_distrib[o] << @log.anomaly_length((stim_i+1)*2, o)
        end
      end

      # val_list = anomaly_distrib.values.flatten
      # mean_anomaly = val_list.sum(0.0) / val_list.length 
      anomaly_distrib
    end

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

  end
end