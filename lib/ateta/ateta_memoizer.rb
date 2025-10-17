module AtetaAddOn
  
  class AtetaMemoizer
    def initialize
      @data = {}
    end

    def memoize(targeted_output,smtlib_converter)
      @data[targeted_output] = smtlib_converter
    end

    def exists?(targeted_output)
      !@data[targeted_output].nil?
    end

    def get_back(targeted_output)
      @data[targeted_output]
    end
  end
end