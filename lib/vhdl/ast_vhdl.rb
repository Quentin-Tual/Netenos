#! /usr/env/bin ruby

module VHDL
    module AST
        $DEF_LIB = ".work"
        $DEF_TYPES = ["bit", "/bit_vector\(\d+ downto \d+\)/"] # Defines the allowed types in the VHDL parsed 
        $DEF_TYPES_SIZES = {"bit" => 1}
        $DEF_OP = ["and", "or", "xor", "not", "nand", "nor"]
        $DEF_OP_TYPES = {
            "and" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "or" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "xor" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "not" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "nand" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "nor" => [["bit", "bit"],["bit_vector","bit_vector"]]
        }
        $DEF_OP_RET_TYPES = {
            "and" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "or" => {   ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "xor" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "not" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "nand" => { ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "nor" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"}
        }
        
        Token = Struct.new(:kind, :val, :line)

        Root                    =   Struct.new(*:entity, *:architectures)
        Entity                  =   Struct.new(:name, *:ports, *:architectures)
        Port                    =   Struct.new(:name, :port_type, :data_type)
        Architecture            =   Struct.new(:name, :entity, :decl, :body)
        PortMap                 =   Struct.new(*:association_statements)
        
        Ident                   =   Struct.new(:token, :decl) do 
            def name 
                self.token.val
            end
        end

        Type                    = Struct.new(:type_name,:size) do
            attr_reader :type_name, :size
            def initialize type_name
                if $DEF_TYPES.map{|ref| type_name.match?(ref)}.include?(true)
                    @type_name = type_name.split("(")[0]
                    if $DEF_TYPES_SIZES[type_name].nil? # If the size is not dermined by the type 
                        # * : \/ Parsing from vector size to bit size below \/
                        @size = type_name[/\d+/].to_i + 1 
                    else # Else, size for this type is known 
                        @size = $DEF_TYPES_SIZES[type_name]
                    end
                else
                    raise "Error : Unknown type #{type_name} encountered."
                end
            end

            def == e
                if (self.type_name == e.type_name) and (self.size == e.size)
                    return true
                else 
                    return false
                end
            end
        end
        Operator                =   Struct.new(:op)
        SignalDeclaration       =   Struct.new(:name, :data_type)

        AssociationStatement    =   Struct.new(:dest, :source)
        AssignStatement         =   Struct.new(:dest, :source)
        InstantiateStatement    =   Struct.new(:name, :entity, :arch, :lib, :port_map)

        UnaryExp                =   Struct.new(:operator, :operand, :ret_type)
        BinaryExp               =   Struct.new(:operand1, :operator, :operand2, :ret_type) 

        # Add behavioral expressions classes necessary to parse the architecture body


        class Work 
            # Current library, known entities are stored in it in the form of decorated ASTs.
            # "entities" attribute is Hash type variable containing known entities associated with their name as the hash key.
            attr_accessor :entities

            def initialize *ent
                @entities = {}
                if ent != []
                    ent.each{|e| @entities[e.name.name] = e}
                end
            end
        
            def export
                f = File.new($DEF_LIB, "wb")
                f.puts(Marshal.dump(self))
                f.close
            end

            def import
                if File.exists?($DEF_LIB)
                    f = File.new($DEF_LIB, "rb")
                    self.entities = Marshal.load(f).entities
                    f.close
                    return self.entities
                else 
                    puts "Warning : no default library found, a .work will be created."
                end
            end

            def add ent
                @entities[ent.name.name] = ent
            end

            def delete ent
                @entities.delete ent.name
            end

            def update ent
                self.import
                add ent
                self.export
            end
        end 
    end
end