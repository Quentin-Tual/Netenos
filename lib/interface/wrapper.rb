# require_relative "../netlist.rb"
# require_relative "../vhdl.rb"
# require_relative "../converter.rb"
# require_relative "../inserter/tamper.rb"

module Netlist

    class Wrapper
        attr_accessor :netlist
        
        def initialize netlist = nil
            @netlist = netlist
        end

        def get_name
            return @netlist.name
        end

        # * : ------ Import methods ------ :
        def import path
            format = self.parse_path(path)[:ext]

            case format 
            when "json"
                self.load_json path
            when "enl"
                self.load_def path
            when "vhdl"
                self.load_vhdl path
            when "vhd"
                self.load_vhdl path
            else
                raise "Error : Unknown import format type : \"#{format}\". Allowed format for an import : json, enl, vhdl."
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
            # ! : Optimisation possible en modifiant ConvVhdl2Netlist pour accepter un ast décoré en argument du constructeur de manière optionnel pour garder une utilité à la fonction load et éventuellement intéressant à l'avenir.
            visitor.exportDecAst "#{$DEF_TEMP_PATH}~.ast"
            # Chargement de l'AST en sortie de Hyle
            vhdl_converter = Netlist::ConvVhdl2Netlist.new
            vhdl_converter.load "#{$DEF_TEMP_PATH}~.ast"
            @netlist = vhdl_converter.convAst
        end

        def randgen parameters
            if parameters.length > 1
                generator = Netlist::RandomGenComb.new parameters[1].to_i, parameters[2].to_i, parameters[3].to_i, parameters[4].to_i
            else
                generator = Netlist::RandomGenComb.new
            end
            @netlist = generator.getRandomNetlist self.parse_path(parameters[0])[:filename]
            return generator.getNetlistInformations
        end

        # * : ------ Export methods ------ : 
        def export path, format
            case format 
            when "json"
                self.store_json path
            when "enl"
                self.store_def path
            when "vhdl"
                self.store_vhdl path
            when "dot"
                self.store_dot path
            else
                raise "Error : Unknown export format type : \"#{format}\". Allowed format for an export : json, enl, vhdl, dot."
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
        def show
            self.store_dot "#{$DEF_TEMP_PATH}~#{@netlist.name}.dot"
            `xdot #{$DEF_TEMP_PATH}~#{@netlist.name}.dot`
        end

        def parse_path path
            tmp = path.split '/'
            filename, ext = tmp[-1].split('.')
            tmp.pop
            path_dir = ""
            tmp.each{|dir| path_dir = path_dir+dir+'/'}

            path_dir = path_dir.nil? ? "" : path_dir
            filename = filename.nil? ? "" : filename
            ext = ext.nil? ? "" : ext
            
            return {:dir => path_dir,
                    :filename => filename, 
                    :ext => ext}
        end

    end

end
