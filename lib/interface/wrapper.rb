require_relative '../netlist/circuit.rb'
require_relative '../converter/netson.rb'
require_relative '../vhdl.rb'

module Netlist

    class Wrapper
        
        def initialize name
            @name = name
            @netlist = nil
        end

        # * : ------ Import methods ------ :
        def import path, format
            case format 
            when "json"
                self.load_json path
            when "def"
                self.load_def path
            when "vhdl"
                self.load_vhdl path
            end
        end

        def load_json path
            @netlist = Netlist::Netson.new.load path
        end

        def load_def path
            file = IO.read(path)
            @netlist = Marshal.load(file)
        end

        def load_vhdl path
            # Lancer Hyle et récupérer l'AST (stocké en Marshal)
            txt = IO.read(path)
            ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
            visitor = VHDL::Visitor.new
            decorated_ast = visitor.visitAST ast
            visitor.exportDecAst "/tmp/~.ast"
            # Chargement de l'AST en sortie de Hyle
            vhdl_converter = Netlist::ConvVhdl2Netlist.new
            vhdl_converter.load "/tmp/~.ast"
            @netlist = vhdl_converter.convAst
        end

        # * : ------ Export methods ------ : 
        def export path, format
            case format 
            when "json"
                self.store_json path
            when "def"
                self.store_def path
            when "vhdl"
                self.store_vhdl path
            when "dot"
                self.store_dot path
            end
        end

        def store_json path
            Netlist::Netson.new.save_as_json @netlist, path
        end

        def store_def path
            File.write(path, Marshal.dump(@netlist))
        end

        def store_vhdl path
            src = Netlist::ConvNetlist2Vhdl.new.get_vhdl @netlist 
            File.write(path, src)
        end

        def store_dot path
            if path.nil?
                Netlist::DotGen.new.dot @netlist
            else
                Netlist::DotGen.new.dot @netlist, path
            end

        end

        # * : ------ Operation/manipulation methods ------ :

            # WIP

        # * : ------ Other methods ------ : 
        def show path
            self.store_dot "/tmp/~#{@netlist.name}.dot"
            `xdot /tmp/~#{@netlist.name}.dot`
        end

    end

end
