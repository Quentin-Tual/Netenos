require_relative '../enoslist.rb'

module Netlist

    class Wrapper
        attr_accessor :netlist
        
        def initialize 
            @netlist = nil
        end

        def get_name
            return @netlist.name
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
            visitor.exportDecAst "#{$DEF_TEMP_PATH}~.ast"
            # Chargement de l'AST en sortie de Hyle
            vhdl_converter = Netlist::ConvVhdl2Netlist.new
            vhdl_converter.load "#{$DEF_TEMP_PATH}~.ast"
            @netlist = vhdl_converter.convAst
        end

        def randgen parameters
            if parameters.length > 1
                generator = Netlist::RandomGen.new parameters[1].to_i, parameters[2].to_i, parameters[3].to_i, parameters[4].to_i
            else
                generator = Netlist::RandomGen.new
            end
            @netlist = generator.getRandomNetlist parameters[0]
            return generator.getNetlistInformations
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

        def tamper ht_type, trigger_signals_number = nil
            tamperer = Netlist::Tamperer.new(@netlist)
            tamperer.select_ht ht_type, trigger_signals_number
            @netlist = tamperer.insert
            @netlist.name = "#{@netlist.name}_tampered"
            return @netlist
        end

        # * : ------ Other methods ------ : 
        def show path
            self.store_dot "#{$DEF_TEMP_PATH}~#{@netlist.name}.dot"
            `xdot #{$DEF_TEMP_PATH}~#{@netlist.name}.dot`
        end

    end

end
