module VCD 
  
  class WordArrayTrace < ArrayTrace
    attr_reader :signal_names, :values, :clk_period

    def initialize *args
      super(*args)
    end 

    ## ------ Operators between traces ------

    # CROSS-CORRELATION
    def cycle_based_xcorr(b, max_tau, step_size=1)
      a = self

      Hash.new.tap do |xcorr_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          xcorr_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            xcorr_by_sig["#{sa}/#{sb}"] << xcorr(
              a.get_cycle(cycle,sa),
              b.get_cycle(cycle,sb),
              max_tau,
              step_size
            )
          end
        end
      end
    end

    # def xcorr(arr_a, arr_b, max_tau, step_size=1)
    #   score = []

    #   max_tau.times do |tau|
    #     win_a = arr_a[0..-tau-1]
    #     win_b = arr_b[tau..]

    #     score << win_a.zip(win_b).map{|va, vb| va * vb}.sum
    #   end
      
    #   score.each_with_index.max
    # end

    def xcorr(arr_a, arr_b, max_tau, step_size=1)
      score = []

      len_a = arr_a.length
      len_b = arr_b.length

      mean_a = arr_a.sum(0.0) / len_a
      std_a = Math.sqrt((arr_a.map{|ea| (ea - mean_a) ** 2}.sum(0.0) / len_a))

      mean_b = arr_b.sum(0.0) / len_b
      std_b = Math.sqrt((arr_b.map{|eb| (eb - mean_b) ** 2}.sum(0.0) / len_b))

      if std_a == 0.0 && std_b == 0.0
        return [0.0,0]
      end

      max_tau.times do |tau|
        win_a = arr_a[0..-tau-1]
        win_b = arr_b[tau..]

        if win_a.length != win_b.length
          raise "Error: xcorr not feasible on arrays of different lengths."
        end

        num = win_a.zip(win_b).map{|va, vb| (va - mean_a) * (vb - mean_b)}.sum(0.0)
        denom = win_a.length * std_a * std_b
        
        score << (num / denom).round(3)
      end
      
      score.each_with_index.max
    end

    # DTW (Dynamic Time Warping)
    def cycle_based_dtw(b, w)
      a = self

      Hash.new.tap do |xcorr_by_sig|
        a.keys.zip(b.keys) do |sa,sb|
          xcorr_by_sig["#{sa}/#{sb}"] = []
          a.get_nb_cycle.times do |cycle|
            xcorr_by_sig["#{sa}/#{sb}"] << dtw(
              a.get_cycle(cycle,sa),
              b.get_cycle(cycle,sb),
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