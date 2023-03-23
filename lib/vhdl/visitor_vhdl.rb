#! /usr/env/bin ruby    

require_relative 'ast_vhdl.rb'

module VHDL

    class Visitor 
        # Visitor's goal is to decorate the given AST and detect any contextual error, including type errors.
        attr_accessor :id_tab, :ent_name, :actual_lib

        def initialize
            @id_tab = Hash.new # Peut-être préférable d'avoir une table différentes pour chaque famille : les entités, les architectures, les ports, les signaux, voire d'autres. 
            @actual_lib = VHDL::AST::Work.new 
        end

        def exportDecAst path
            # export de l'ast décoré donc toutes les entités concernées, certaines pouvant être dans la lib.
            f = File.new(path, "wb")
            f.puts(Marshal.dump([@id_tab, ent_name]))
            f.close
        end

        def visitAST ast
            #print "Contextual analysis........"

            @actual_lib.import
            
            visitEntity ast.entity
            ast.architectures.each{|arch| visitArch arch}

            @actual_lib.add ast.entity
            @actual_lib.export

            #puts "OK"
            #puts "Contextual analysis succesfully terminated !"
            return ast
        end
        
        def visitEntity subAst
            @ent_name = subAst.name.name
            @id_tab[subAst.name.name] = subAst
            visitPorts subAst.ports 
        end

        def visitPorts subAst
            subAst.each{|e| visitPort e}
        end
        
        def visitPort subAst
            @id_tab[subAst.name.name] = subAst
        end

        def visitArch subAst
            subAst.entity = @id_tab[subAst.entity.name]
            if subAst.entity.architectures == nil
                subAst.entity.architectures = [subAst]
            else    
                subAst.entity.architectures << subAst
            end
            visitArchDecl subAst.decl
            visitArchBody subAst.body
            clear_SignalDeclaration
        end

        def clear_SignalDeclaration # Allow to reset context between two architecture visit
            @id_tab.each_pair{|key, value| 
                if value.class == VHDL::AST::SignalDeclaration
                    @id_tab.delete(key)
                end
            }
        end

        def visitArchDecl subAst
            # pp subAst
            subAst.each{ |line|
                visitDecl line
            }
        end

        def visitDecl exp
            case exp
            when VHDL::AST::SignalDeclaration
                visitSignalDeclaration exp
            else
                raise "Internal Error : Parsing incorrect, unknown declaration sequence"
            end
        end

        def visitSignalDeclaration exp
            if @id_tab[exp.name.name].nil?
                @id_tab[exp.name.name] = exp
            else
                raise "Error : Name already known as #{@id_tab[exp.name.name]}.\n -> #{exp.name.token.line}"
            end
        end

        def visitArchBody subAst
            subAst.each { |line|
                visitExp line
            }
        end

        def visitInstantiateStatement exp
            if exp.lib.name == "work"
                exp.entity = @actual_lib.entities[exp.entity.name]
                @id_tab[exp.name.name] = exp.entity
                @id_tab[exp.entity.name.name] = exp.entity
                exp.entity.ports.each{|p| @id_tab["#{exp.name.name}:#{p.name.name}"] = p}
                exp.arch = exp.entity.architectures.select{ |arch|
                    arch.name.name == exp.arch.name
                } 
                if exp.arch == []
                    raise "Error : Architecture not found for instanciation of #{exp.name}."
                elsif exp.arch.length > 1 
                    # ! : Possible ça ? à voir mais sûrement inutile
                    raise "Error : Multiple architectures found in entity #{exp.entity.name} for instanciation of #{exp.name}."
                else 
                    exp.arch = exp.arch[0]
                end

            else
                raise "Error : Only \"work\" library allowed in the current version. See #{exp.name} instance declaration of entity #{exp.entity}."
            end
            visitPortMap exp.port_map, exp.name.name
        end

        def visitPortMap exp, ent
            exp.association_statements.each{|statement| 
                # Decorate the AST replacing names by references to objects from work lib
                # Test data and port type validity for port_map expression.
                visitAssociateStatement statement, ent
            }
        end

        def visitExp exp
            # Contextual verification
            # Also replaces name by references link between objects
            case exp
            when VHDL::AST::AssignStatement
                visitAssignStatement exp
            when VHDL::AST::InstantiateStatement
                visitInstantiateStatement exp
            else
                raise "Error : unknown expression in architecture body"
            end
        end

        def visitUnaryExp exp, ret_type
            exp.operand.decl = @id_tab[exp.operand.name]
            exp.ret_type = ret_type
        end

        def visitBinaryExp exp, ret_type
            exp.operand1.decl = @id_tab[exp.operand1.name]
            exp.operand2.decl = @id_tab[exp.operand2.name]
            exp.ret_type = ret_type 
        end

        def visitAssignStatement statement

            case statement.source
            when VHDL::AST::Ident
                testTypeValidity statement
                statement.dest.decl = @id_tab[statement.dest.name] 
                statement.source.decl = @id_tab[statement.source.name]
            when VHDL::AST::UnaryExp
                visitUnaryExp statement.source, testTypeValidity(statement)
                statement.dest.decl = @id_tab[statement.dest.name] 
            when VHDL::AST::BinaryExp
                visitBinaryExp statement.source, testTypeValidity(statement)
                statement.dest.decl = @id_tab[statement.dest.name]
            end
            
        end

        def visitAssociateStatement statement, ent
            
            testTypeValidity statement, ent
            statement.dest.decl     = @id_tab[ent].ports.select{|p| p.name.name == statement.dest.name}[0]
            statement.source.decl   = @id_tab[statement.source.name] 

        end

        def testTypeValidity exp, ent = nil
            case exp # Different conditions for a valid expression, also different form to test (match it up in the future)
            when VHDL::AST::AssociationStatement  
                if @id_tab["#{ent}:#{exp.dest.name}"].data_type == @id_tab[exp.source.name].data_type
                    if (@id_tab["#{ent}:#{exp.dest.name}"].class == VHDL::AST::Port and @id_tab[exp.source.name].class == VHDL::AST::Port) 
                        if (@id_tab["#{ent}:#{exp.dest.name}"].port_type != @id_tab[exp.source.name].port_type)
                            raise "Error : ports #{exp.dest.name} and #{exp.source.name} are from same port type and can't be wired together.\n -> #{exp.dest.token.line}"
                        end
                    end
                else 
                    raise "Error : ports #{exp.dest.name} and #{exp.source.name} don't ave the same data_type and can't be wired together.\n -> #{exp.dest.token.line}"
                end
            when VHDL::AST::AssignStatement
                
                if exp.source.class == VHDL::AST::BinaryExp
                    testTypeValidity exp.source
                elsif exp.source.class == VHDL::AST::UnaryExp
                    testTypeValidity exp.source
                elsif @id_tab[exp.dest.name].data_type == @id_tab[exp.source.name].data_type
                    # TODO : Voir pour bouger le contenu de ce branchement en l'état dans une fonction visitUnaryExp
                    if (@id_tab[exp.dest.name].class == VHDL::AST::Port) and (@id_tab[exp.dest.name].port_type != "out")
                            raise "Error : ports #{exp.dest.name} and #{exp.source.name} are from same port type and can't be wired together.\n -> #{exp.dest.token.line}"
                    end
                else
                    raise "Error : #{exp.dest.name} and #{exp.source.name} don't have the same data_type and can't be wired together.\n -> #{exp.dest.token.line}"
                end
            when VHDL::AST::UnaryExp
                return @id_tab[exp.operand.name].data_type.type_name
            when VHDL::AST::BinaryExp
                op_type = [@id_tab[exp.operand1.name].data_type.type_name,@id_tab[exp.operand2.name].data_type.type_name]
                if $DEF_OP_TYPES[exp.operator.op].include?(op_type)
                    return $DEF_OP_RET_TYPES[exp.operator.op][op_type]
                else
                    raise "Error : #{exp.operand1} and #{exp.operand2} don't match types expected with operator #{exp.operator} and can't be wired together (got #{@id_tab[exp.operand1.name].data_type} #{exp.operator} #{@id_tab[exp.operand2.name].data_type}).\n -> #{exp.operand1.token.line}"
                end
            end
        end
    end
end