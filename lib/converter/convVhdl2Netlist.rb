module Netlist

    class ConvVhdl2Netlist

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
            # TODO : Première fonction d'un visiteur qui parcourt l'AST et construit la Netlist au fur et à mesure.
            @netlist = convEntity @ast
            @current_RTL_block = @netlist
            convArch(@ast.architectures.select{|arch| arch.name.name=="enoslist"}[0])
    
            verify_wiring
            #convInstanciatedComponents

            return @netlist
        end

        def convEntity entity
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
            return Netlist::Port.new(port.name.name, port.port_type.to_sym)
        end
    
        def convArch arch
            convArchDecl arch.decl
            @current_RTL_block.components.concat(convArchBody(arch.body))
        end

        def convArchDecl archDecl
            archDecl.each{|declaration| 
                wire = Wire.new declaration.name.name
                @wire_table[declaration.name.name] = wire
                @netlist.wires << wire
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
                    raise "Error : Unknown statement #{statement.class} in architecture body." 
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

        def convInstantiateStatement instanciateStatement
            inst_name = "#{instanciateStatement.name.name}_#{instanciateStatement.entity.name.name}" 
            inst = convEntity(@sym_tab[instanciateStatement.name.name])
            inst.name = inst_name
            inst.partof = @netlist
            convPortMap instanciateStatement.port_map, inst

            return inst
        end

        def convPortMap portmap, component
            portmap.association_statements.each{ |associationStatement|
                convAssociationStatement associationStatement, component
            }
        end

        def convAssociationStatement associationStatement, component
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
                    output_port.fanout.each do |targeted_interface|
                        targeted_interface.fanin = nil
                        targeted_interface <= output_port.fanin
                    end
                    output_port.fanout = []
                end
            end
        end

    end

end