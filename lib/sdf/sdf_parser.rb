module SDF
  class Parser
    # def initialize
    #   @h = Hash.new
    #   @current_pos = h
    #   @block_stack = [] # Stack
    #   # @level = 0
    #   @line = 0
    # end

    def parse(path)
      root = Root.new(path)
      @tokens = Lexer.new.lexify(path)

      root.add parse_delayfile
      root
    end

    def acceptIt
      @tokens.shift
    end

    def showNext
      lookAhead 1
    end

    def lookAhead(n)
      @tokens[n - 1]
    end

    def expect(kind)
      if (actual = showNext.kind) != kind
        raise "ERROR at #{showNext.num_line}. Expecting #{kind}. Got #{actual}"
      else
        acceptIt
      end
    end

    def parse_delayfile
      expect :lpar
      expect :delayfile
      delayfile = DELAYFILE.new
      expect :new_line
      parse_nocareheader until lookAhead(2).kind == :design
      delayfile.add parse_design
      parse_nocareheader until lookAhead(2).kind == :timescale
      delayfile.add parse_timescale
      delayfile.add parse_cell until showNext.kind == :rpar
      expect :rpar

      delayfile
      # expect :new_line # ? check if mandatory, can be ignored cause delayfile is closed with last right parenthesis
    end

    def parse_nocareheader
      expect :lpar
      acceptIt
      expect :rpar
      expect :new_line
    end

    def parse_design
      expect :lpar
      token = expect :design
      expect :rpar
      expect :new_line

      DESIGN.new(@design_name = token.data.split(' ')[1].tr('"', ''))
    end

    def parse_timescale
      expect :lpar
      token = expect :timescale
      expect :rpar
      expect :new_line

      TIMESCALE.new(Time.new(token.data.split(' ')[1]))
    end

    def parse_cell
      expect :lpar
      expect :cell
      expect :new_line

      node = CELL.new
      node.add parse_celltype
      node.add parse_instance
      node.add parse_delay

      expect :rpar
      expect :new_line

      node
    end

    def parse_celltype
      expect :lpar
      token = expect :celltype
      expect :rpar
      expect :new_line

      i = token.data.index(/"\w+"/) + 1 # +1 to get rid of opening double quote
      celltype = token.data[i...-1] # -1 to get rid of the closing double quote

      CELLTYPE.new(celltype)
    end

    def parse_instance
      expect :lpar
      token = expect :instance
      expect :rpar
      expect :new_line

      instance = Ident.new(token.data.split(' ')[1].to_s)
      INSTANCE.new(instance)
    end

    def parse_delay
      expect :lpar
      expect :delay
      expect :new_line

      node = DELAY.new
      node.add parse_absolute until showNext.kind == :rpar

      expect :rpar
      expect :new_line

      node
    end

    def parse_absolute
      expect :lpar
      expect :absolute
      expect :new_line

      node = ABSOLUTE.new
      until showNext.kind == :rpar
        next_block = lookAhead(2).kind
        if next_block == :interconnect
          node.add parse_interconnect
        elsif next_block == :iopath
          node.add parse_iopath
        else
          raise "Error: Unexpected sequence encountered #{showNext}."
        end
      end
      expect :rpar
      expect :new_line

      node
    end

    def parse_interconnect
      expect :lpar
      token = expect :interconnect
      expect :rpar
      expect :new_line

      w, d = parse_delaynode(token)
      INTERCONNECT.new(w, d)
    end

    def parse_iopath
      expect :lpar
      token = expect :iopath
      expect :rpar
      expect :new_line

      w, d = parse_delaynode(token)
      IOPATH.new(w, d)
    end

    def parse_delaynode(token)
      data = token.data.split(' ')[1..]
      w = Wire.new(
        Ident.new(data[0]),
        Ident.new(data[1])
      )
      d = DelayTable.new(
        DelayArray.new(data[2]),
        DelayArray.new(data[3])
      )

      [w, d]
    end
  end
end
