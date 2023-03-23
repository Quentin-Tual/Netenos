

module VHDL 

    # ? : Surement possible de faire quelque chose de plus propre avec un hash ayant comme clé le type et comme valeur le keyword langage à insérer dans le code générer. Avantage : Avoir tous les keywords langages au même endroit -> plus ranger et clean mais à voir si vraiment utile.

    class DeParser
        attr_reader :dec_ast, :str
        
        def initialize dec_ast
            @dec_ast = dec_ast
            @str = ""
        end

        def deparse 
            @str << deparse_entity(@dec_ast.entity)
            @dec_ast.architectures.each{ |a|
                @str << deparse_arch(a)
            }
            return @str
        end

        def deparse_entity sub_ast
            tmp = "entity #{sub_ast.name.name} is\n"
            tmp << deparse_port(sub_ast.ports)
            tmp << "end #{sub_ast.name.name};\n\n"
        end

        def deparse_port sub_ast
            tmp = "\tport (\n"
            sub_ast.each{ |p|
                tmp << "\t\t#{p.name.name} : #{p.port_type} #{p.data_type.type_name};\n"
            }
            tmp.chop!.chop!
            tmp << "\n\t);\n"
        end

        def deparse_arch sub_ast
            tmp = "architecture #{sub_ast.name.name} of #{sub_ast.entity.name.name} is\n\n"
            # in theory, call here "deparse_arch_decl"
            tmp << deparse_arch_decl(sub_ast.decl)
            tmp << "begin\n\n"
            tmp << deparse_arch_body(sub_ast.body)  
            tmp << "end architecture;\n\n"
        end

        def deparse_arch_decl sub_ast
            tmp = ""
            if sub_ast != []
                sub_ast.each{ |d|
                    case d
                    when VHDL::AST::SignalDeclaration
                        tmp << "#{deparse_SignalDeclaration(d)}\n"
                    else
                        raise "Internal error : Unknwon statement type, corrupted AST"
                    end
                }
                tmp << "\n"
            end
            return tmp
        end

        def deparse_SignalDeclaration declaration
            tmp = "\tsignal #{declaration.name.name} : #{deparse_Type declaration.data_type};"
        end

        def deparse_Type type
            tmp = "#{type.type_name}"
            case tmp
            when "bit"
                return tmp # * : Nothing more to add then for signal declaration
            when "bit_vector" 
                tmp << "(#{type.size - 1} downto 0)"
            end
        end

        def deparse_arch_body sub_ast
            tmp = ""
            if sub_ast != []
                sub_ast.each{ |s|
                    case s
                    when VHDL::AST::InstantiateStatement
                        tmp << deparse_instantiateStatement(s)
                    when VHDL::AST::AssignStatement
                        tmp << deparse_AssignStatement(s)
                    else
                        raise "Internal error : Unknown statement type, corrupted AST."
                    end
                }
                tmp << "\n"
            end    
            return tmp        
        end

        def deparse_instantiateStatement statement
            tmp = "\t#{statement.name.name} : entity #{statement.lib.name}.#{statement.entity.name.name}(#{statement.arch.name.name})\n"
            tmp << deparse_portMap(statement.port_map)
        end

        def deparse_portMap port_map
            tmp = "\tport map (\n"
            tmp << deparse_associationStatement(port_map.association_statements) 
            tmp << "\t);\n"
        end

        def deparse_associationStatement association_statements
            tmp = ""
            association_statements.each{ |asso_state|
                tmp << "\t\t#{asso_state.dest.decl.name.name} => #{asso_state.source.decl.name.name},\n"
            }
            tmp.chop!.chop!
            tmp << "\n"
        end

        def deparse_AssignStatement statement
            # TODO : Ajouter un branchement pour les binaryExp (1 opérateur, 2 opérandes)
            case statement.source
            when VHDL::AST::UnaryExp
                tmp = "\t#{statement.dest.decl.name.name} <= #{deparse_UnaryExp statement.source};\n"
            when VHDL::AST::BinaryExp
                tmp = "\t#{statement.dest.decl.name.name} <= #{deparse_BinaryExp statement.source};\n"
            else
                tmp = "\t#{statement.dest.decl.name.name} <= #{statement.source.decl.name.name};\n"
            end
        end

        def deparse_UnaryExp exp
            tmp = "#{exp.operator.op} #{exp.operand.decl.name.name}"
        end

        def deparse_BinaryExp exp
            tmp = "#{exp.operand1.decl.name.name} #{exp.operator.op} #{exp.operand2.decl.name.name}"
        end 

        def save
            f = File.new("rev_#{dec_ast.entity.name.name}.vhd", "w")
            f.puts(@str)
            f.close
        end 

        def save_as path
            f = File.new(path, "w")
            f.puts(@str)
            f.close
        end
    end
end 