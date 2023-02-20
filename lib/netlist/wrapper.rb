require_relative 'circuit.rb'
require_relative 'netson.rb'

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
            # WIP
            puts "      | ----- WIP ----- | "
            # TODO : Lire le fichier et le parser à l'aide d'Hyle, la conversion decorated_AST (Hyle) vers la netlist Enoslist est à terminer en amont.
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
            # WIP
            # TODO : Convertir en VHDL à l'aide d'Hyle, la conversion de la netlist Enoslist vers un decorated_AST (Hyle) est à terminer en amont.
            puts "WIP"
        end

        def store_dot path
            if path.nil?
                Netlist::DotGen.new.dot @netlist
            else
                Netlist::DotGen.new.dot @netlist, path
            end

        end

        # * : ------ Operation methods ------ :

            # WIP

        # * : ------ Other methods ------ : 
        def show path
            self.store_dot "./~#{@netlist.name}.dot"
            `xdot ./~#{@netlist.name}.dot`
        end

    end

end
