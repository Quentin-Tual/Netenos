module VCD 
  
  class ArrayTrace
    attr_reader :signal_names, :values, :clk_period

    def initialize signal_names, clk_period, values = Hash.new {|h,k| h[k] = '0'}, length = nil
      @signal_names = signal_names.sort
      @clk_period = clk_period
      @values = values
      @length = length
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
      @values[sig] << val
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
      @length / @clk_period
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
      self.class.new(selected_signal_names, @clk_period, sort_keys(selected_values)).tap do |newtrace|
        newtrace.finalize
      end
    end

    def merge a_trace
      @signal_names += a_trace.signal_names
      @values.merge(a_trace.values)
    end

    def finalize
      @length = @values.first.last.length
      sort
    end
  end
end