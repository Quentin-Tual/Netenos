module Liberty
  Token = Struct.new(:kind, :data)

  class FunLexer
    def initialize 
      @tokens = []
    end

    def tokenize expr
      while !expr.empty?
        case expr
        when /\A\(/
          @tokens << Token.new(:lpar, ::Regexp.last_match(0))
        when /\A\)/
          @tokens << Token.new(:rpar, ::Regexp.last_match(0)) 
        when /\A\&/
          @tokens << Token.new(:and, ::Regexp.last_match(0))
        when /\A\|/
          @tokens << Token.new(:or, ::Regexp.last_match(0))
        when /\A!/
          @tokens << Token.new(:not, ::Regexp.last_match(0))
        when /\A\w+/
          @tokens << Token.new(:ident, ::Regexp.last_match(0))
        when /\A\s/
        else
          raise "Error: Unexpected sequence encountered #{expr[0..10]}."
        end

        expr.delete_prefix!(::Regexp.last_match(0))
      end
      @tokens
    end
  end 

  class FunParser
    def acceptIt
      @tokens.shift
    end
    
    def showNext
      lookAhead 1
    end

    def lookAhead(n)
      @tokens[n - 1]
    end

    def accept_empty_lines
      until showNext.kind != :new_line
        acceptIt
      end
    end

    def show_next_line_kinds
      ret = []
      i = 1
      until lookAhead(i).kind == :semicolon
        ret << lookAhead(i).kind
        i+=1
      end
      last_tok = lookAhead(i)
      ret << last_tok.kind

      return ret
    end
    
    def expect(*kind)
      if kind.include?(actual = showNext.kind)
        acceptIt
      else
        raise "ERROR: Expecting #{kind}. Got #{actual} with #{showNext}"
      end
    end

    def maybe kind # same as expect but without error raised, for new_line token that does not change the structure or information contained in the file 
      if showNext.kind == kind 
        acceptIt
      end
    end

    def parse(expr)
      @tokens = FunLexer.new.tokenize(expr)

      terms = []
      operators = []

      while !@tokens.empty?
        #Can be a :lpar, :not or a :ident
        tok = expect(:lpar,:not,:ident)
        case tok.kind 
        when :lpar 
          terms << parse_block
        when :not
          terms << parse_not
        when :ident
          terms << parse_ident(tok)
        else 
          raise "Error: Internal error."
        end

        break if @tokens.empty?

        operators << expect(:and, :or)
      end

      
      if operators.length == 0 # No sum, only one term
        return terms.first
      elsif operators.uniq.length != 1
        raise "Error: Unexpected token sequence during parsing."
      end

      case operators.first.kind
      when :and
        Bexp::And.new(*terms)
      when :or
        Bexp::Or.new(*terms)
      else 
        raise "Error: Internal error."
      end
    end

    def parse_block
      operands = []
      operators = []
      while showNext.kind != :rpar
        tok = expect :lpar,:ident,:not
        case tok.kind
        when :lpar 
          operands << parse_block
        when :not
          operands << parse_not
        when :ident
          operands << parse_ident(tok)
        else
          raise "Error: Unexpected token encountered #{tok}."
        end
        
        break if showNext.kind == :rpar

        operators << expect(:and, :or)
      end
      expect :rpar

      if operators.length == 0 # No sum, only one term
        return operands.first
      elsif operators.uniq.length != 1
        raise "Error: Unexpected token sequence during parsing."
      end

      case operators.first.kind
      when :and
        Bexp::And.new(*operands)
      when :or
        Bexp::Or.new(*operands)
      else 
        raise "Error: Internal error."
      end
    end

    def parse_not
      tok = expect(:lpar, :ident)
      case tok.kind
      when :lpar
        Bexp::Not.new(parse_block)
      when :ident
        Bexp::Not.new(parse_ident(tok))
      else 
        raise "Error: Internal error."
      end
    end

    def parse_ident tok
      Bexp::Operand.new(tok.data)
    end
  end
end
