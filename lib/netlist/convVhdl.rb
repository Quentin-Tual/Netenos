

module Netlist

    # ! : Seul le type de données 'bit' est pris en compte dans un premier temps
    # ? : Table des correspondances ? (classes de l'AST vers les classes de la netlist)

    class ConvVhdl

        def initialize sym_tab = nil, ast = nil
            @sym_tab = sym_tab
            @ast = ast
            @netlist = nil
            @wire_table = {}
            @current_RTL_block = nil # Will change with instanciation statement, need some verification methods before to change it (complete all relations, emptying the @correlation_table) 
        end

        def load path
            if File.exists?(path)
                f = File.new(path, "rb")
                tmp = Marshal.load(f)
                @sym_tab = tmp[0]
                @ast = tmp[0][tmp[1]]
                f.close
            else 
                puts "Error : File not found."
            end
        end

        def convAst
            # TODO : Première fonction d'un visiteur qui parcout l'AST et construit la Netlist au fur et à mesure.
            # pp @ast # OK
            @netlist = convEntity @ast
            @current_RTL_block = @netlist
            convArch(@ast.architectures.select{|arch| arch.name.name=="enoslist"}[0])
    
            verify_wiring
            #convInstanciatedComponents

            return @netlist
        end

        # def convInstanciatedComponents
        #     # TODO : Faire la liaison et l'a conversion de l'architecture car le composant et ses ports sont déjà instanciés
        #     if !@current_RTL_block.components.empty?
        #         @current_RTL_block.components.each{|comp| 
        #             @current_RTL_block = comp
        #             # ! : Ici il faut aller chercher l'architecture associée à l'entité traitée uniquement et non toutes les architectures enregistrées dans l'AST
        #             # convArch(@sym_tab[@current_RTL_block.name].architectures.select{|arch| arch.name.name=="enoslist"}[0])
        #             # convInstanciatedComponents
        #         }
        #     end
            
        # end

        def convEntity entity
            # TODO : Instanciation du circuit 'global'
            ret = Netlist::Circuit.new(entity.name.name)
            ports = convPorts entity.ports
            ports.each{ |p|
                ret << p
            }
            return ret
        end

        def convPorts ports
            ret = ports.collect{|p| convPort p}
            return ret
        end

        def convPort port
            # ? : Possibilité d'instancier les ports et de les remonter au circuit global par retour de fonction. Cependant légèrement plus complexe pour le test.
            return Netlist::Port.new(port.name.name, port.port_type.to_sym)
        end
    
        def convArch arch
            convArchDecl arch.decl
            @current_RTL_block.components.concat(convArchBody(arch.body))
        end

        def convArchDecl archDecl
            archDecl.each{|declaration| 
                @wire_table[declaration.name.name] = Wire.new declaration.name.name
            }
        end

        def convArchBody archBody
            components = []

            archBody.each{|statement| 
                case statement
                when VHDL::AST::AssignStatement
                    tmp = convAssignStatement(statement)
                    if !tmp.nil?
                        components << tmp
                    end 
                when VHDL::AST::InstantiateStatement
                    components << convInstantiateStatement(statement)
                else
                    raise "Error : Unknown statement in architecture body." # TODO : Voir pour ajouter plus d'éléments contextuels au message d'erreur
                end
            }

            return components
        end

        def find_interface interface_name 
        # * : Returns the port or wire corresponding to the name passed
            if @wire_table.keys.include?(interface_name)
                return @wire_table[interface_name]
            else 
                return @netlist.get_port_named(interface_name)
            end

        end

        def wiring sink_name, source_name
            sink = find_interface sink_name
            source = find_interface source_name

            sink <= source
        end

        def convAssignStatement assignStatement
            ret = nil
            
            case assignStatement.source
            when VHDL::AST::UnaryExp
                ret = convOperator exp.operator.op
                ret.partof = @netlist
                ret.get_port_named("i0") <= find_interface(assignStatement.source.operand.name) 
                find_interface(assignStatement.dest.name) <= ret.get_port_named("o0")
            when VHDL::AST::BinaryExp
                ret = convBinaryExp assignStatement.source 
                find_interface(assignStatement.dest.name) <= ret.get_port_named("o0")
            else 
                wiring(assignStatement.dest.name, assignStatement.source.name)
            end

            return ret
        end

        def convBinaryExp exp # * : Retourne l'opérateur/la porte instanciée
            op = convOperator exp.operator.op
            op.partof = @netlist

            op.get_port_named("i0") <= find_interface(exp.operand1.name)
            op.get_port_named("i1") <= find_interface(exp.operand2.name) 

            return op
        end

        def convOperator op # * : Retourne l'opérateur instancié
            case op
            when "and"
                return Netlist::And.new
            when "or"
                return Netlist::Or.new
            when "xor"
                return Netlist::Xor.new
            when "not"
                return Netlist::Not.new
            when "nand"
                return Netlist::Nand.new
            when "nor"
                return Netlist::Nor.new
            else 
                raise "Error : unknown operator encountered : #{op}"
            end
        end

        def convInstantiateStatement instanciateStatement # ! : Devra retourner le composant instancié
            # name et partof récupérable dès le départ
            # PortMap pour les ports
            # l'attribut components restera vide (nil) à moins que l'entité instanciée possède un InstanciateStatement dans son architecture

            inst = convEntity(@sym_tab[instanciateStatement.name.name])
            inst.name = instanciateStatement.name.name
            inst.partof = @netlist
            convPortMap instanciateStatement.port_map, inst

            # TODO : Lancer la conversion de l'entité instanciée maintenant pour instancier les ports et le composant. Cependant attention à ne pas réécrire la table des symboles
            # TODO : Lancer la conversion de l'architecture plus tard pour les liaisons
            return inst
        end

        def convPortMap portmap, component
            portmap.association_statements.each{ |associationStatement|
                convAssociationStatement associationStatement, component
            }
        end

        def convAssociationStatement associationStatement, component
            # port = Port.new(associationStatement.dest.name, associationStatement.dest.decl.port_type.to_sym, component)
            # component << port
            port = component.get_port_named(associationStatement.dest.name)

            if port.is_input? 
                port <= find_interface(associationStatement.source.name)
            else 
                find_interface(associationStatement.source.name) <= port 
            end
            
        end

        def verify_wiring
            # * : Post conversion verification to avoid specific states
            @netlist.get_outputs.each do |output_port|
                if !output_port.fanout.empty?
                    # TODO : Remplacer les fanin visés par le fanout par le fanin du port courant
                    output_port.fanout.each do |targeted_interface|
                        targeted_interface.fanin = nil
                        targeted_interface <= output_port.fanin
                    end
                    output_port.fanout = []
                    # TODO : Remplacer le fanout par nil
                end
            end
        end

    end

end