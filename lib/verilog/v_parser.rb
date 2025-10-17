module Verilog
  class Parser
    # def initialize
    #   @h = Hash.new
    #   @current_pos = h
    #   @block_stack = [] # Stack
    #   # @level = 0
    #   @line = 0
    # end
    
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

      return ret, last_tok.num_line
    end
    
    def expect(*kind)
      if kind.include?(actual = showNext.kind)
        acceptIt
      else
        raise "ERROR at #{showNext.num_line}. Expecting #{kind}. Got #{actual}"
      end
    end

    def maybe kind # same as expect but without error raised, for new_line token that does not change the structure or information contained in the file 
      if showNext.kind == kind 
        acceptIt
      end
    end
    
    def parse(path)
      @tokens = Lexer.new.lexify(path)

      # Verify if next tokens (firsts) are comments and skip them
      maybe :comment
      accept_empty_lines
      # Verify if next token is module, if it is parse it
      if showNext.kind == :module
        Root.new(path,parse_module)
      else
        raise "Error: No module found in the file #{path}"
      end
      # else raise an error
    end

    def parse_module
      expect :module
      mod = Verilog::Module.new(Verilog::Ident.new(expect(:ident).data))
      ios = []
      expect :lpar
      if showNext.kind == :rpar
        expect :rpar
      else
        until showNext.kind == :semicolon
          ios << Ident.new(expect(:ident).data)
          expect :coma, :rpar
          maybe :new_line
        end
      end
      expect :semicolon
      expect :new_line

      until showNext.kind == :endmodule
        maybe :new_line # Empty line
        next_line_kinds, num_line = show_next_line_kinds

        # Pattern matching
        case next_line_kinds
        in [:input | :output | :wire, :ident, :semicolon]
          mod.add(parse_decl)
        in [:ident, :ident, :lpar, *]
          mod.add(parse_inst)
        else
          raise "Error: Verilog Parser encountered unknown sequence #{next_line_kinds} at line #{num_line}."
        end
      end

      mod
    end

    def parse_decl
      tok = expect(:input, :output, :wire)
      sig_name = Ident.new(expect(:ident).data)
      expect :semicolon
      expect :new_line

      case tok.kind
      when :input
        Verilog::Input.new(sig_name)
      when :output
        Verilog::Output.new(sig_name)
      when :wire
        Verilog::Wire.new(sig_name)
      else
        raise "Error: Verilog parser encountered an unexpected sequence -> #{tok}"
      end
    end

    def parse_inst
      module_name = Ident.new(expect(:ident).data)
      instance_name = Ident.new(expect(:ident).data)
      expect :lpar
      maybe :new_line

      if showNext.kind == :rpar
        port_map = nil
        expect :rpar
        expect :semicolon
        expect :new_line
      else
        port_map = parse_portmap
      end

      Verilog::Instance.new(module_name, instance_name, port_map)
    end

    def parse_portmap
      elements = []
      until showNext.kind == :semicolon
        expect :dot
        port_inst = Verilog::Ident.new(expect(:ident).data)
        expect :lpar
        sig_mod = Verilog::Ident.new(expect(:ident).data)
        expect :rpar
        maybe :new_line
        last = expect :coma, :rpar
        if last.kind == :coma 
          maybe :new_line
        end
        elements << PortMapElement.new(port_inst, sig_mod)
      end
      expect :semicolon
      expect :new_line

      PortMap.new(elements)
    end
  end
end
