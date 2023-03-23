#! /usr/env/bin ruby    

require_relative 'lexer_vhdl.rb'

module VHDL
    
    class Parser

        def initialize
            @tokens = nil
            @ast = nil
        end

        def parse tokens
            #print "Lexical verification......."
            @tokens = tokens
            # pp @tokens # Uncomment for debug
            #puts "OK"
            #print "Parsing...................."
            @ast = AST::Root.new(parse_entity, parse_architectures)
            #puts "OK"
            #puts "Parsing succesfully terminated !"
            @ast
        end

        def parse_entity
            expect :entity
            ret = AST::Entity.new(AST::Ident.new(expect(:ident)), parse_ports)
            expect :semicol
            expect :end
            expect :ident
            expect :semicol
            del_next_new_line
            ret
            # Note : si on souhaite stocker la ou les architectures de l'entité dans cet objet, il est impossible de le faire ici. Il sera nécessaire de décorer l'AST avec une seconde passe ou lors de l'analyse de contexte.
        end

        def parse_ports
            expect :is
            if expect :port                
                expect :o_parent
                ports = []
                while show_next.kind != :semicol # Boucle jusqu'à la fin de la déclaration des ports
                    name = VHDL::AST::Ident.new(expect(:ident))
                    expect :colon
                    port_type = expect(:in, :out).val 
                    data_type = VHDL::AST::Type.new(expect(:type).val)
                    expect :semicol, :c_parent # 2 possibilités au même instant, ne créant pas de nouvelle branche dans l'arbre de décision (fin de branchement/chemin parallèle)
                    ports.append(VHDL::AST::Port.new(name, port_type, data_type))
                end
                return ports
            end
        end

        def parse_architectures
            archs = []
            while show_next != nil
                if show_next.kind == :architecture
                    archs << parse_arch 
                else 
                    break
                end
            end
            return archs
        end

        def parse_arch
            expect :architecture
            name = AST::Ident.new(expect(:ident))
            expect :of
            ent = AST::Ident.new(expect(:ident))
            expect :is
            arch_decl = []
            until show_next.kind == :begin
                arch_decl << parse_arch_declarations
                del_next_new_line
            end
            expect :begin
            statements = []
            while show_next.kind != :end
                statements << parse_arch_body
            end 
            expect :end
            expect :architecture
            expect :semicol
            return AST::Architecture.new(name, ent, arch_decl, statements)
        end

        def parse_arch_declarations
                next_line = show_next_line
                next_line_kinds = next_line.collect {|x| x.kind}
                case next_line_kinds
                    in [:signal, :ident, :colon, :type, :semicol] # Comment faire si le type est un vecteur ? Faire contenir la taille dans la chaine de caractère associée au token semble une bonne solution, reste à voir comment extraire ça avec des regex
                        return VHDL::AST::SignalDeclaration.new(VHDL::AST::Ident.new(next_line[1]), VHDL::AST::Type.new(next_line[3].val))    
                    else
                        raise "Error : Not recognized declaration sequence -> #{next_line_kinds}"
                end
        end

        def parse_arch_body
            next_line = show_next_line
            next_line_kinds = next_line.collect {|x| x.kind}
            case next_line_kinds
                # Component instanciation
                in [:ident, :colon, :entity, *] 
                    name = AST::Ident.new(next_line[0])
                     # Gives the name of the Instantiated object
                    lib = AST::Ident.new(next_line[3]) # Gives the lib in which entity is declared
                    ent = AST::Ident.new(next_line[5]) # Gives the name of entity Instantiated
                    arch = AST::Ident.new(next_line[7]) # Gives the architectures name to use (if multiples declared in lib)
                    if show_next.kind == :gen_map
                        puts "WIP"
                    end
                    del_next_new_line
                    expect :port_map
                    port_map = AST::PortMap.new([])
                    expect :o_parent
                    # Loop until :c_parent instead of :coma
                    while show_next.kind != :semicol
                        a = AST::Ident.new(expect :ident) # Create an AssignStatement class object with these information
                        expect :arrow
                        b = AST::Ident.new(expect :ident)
                        port_map.association_statements << AST::AssociationStatement.new(a, b)
                        expect :coma, :c_parent
                    end
                    expect :semicol
                    ret = AST::InstantiateStatement.new(name, ent, arch, lib, port_map)
                # Signal/Port assignement 
                in [:ident, :assign_sig, :ident, :semicol]
                    # Only create an object, visitor object in charge of contextual analysis will then replace the names by actual instantiated Port objects.
                    # TODO : Voir si on ne met pas toujours une unary exp à la place de la source ici (un seul opérande et pas d'opération)
                    ret = VHDL::AST::AssignStatement.new(AST::Ident.new(next_line[0]), AST::Ident.new(next_line[2]))
                in [:ident, :assign_sig, :operator, :ident, :semicol]
                    ret = VHDL::AST::AssignStatement.new(AST::Ident.new(next_line[0]), parse_UnaryExp(next_line))
                in [:ident, :assign_sig, :ident, :operator, :ident, :semicol]
                    ret = VHDL::AST::AssignStatement.new(AST::Ident.new(next_line[0]), parse_BinaryExp(next_line))
            else
                raise "Error : Expecting architecture body expression. Received unknown expression.\n -> #{next_line[0].line} : #{next_line_kinds}"
            end 
            del_next_new_line
            return ret
        end

        def parse_UnaryExp exp
            if $DEF_OP.include?(exp[2].val)
                ret = VHDL::AST::UnaryExp.new(AST::Operator.new(exp[2].val), AST::Ident.new(exp[3]))
            else
                raise "Error : Unknown operator encountered #{exp[2].val}.\n -> #{exp[2].line}."
            end
        end

        def parse_BinaryExp exp
            if $DEF_OP.include?(exp[3].val)
                ret = VHDL::AST::BinaryExp.new(AST::Ident.new(exp[2]), VHDL::AST::Operator.new(exp[3].val), AST::Ident.new(exp[4]))
            else
                raise "Error : Unknown operator encountered #{exp[3].val}.\n -> #{exp[3].line}."
            end
        end

        def show_next_line
            
            ret = []
            until show_next.kind == :new_line
                ret << show_next 
                accept_it
            end

            return ret
        end

        def show_next
            @tokens.first # Renvoi le premier élément de la file (Array)
        end

        def accept_it
            @tokens.shift # supprime le premier élément de la file (Array)
        end

        def del_next_new_line
            while show_next != nil 
                if show_next.kind == :new_line
                    accept_it
                else 
                    return nil
                end
            end
        end

        def expect *expected_tok_kind # Arguments multiples sous forme d'Array
            del_next_new_line

            actual_kind = show_next.kind

            if expected_tok_kind.include? actual_kind
                ret = accept_it
            else 
                raise "ERROR : expecting token #{expected_tok_kind}. Received #{actual_kind}."
            end

            del_next_new_line
            return ret
        end

        # TESTS Methods 
        def test_parse_arch_declarations tmp
            @tokens = tmp # Uncomment for the TEST
            parse_arch_declarations
        end

    end

end
