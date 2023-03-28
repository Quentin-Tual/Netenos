module Netlist

    class ConvNetlist2Vhdl
        # * : Convert a Netlsit to a Vhdl not decorated AST.
        # * : Then it will need to be visited to decorate it and verify its correctness.
        # * : Finally the decorated AST will be ready to be deparsed to recover a VHDL source code file (structural). 

        def initialize netlist = nil
            @netlist = netlist
            @ast = VHDL::AST::Root.new
        end

        def to_Ident str   
            return VHDL::AST::Ident.new(VHDL::AST::Token.new(:ident, str))
        end

        def get_ast netlist
            conv netlist
            @ast = VHDL::Visitor.new.visitAST @ast
            return @ast
        end

        def get_vhdl netlist
            conv netlist
            @ast = VHDL::Visitor.new.visitAST @ast 
            return VHDL::DeParser.new(@ast).deparse
        end

        def to_Ident str   
            return VHDL::AST::Ident.new(VHDL::AST::Token.new(:ident, str))
        end

        def conv netlist = nil
            if !netlist.nil?
                @netlist = netlist
            elsif @netlist.nil?
                raise "Error : No netlist to convert."
            end
            
            convEntity # * : Entity Declaration
            @ast.architectures = [VHDL::AST::Architecture.new(
                to_Ident("enoslist"), 
                to_Ident(@netlist.name),
                convSignalDeclaration,
                convInstantiateStatements.concat(convWiring) # * : Joins InstantiateStatements and AssignStatements together
            )]

            return @ast
        end

        def convEntity # * : Entity Declaration
            @ast.entity = VHDL::AST::Entity.new(
                to_Ident(@netlist.name), 
                @netlist.ports.values.flatten.collect{|p| convPort p}
            )
        end

        def convPort p # * : Port Declaration
            name = to_Ident(p.name)
            port_type = p.direction.to_s
            data_type = VHDL::AST::Type.new("bit")

            return VHDL::AST::Port.new(name, port_type, data_type)
        end

        def convSignalDeclaration # * : Signal Declaration
            if @netlist.wires != []
                return @netlist.wires.collect do |w| 
                VHDL::AST::SignalDeclaration.new(
                    to_Ident(w.name),
                    VHDL::AST::Type.new("bit")
                )
                end
            else
                return []
            end
        end

        def convInstantiateStatements # * : Instantiate Statement
            components = @netlist.components.select do |inst|
                !inst.is_a? Gate
            end

            return components.collect do |comp|
                comp_name = to_Ident(comp.name.split('_')[0])
                ent_name = to_Ident(comp.name.split('_')[1])
                lib_name = to_Ident("work") # ! : Ici Work par défaut en lib mais à voir comment faire évoluer cette partie à l'avenir si ajout de lib perso
                # ? : Conversion d'une lib vhdl en lib rb avec les classes de comp déclarée ?  
                arch_name = to_Ident("enoslist")

                statement = VHDL::AST::InstantiateStatement.new(comp_name, ent_name, arch_name, lib_name, convPortMap(comp))
            end
        end

        def convPortMap comp # * : Port Map(Association Statements)
            association_statements = []
            comp.get_ports.each do |p|
                if p.is_input?
                    to_unplug = p.get_source
                    association_statements << VHDL::AST::AssociationStatement.new(
                        to_Ident(p.name), 
                        to_Ident(to_unplug.name)
                    )
                    p.unplug(to_unplug.name)
                else
                    to_unplug = p.get_sinks[0]
                    association_statements << VHDL::AST::AssociationStatement.new(
                        to_Ident(p.name), 
                        to_Ident(to_unplug.name)
                    )
                    to_unplug.unplug(p.name)
                end
            end

            return VHDL::AST::PortMap.new(association_statements)
        end

        def convWiring
            statements = []

            # * : Global entries wiring
            @netlist.get_inputs.each do |p|
                p.get_sinks.each do |sink|
                    statements << VHDL::AST::AssignStatement.new(
                        to_Ident(sink.name),
                        to_Ident(p.name) 
                    )

                    sink.unplug(p.name)
                end
            end

            # * : Gates wiring (Converted into Binary or Unary Expressions)
            @netlist.components.each do |comp|
                if comp.is_a? Gate
                    # ! : Voir si possible d'optimiser le découpage du nom (ajout d'un caractère deséparation '_' ?)
                    operator = comp.name.split(/(?<=[A-Za-z])(?=\d)/)[0].downcase # * : Retrieve the gate type only without the object ID
                    if operator != "Not" # BinaryExp
                        statements << convBinaryExp(comp, operator)
                    else # UnaryExp
                        statements << convUnaryExp(comp, operator)
                    end
                end
            end

            # *: Wires equivalent to Signals assignments 
            if @netlist.wires != []
                @netlist.wires.each do |w|
                    w.get_sinks.each do |sink|
                        statements << VHDL::AST::AssignStatement.new(
                            to_Ident(sink.name), 
                            to_Ident(w.name)
                        )
                        w.unplug sink.name
                    end
                end
            end

            return statements
        end

        def convUnaryExp comp, operator
            i1 = comp.get_inputs[0]
            operand_name = i1.get_source.name
            o1 = comp.get_outputs[0]
            dest_name = o1.get_sinks[0].name
        
            i1.unplug operand
            o1.unplug dest

            return VHDL::AST::AssignStatement.new( 
                to_Ident(dest_name),
                VHDL::AST::UnaryExp.new(
                    VHDL::AST::Operator.new(operator), 
                    to_Ident(operand_name), 
                    VHDL::AST::Type.new("bit")
                )
            )
        end

        def convBinaryExp comp, operator
            i1, i2 = comp.get_inputs
            operand1_name, operand2_name = i1.get_source.name, i2.get_source.name
            dest = comp.get_outputs[0].get_sinks[0]
            dest_name = dest.name

            i1.unplug operand1_name
            i2.unplug operand2_name
            dest.unplug comp.get_outputs[0].name

            return VHDL::AST::AssignStatement.new(   
                to_Ident(dest_name), 
                VHDL::AST::BinaryExp.new(
                    to_Ident(operand1_name), 
                    VHDL::AST::Operator.new(operator), 
                    to_Ident(operand2_name), 
                    VHDL::AST::Type.new("bit")
                )
            )
        end

    end

end
