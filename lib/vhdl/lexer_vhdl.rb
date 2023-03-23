#! /usr/env/bin ruby

require_relative 'ast_vhdl.rb'

module VHDL
    class Lexer
        attr_accessor :tokens

        def initialize
            @tokens = []
        end

        def tokenize str
            @tokens=[]
            num_line = 1
            while str.size > 0
                case str
                    when /\A\n/
                        @tokens << VHDL::AST::Token.new(:new_line, $&, num_line)
                        num_line += 1
                    when /\A\s/
                    when /\Aentity/
                        @tokens << VHDL::AST::Token.new(:entity, $&, num_line)
                    when /\Ais/
                        @tokens << VHDL::AST::Token.new(:is, $&, num_line)
                    when /\Aend/ 
                        @tokens << VHDL::AST::Token.new(:end, $&, num_line)
                    when /\A;/
                        @tokens << VHDL::AST::Token.new(:semicol, $&, num_line)
                    when /\Aarchitecture/
                        @tokens << VHDL::AST::Token.new(:architecture, $&, num_line)
                    when /\Aof/
                        @tokens << VHDL::AST::Token.new(:of, $&, num_line)
                    when /\Asignal /
                        @tokens << VHDL::AST::Token.new(:signal, $&, num_line)
                    when /\Abegin/
                        @tokens << VHDL::AST::Token.new(:begin, $&, num_line)
                    when /\Aport map/
                        @tokens << VHDL::AST::Token.new(:port_map, $&, num_line)
                    when /\Aport/
                        @tokens << VHDL::AST::Token.new(:port, $&, num_line)
                    when /\A\(/
                        @tokens << VHDL::AST::Token.new(:o_parent, $&, num_line)
                    when /\A\)/
                        @tokens << VHDL::AST::Token.new(:c_parent, $&, num_line)
                    when /\A\:/
                        @tokens << VHDL::AST::Token.new(:colon, $&, num_line)
                    when /\Ain/
                        @tokens << VHDL::AST::Token.new(:in, $&, num_line)
                    when /\Aout/
                        @tokens << VHDL::AST::Token.new(:out, $&, num_line)
                    when /\Abit_vector\(\d+ downto \d+\)/
                        @tokens << VHDL::AST::Token.new(:type, $&, num_line)
                    when /\Abit/ 
                        @tokens << VHDL::AST::Token.new(:type, $&, num_line)
                    when /\A<=/
                        @tokens << VHDL::AST::Token.new(:assign_sig, $&, num_line)
                    when /\Aand/
                        @tokens << VHDL::AST::Token.new(:operator, $&, num_line)
                    when /\Aor/
                        @tokens << VHDL::AST::Token.new(:operator, $&, num_line)
                    when /\Axor/
                        @tokens << VHDL::AST::Token.new(:operator, $&, num_line)
                    when /\Anand/
                        @tokens << VHDL::AST::Token.new(:operator, $&, num_line)
                    when /\Anor/
                        @tokens << VHDL::AST::Token.new(:operator, $&, num_line)
                    when /\Anot/
                        @tokens << VHDL::AST::Token.new(:operator, $&, num_line)
                    when /\A\:/
                        @tokens << VHDL::AST::Token.new(:colon, $&, num_line)
                    when /\A\./
                        @tokens << VHDL::AST::Token.new(:namespace_sep, $&, num_line)
                    when /\Ageneric map/
                        @tokens << VHDL::AST::Token.new(:gen_map, $&, num_line)
                    when /\A=>/
                        @tokens << VHDL::AST::Token.new(:arrow, $&, num_line)
                    when /\A\,/
                        @tokens << VHDL::AST::Token.new(:coma, $&, num_line)
                    when /\A[a-zA-Z]+(\w)*\b/ # Placed at the end of the case statement because other "kinds" could satisfy the regexp
                        @tokens << VHDL::AST::Token.new(:ident, $&, num_line)
                    else
                        raise "Encountered unknown expression : #{str[0..-1]}"
                end
                str.delete_prefix!($&)
            end
            @tokens
        end
        
    end
end

# Unit test 

# if $PROGRAM_NAME==__FILE__
#     txt=IO.read("./vhdl/test.vhd")
#     pp VHDL::Lexer.new.tokenize txt
# end