# frozen_string_literal: true

module Verilog
  Token = Struct.new(:kind, :data, :num_line)

  class Lexer
    attr_reader :tokens

    def initialize
      @tokens = []
    end

    def lexify(path)
      tokenize(File.read(path))
    end

    def tokenize(str)
      num_line = 1

      while str.length.positive?
        case str
        when %r{\A/\*.+\*/}
          @tokens << Verilog::Token.new(:comment, ::Regexp.last_match(0), num_line)
        when /\Amodule /
          @tokens << Verilog::Token.new(:module, ::Regexp.last_match(0), num_line)
        when /\Aendmodule/
          @tokens << Verilog::Token.new(:endmodule, ::Regexp.last_match(0), num_line)
        when /\A\(/
          @tokens << Verilog::Token.new(:lpar, ::Regexp.last_match(0), num_line)
        when /\A\)/
          @tokens << Verilog::Token.new(:rpar, ::Regexp.last_match(0), num_line)
        when /\A;/
          @tokens << Verilog::Token.new(:semicolon, ::Regexp.last_match(0), num_line)
        when /\A\n/
          @tokens << Verilog::Token.new(:new_line, ::Regexp.last_match(0), num_line)
          num_line += 1
        when /\Awire /
          @tokens << Verilog::Token.new(:wire, ::Regexp.last_match(0), num_line)
        when /\Ainput /
          @tokens << Verilog::Token.new(:input, ::Regexp.last_match(0), num_line)
        when /\Aoutput /
          @tokens << Verilog::Token.new(:output, ::Regexp.last_match(0), num_line)
        when /\A,/
          @tokens << Verilog::Token.new(:coma, ::Regexp.last_match(0), num_line)
        when /\A\./
          @tokens << Verilog::Token.new(:dot, ::Regexp.last_match(0), num_line)
        when /\A\w+/
          @tokens << Verilog::Token.new(:ident, ::Regexp.last_match(0), num_line)
        when /\A\s/
          # Do nothing, just encountered a space or a tabulation
        else
          raise "Error: Unknown expression encountered '#{str}'"
        end
        str.delete_prefix!(::Regexp.last_match(0))
      end

      @tokens
    end
  end
end
