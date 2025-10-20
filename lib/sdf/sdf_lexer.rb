module SDF
  
  Token = Struct.new(:kind, :data, :num_line)
  
  class Lexer
    attr_reader :tokens
    
    def initialize
      @tokens = []
    end

    def lexify path
      tokenize(File.read(path))
    end

    def tokenize str
      num_line = 1

      while str.length > 0
        case str
        when /\A\n/
          @tokens << SDF::Token.new(:new_line, ::Regexp.last_match(0), num_line)
          num_line += 1
        when /\A\s/
          # Do nothing, just encountered a space or a tabulation
        when /\A\(\w+ .+\)/
          s = ::Regexp.last_match(0)
          @tokens << SDF::Token.new(:lpar, s[0], num_line)
          s.delete_prefix!('(').delete_suffix!(')')
          kind = s.split(' ')[0].downcase
          @tokens << SDF::Token.new(kind.to_sym, s, num_line)
          @tokens << SDF::Token.new(:rpar, ')', num_line)
        when /\A\(\w+/
          s = ::Regexp.last_match(0)
          @tokens << SDF::Token.new(:lpar, s[0], num_line)
          kind = s.tr("(\n",'')
          @tokens << SDF::Token.new(kind.downcase.to_sym, kind, num_line)
          # @tokens << SDF::Token.new(:new_line, "\n", num_line)
        # when /\A\(/
        #   @tokens << SDF::Token.new(:lpar, ::Regexp.last_match(0), num_line)
        when /\A\)/
          @tokens << SDF::Token.new(:rpar, ::Regexp.last_match(0), num_line)
        # when /\ADELAYFILE/ 
        #   @tokens << SDF::Token.new(:delayfile, ::Regexp.last_match(0), num_line)
        # when /\ADESIGN "\w+"/
        #   @tokens << SDF::Token.new(:design, ::Regexp.last_match(0), num_line)
        # when /\ATIMESCALE \w+/
        #   @tokens << SDF::Token.new(:timescale, ::Regexp.last_match(0), num_line)
        # when /\ACELL/
        #   @tokens << SDF:Token.new(:cell, ::Regexp.last_match(0), num_line)
        # when /\ACELLTYPE ".+"/
        #   @tokens << SDF::Token.new(:celltype, ::Regexp.last_match(0), num_line)
        # when /\AINSTANCE \w+/, /\AINSTANCE/, /\AINSTANCE _\d+_/
        #   @tokens << SDF::Token.new(:instance, ::Regexp.last_match(0), num_line)
        # when /\ADELAY/
        #   @tokens << SDF::Token.new(:delay, ::Regexp.last_match(0), num_line)
        # when /\AABSOLUTE/
        #   @tokens << SDF::Token.new(:absolute, ::Regexp.last_match(0),num_line)
        # when /\AINTERCONNECT \S+ \S+ \((\d|\.)+:(\d|\.)+:(\d|\.)+\) \((\d|\.)+:(\d|\.)+:(\d|\.)+\)/
        #   @tokens << SDF::Tokens.new(:interconnect, ::Regexp.last_match(0),num_line)
        # when /\AIOPATH \S+ \S+ \((\d|\.)+:(\d|\.)+:(\d|\.)+\) \((\d|\.)+:(\d|\.)+:(\d|\.)+\)/
        #   @tokens << SDF::Tokens.new(:iopath, ::Regexp.last_match(0),num_:line)
        # when /\A\(.+\)/
          # Ignore this line, skip unused lines (for example SDFVERSION, VERSION, PROGRAM,...)
        else
          raise "Error: Unknown expression encountered '#{str}'"
        end
        str.delete_prefix!(::Regexp.last_match(0))
      end

      @tokens
    end

  end # class
end # module