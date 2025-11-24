module VCD 
  
  class ArrayTrace
    ACCEPTED_VALUES = Set.new(['0','1'])
    attr_reader :signal_names, :values, :clk_period

    def initialize signal_names, clk_period, values = Hash.new {|h,k| h[k] = '0'}
      @signal_names = signal_names.sort
      @clk_period = clk_period
      @values = values
    end 

    def []=(sig,val)
      @values[sig] = val
    end

    def [](sig)
      @values[sig]
    end

    def keys 
      @values.keys
    end

    def add val, sig
      if !ACCEPTED_VALUES.include? val
          raise "Error: value #{val} no handled by class #{self.class}"
      elsif !@signal_names.include? sig
          raise "Error: signal #{sig} unknown for #{self}"
      else
          @values[sig] << val
      end
    end

    def repeat_last_value sig, n
      @values[sig] << @values[sig][-1]*n
    end

    def get_cycle n, sig
      # n must be < the length of values[sig]/@clk_period
      # else raise an error
      raise "Error: n > number of cycles in the trace, please verify." unless n <= get_nb_cycle
      
      start_cycle = n*@clk_period
      end_cycle = start_cycle+clk_period

      @values[sig][start_cycle...end_cycle]      
    end

    def get_nb_cycle
      @values.first.last.length / @clk_period
    end

    def is_valid?
      @values.values.collect(&:length).uniq.length == 1
    end

    def add_full_values values
      @values = values
    end

    def sort 
      @values = sort_keys(@values)
    end

    def split names_including
      # Create a new object of self.class and pass it the elements including names_including
      selected_signal_names = @signal_names.select{|s| s.include?(names_including)}
      selected_values = @values.select{|sig, val| sig.include? names_including}
      self.class.new(selected_signal_names, @clk_period, sort_keys(selected_values))
    end

    def merge a_trace
      @signal_names += a_trace.signal_names
      @values.merge(a_trace.values)
    end

    ## ------ Operators between traces ------
    
    # JACCARD
    def cycle_based_jaccard(b)
      a = self

      Hash.new.tap do |simi_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          simi_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            simi_by_sig["#{sa}/#{sb}"] << jaccard(
              a.get_cycle(cycle,sa).chars,
              b.get_cycle(cycle,sb).chars
            )
          end
        end
      end
    end

    def jaccard(arr_a, arr_b)
      m = [0,0]
      n = arr_a.length

      raise "Error: Arrays don't have the same size, operation not possible." if n != arr_b.length


      arr_a.zip(arr_b) do |va, vb|
          if va == "1" and vb == "1"
              m[1] += 1
          elsif va == "0" and vb == "0"
              m[0] += 1
          end
      end

      ((m[1].to_f) / (n-m[0])).round(3)
    end

    # TANIMOTO
    def cycle_based_tanimoto(b)
      a = self

      Hash.new.tap do |simi_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          simi_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            simi_by_sig["#{sa}/#{sb}"] << tanimoto(
              a.get_cycle(cycle,sa).chars,
              b.get_cycle(cycle,sb).chars
            )
          end
        end
      end
    end

    def tanimoto(arr_a, arr_b)
      m = [[0,0],[0,0]]
      n = arr_a.length

      raise "Error: Arrays don't have the same size, operation not possible." if n != arr_b.length


      arr_a.zip(arr_b) do |va, vb|
          m[va.to_i][vb.to_i] += 1
      end

      s_ident = m[1][1] + m[0][0]
      s_diff = m[1][0] + m[0][1]
      ( (s_ident).to_f / (s_ident + 2*(s_diff)) ).round(3)
    end

    # MICHENER
    def cycle_based_michener(b)
      a = self

      Hash.new.tap do |simi_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          simi_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            simi_by_sig["#{sa}/#{sb}"] << michener(
              a.get_cycle(cycle,sa).chars,
              b.get_cycle(cycle,sb).chars
            )
          end
        end
      end
    end

    def michener(arr_a, arr_b)
      m = [[0,0],[0,0]]
      n = arr_a.length

      raise "Error: Arrays don't have the same size, operation not possible." if n != arr_b.length


      arr_a.zip(arr_b) do |va, vb|
          m[va.to_i][vb.to_i] += 1
      end

      s_ident = m[1][1] + m[0][0]
      s_diff = m[1][0] + m[0][1]
      ( (s_ident).to_f / (s_ident + s_diff)).round(3)
    end

    # YULE
    def cycle_based_yule(b)
      a = self

      Hash.new.tap do |simi_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          simi_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            simi_by_sig["#{sa}/#{sb}"] << yule(
              a.get_cycle(cycle,sa).chars,
              b.get_cycle(cycle,sb).chars
            )
          end
        end
      end
    end

    def yule(arr_a, arr_b)
      m = [[0,0],[0,0]]
      n = arr_a.length

      raise "Error: Arrays don't have the same size, operation not possible." if n != arr_b.length


      arr_a.zip(arr_b) do |va, vb|
          m[va.to_i][vb.to_i] += 1
      end

      prod_ident = m[1][1] * m[0][0]
      prod_diff = m[1][0] * m[0][1]
      ( (prod_ident - prod_diff).to_f / (prod_ident + prod_diff) ).round(3)
    end

    # CORRELATION
    def cycle_based_correlation(b)
      a = self

      Hash.new.tap do |simi_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          simi_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            simi_by_sig["#{sa}/#{sb}"] << correlation(
              a.get_cycle(cycle,sa).chars,
              b.get_cycle(cycle,sb).chars
            )
          end
        end
      end
    end

    def correlation(arr_a, arr_b)
      m = [[0,0],[0,0]]
      n = arr_a.length

      raise "Error: Arrays don't have the same size, operation not possible." if n != arr_b.length

      arr_a.zip(arr_b) do |va, vb|
          m[va.to_i][vb.to_i] += 1
      end

      sigma = Math.sqrt((m[1][0] + m[1][1])*(m[0][1] + m[0][0])*(m[1][1] + m[0][1])*(m[0][0] + m[1][0]))
      prod_ident = m[1][1] * m[0][0]
      prod_diff = m[1][0] * m[0][1]
      ( (prod_ident - prod_diff).to_f / sigma ).round(3)
    end

    # CROSS-CORRELATION
    def cycle_based_xcorr(b, max_tau, step_size=1)
      a = self

      Hash.new.tap do |xcorr_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          xcorr_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            xcorr_by_sig["#{sa}/#{sb}"] << xcorr(
              a.get_cycle(cycle,sa).chars,
              b.get_cycle(cycle,sb).chars,
              max_tau,
              step_size
            )
          end
        end
      end
    end

    def xcorr(arr_a, arr_b, max_tau, step_size=1)
      score = []

      max_tau.times do |tau|
        local_score = 0
        arr_size = arr_a.length 

        (0...arr_size-tau).step(step_size) do |i|
          va = arr_a[i]
          vb = arr_b[i+tau]

        # end
        # arr_a[0..tau].zip(arr_b[tau..-1]).step(step_size) do |va, vb|
          if va == vb 
            local_score += 1
          else
            local_score -= 1
          end
        end
        score << local_score.to_f / (arr_size - tau)
      end
      
      score.each_with_index.max[1]
    end

    # DTW (Dynamic Time Warping)
    def cycle_based_dtw(b, w)
      a = self

      Hash.new.tap do |xcorr_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          xcorr_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            xcorr_by_sig["#{sa}/#{sb}"] << dtw(
              a.get_cycle(cycle,sa).chars,
              b.get_cycle(cycle,sb).chars,
              w
            )
          end
        end
      end
    end

    def dtw(arr_a, arr_b, w = arr_b.length)
      n = arr_a.length
      m = arr_b.length
      w = [w, (n-m).abs].max

      dtw = Array.new(n) {Array.new(m, Float::INFINITY)}
      dtw[0][0] = 0
      
      arr_a[1..].each_with_index do |va, i|
        i+=1
        j_min = [1, i-w].max
        j_max = [m, i+w].min
        arr_b[j_min..j_max].each_with_index do |vb, j|
          j += j_min
          cost = (va.to_i - vb.to_i).abs
          dtw[i][j] = cost + [  dtw[i-1][j],
                                dtw[i][j-1],
                                dtw[i-1][j-1]  ].min
        end
      end

      dtw[-1][-1]
    end
  end
end