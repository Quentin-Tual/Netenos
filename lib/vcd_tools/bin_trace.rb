module VCD 
  
  class BinArrayTrace < ArrayTrace
    ACCEPTED_VALUES = Set.new(['0','1'])
    attr_reader :signal_names, :values, :clk_period

    def initialize *args
      super(*args)
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

    def to_word_trace reversed:false
      word_names = get_word_names
      word_values = get_word_values(word_names, reversed)
      WordArrayTrace.new(word_values.keys,@clk_period, word_values, @length) 
    end

    def get_word_names 
      @signal_names.group_by do |sig_name|
        sig_name.split('_o')[0]
      end
    end

    def get_word_values word_signals_name, reversed
      res = {}
      word_building = reversed ? :build_rev_word : :build_word
      word_signals_name.each do |word_sig, bit_sigs|
        res[word_sig] = []
        @length.times do |i|
          res[word_sig] << self.send(word_building, bit_sigs, i).to_i(2)
        end
      end
      res
    end

    def build_word bit_sigs, i
      "".tap do |word| 
        bit_sigs.each do |sig|
          word << @values[sig][i]
        end
      end
    end

    def build_rev_word bit_sigs, i
      "".tap do |word| 
        bit_sigs.reverse_each do |sig|
          word << @values[sig][i]
        end
      end
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
        score << (local_score.to_f / (arr_size - tau)).round(3)
      end
      
      res = score.each_with_index.max

      if res[0] == score.first and res[0] == score.last
        [score.first, 0]
      else
        res
      end
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