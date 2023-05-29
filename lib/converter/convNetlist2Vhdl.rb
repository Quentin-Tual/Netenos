require './lib/vhdl.rb'

module Netlist

    class ConvNetlist2Vhdl
        # * : Convert a Netlsit to a Vhdl not decorated AST.
        # * : Then it will need to be visited to decorate it and verify its correctness.
        # * : Finally the decorated AST will be ready to be deparsed to recover a VHDL source code file (structural). 

        # TODO : Add a "library/use" in headers of the generated file
        # TODO : create a directory containing the vhdl generated and another directory in it with delayed operators package.

        def initialize netlist = nil
            @netlist = netlist
            @sig_tab = {}
            @ast = VHDL::AST::Root.new
            @timed = false
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

        def get_timed_vhdl netlist
            conv netlist, true
            @ast = VHDL::Visitor.new.visitAST @ast 
            return VHDL::DeParser.new(@ast).deparse
        end

        def to_Ident str   
            return VHDL::AST::Ident.new(VHDL::AST::Token.new(:ident, str))
        end

        def conv netlist = nil, timed = false
            if !netlist.nil?
                @netlist = netlist
            elsif @netlist.nil?
                raise "Error : No netlist to convert."
            end

            if timed 
                @timed = timed
                # TODO : Ajouter des headers dans l'AST
                # TODO : Nécessite d'ajouter le package "delayed operators" dans la lib actuel du visiteur donc dans le work d'Enoslist. 
                # TODO : Cela nécessitera d'abord de prendre en charge le parsing du 'after n [s]' donc pas mal de travail supplémentaire.
                raise "Error : WIP"
            end            
            
            if netlist.contains_registers?
                raise "Error : Given Netlist contains registers. Convertion in VHDL is not yet supported for sequential Netlists."
            end 

            convEntity # * : Entity Declaration
            @ast.architectures = [VHDL::AST::Architecture.new(
                to_Ident("enoslist"), 
                to_Ident(@netlist.name),
                convSignalDeclaration,
                convInstantiateStatements.concat(convWiring) # * : Joins InstantiateStatements and AssignStatements together
            )]

            @sig_tab.values.each do |sig_decl|
                @ast.architectures[0].decl << sig_decl
            end

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
                    # * : Different process depending on type of source, necessary to avoid generic naming and same identifier for different port entities
                    if !p.get_source.is_global?
                        src = p.get_source
                        src_name = src.get_full_name
                        # * : full name are usefull for this, embedding the component name within
                        @sig_tab[src_name] = VHDL::AST::SignalDeclaration.new(to_Ident(src_name), VHDL::AST::Type.new("bit"))
                        association_statements << VHDL::AST::AssociationStatement.new(
                            to_Ident(p.name), 
                            to_Ident(src_name)
                        )
                        p.unplug(src)
                    # * : Global interfaces are always unique, no name modification need
                    else
                        to_unplug = p.get_source
                        association_statements << VHDL::AST::AssociationStatement.new(
                            to_Ident(p.name), 
                            to_Ident(to_unplug.name)
                        )
                        p.unplug(to_unplug.name)
                    end 
                else
                    if (p.get_sinks.length == 1) and p.get_sinks[0].is_global?
                        to_unplug = p.get_sinks[0]
                        association_statements << VHDL::AST::AssociationStatement.new(
                            to_Ident(p.name), 
                            to_Ident(to_unplug.name)
                        )
                        to_unplug.unplug(p.name) # * : We won't need these information later since they are completely described in the AST
                    else
                        # * : The src_name created herer is a signal to avoid having problems with similar port names between components 
                        src = p
                        src_name = p.get_full_name
                        @sig_tab[src_name] = VHDL::AST::SignalDeclaration.new(to_Ident(src_name), VHDL::AST::Type.new("bit"))
                        association_statements << VHDL::AST::AssociationStatement.new(
                            to_Ident(p.name), 
                            to_Ident(src_name)
                        )
                        # * : No unplug here cause we will need informations for the link in the other way.
                    end
                end
            end

            return VHDL::AST::PortMap.new(association_statements)
        end

        def convWiring
            statements = []

            # # * : Global entries wiring
            # @netlist.get_inputs.each do |p|
            #     p.get_sinks.each do |sink|
            #         statements << VHDL::AST::AssignStatement.new(
            #             to_Ident(sink.get_full_name),
            #             to_Ident(p.get_full_name) 
            #         )

            #         # sink.unplug(p.name) 
            #     end
            # end

            # * : Gates wiring (Converted into Binary or Unary Expressions)
            @netlist.components.each do |comp|
                if comp.is_a? Gate
                    # ! : Possible optimization later using a '_' separator between comp name and object unique ID
                    operator = comp.name.split(/(?<=[A-Za-z])(?=\d)/)[0].downcase # * : Retrieve the gate type only without the object ID
                    if @timed 
                        if operator != "not"
                            statements << convTimedBinary(comp, operator)
                        else
                            statements << convTimedUnary(comp,operator)
                        end
                    else
                        if operator != "not" # BinaryExp
                            statements << convBinaryExp(comp, operator)
                        else # UnaryExp
                            statements << convUnaryExp(comp, operator)
                        end
                    end
                end
            end

            # # *: Wires equivalent to Signals assignments 
            # if @netlist.wires != []
            #     @netlist.wires.each do |w|
            #         w.get_sinks.each do |sink|
            #             statements << VHDL::AST::AssignStatement.new(
            #                 to_Ident(sink.get_full_name), 
            #                 to_Ident(w.get_full_name)
            #             )

            #             # sink.unplug w.name
            #         end
            #     end
            # end

            @netlist.get_outputs.each do |outp|
                # if !outp.get_source.is_global?
                #     src = outp.get_source
                #     src_name = src.get_full_name
                #     if @sig_tab[src_name].nil?
                #         @sig_tab[src_name] = VHDL::AST::SignalDeclaration.new(to_Ident(src_name), VHDL::AST::Type.new("bit"))
                #     end
                # else 
                if outp.get_source.is_global?
                    src_name = outp.get_source.name
                    statements << VHDL::AST::AssignStatement.new(
                        to_Ident(outp.name),
                        to_Ident(src_name)
                    )
                end
            end

            return statements
        end

        def convTimedBinary comp, operator
            association_statements = []
            
            association_statements << VHDL::AST::AssociationStatement.new(to_Ident("a"), to_Ident(comp.get_inputs[0].get_source.get_full_name))
            association_statements << VHDL::AST::AssociationStatement.new(to_Ident("b"), to_Ident(comp.get_inputs[1].get_source.get_full_name))

            association_statements << VHDL::AST::AssociationStatement.new(to_Ident("o"), to_Ident(comp.get_outputs[0].get_sinks[0].get_full_name))

            return VHDL::AST::InstantiateStatement.new(to_Ident(comp.name), to_Ident("#{operator}2_d"), to_Ident("rtl"), to_Ident("work"), association_statements)
        end

        def convTimedUnary comp, operator
            association_statements = []
            
            association_statements << VHDL::AST::AssociationStatement.new(to_Ident("a"), to_Ident(comp.get_inputs[0].get_source.get_full_name))

            association_statements << VHDL::AST::AssociationStatement.new(to_Ident("o"), to_Ident(comp.get_outputs[0].get_sinks[0].get_full_name))

            return VHDL::AST::InstantiateStatement.new(to_Ident(comp.name), to_Ident("#{operator}_d"), to_Ident("rtl"), to_Ident("work"), association_statements)
        end

        def convUnaryExp comp, operator
            i0 = comp.get_inputs[0]
            
            # * : Conversion to AST Signal Declaration, for components ports and for a global port
            if !i0.get_source.is_global?
                src = i0.get_source
                operand_name = src.get_full_name
                if @sig_tab[operand_name].nil?
                    @sig_tab[operand_name] = VHDL::AST::SignalDeclaration.new(to_Ident(operand_name), VHDL::AST::Type.new("bit"))
                end
            else 
                operand_name = i0.get_source.name
            end

            o0 = comp.get_outputs[0]

            if (o0.get_sinks.length == 1) and o0.get_sinks[0].is_global? 
               dest_name = o0.get_sinks[0].name
           else
                # * : The src_name created herer is a signal to avoid having problems with similar port names between components 
                src = o0
                dest_name = o0.get_full_name
                if @sig_tab[dest_name].nil?
                    @sig_tab[dest_name] = VHDL::AST::SignalDeclaration.new(to_Ident(dest_name), VHDL::AST::Type.new("bit"))
                end
                # * : No unplug here cause we will need informations for the link in the other way.
           end

            # i1.unplug operand_name
            # o1.get_sinks[0].unplug o1.name
            # o1.unplug dest_name

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
            i0, i1 = comp.get_inputs
            
            if !i0.get_source.is_global?
                src = i0.get_source
                operand0_name = src.get_full_name
                if @sig_tab[operand0_name].nil?
                    @sig_tab[operand0_name] = VHDL::AST::SignalDeclaration.new(to_Ident(operand0_name), VHDL::AST::Type.new("bit"))
                end
            else 
                operand0_name = i0.get_source.name
            end

            if !i1.get_source.is_global?
                src = i1.get_source
                operand1_name = src.get_full_name
                if @sig_tab[operand1_name].nil?
                    @sig_tab[operand1_name] = VHDL::AST::SignalDeclaration.new(to_Ident(operand1_name), VHDL::AST::Type.new("bit"))
                end
            else
                operand1_name = i1.get_source.name
            end
            
            o0 = comp.get_outputs[0]

            if (o0.get_sinks.length == 1) and o0.get_sinks[0].is_global? 
               dest_name = o0.get_sinks[0].name
            else
                # * : The src_name created here is a signal to avoid having problems with similar port names between components 
                # ! : Should rename 'src' and 'src_name' into 'sink' and 'sink_full_name'
                src = o0
                src_name = o0.get_full_name
                if @sig_tab[src_name].nil?
                    @sig_tab[src_name] = VHDL::AST::SignalDeclaration.new(to_Ident(src_name), VHDL::AST::Type.new("bit"))
                end
                dest_name = src_name
                # * : No unplug here cause we will need informations for the link in the other way.
            end

            return VHDL::AST::AssignStatement.new(   
                to_Ident(dest_name), 
                VHDL::AST::BinaryExp.new(
                    to_Ident(operand0_name), 
                    VHDL::AST::Operator.new(operator), 
                    to_Ident(operand1_name), 
                    VHDL::AST::Type.new("bit")
                )
            )
        end

    end

end
