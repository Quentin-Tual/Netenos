module Converter

    class ConvVhdl2Netlist # ! Legacy / associated to Hyle parser, not used and not maintained 

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
            @netlist = convEntity @ast
            @current_RTL_block = @netlist
            convArch(@ast.architectures.select{|arch| arch.name.name=="netenos"}[0])
    
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
            if !arch.nil?
                convArchDecl arch.decl
                @current_RTL_block.components.concat(convArchBody(arch.body))
            else 
                raise "Error: Empty architecture encountered.\n-> #{@ast.name.name}"
            end
        end

        def convArchDecl archDecl
            archDecl.each{|declaration| 
                w_name = "w_#{declaration.name.name}"
                wire = Wire.new w_name
                @wire_table[w_name] = wire
                @netlist << wire
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
            if @wire_table.keys.include?("w_#{interface_name}")
                ret = @wire_table["w_#{interface_name}"]
            else 
                ret = @netlist.get_port_named(interface_name)
            end

            if ret.nil?
                raise "Error: Interface #{interface_name} not found."
            end

            return ret
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
                ret = convOperator assignStatement.source.operator.op
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
                return Netlist::And2.new
            when "or"
                return Netlist::Or2.new
            when "xor"
                return Netlist::Xor2.new
            when "not"
                return Netlist::Not.new
            when "nand"
                return Netlist::Nand2.new
            when "nor"
                return Netlist::Nor2.new
            else 
                raise "Error : unknown operator encountered : #{op}"
            end
        end

        def convInstantiateStatement instanciateStatement
            inst_name = "#{instanciateStatement.name.name}"##_# {instanciateStatement.entity.name.name}" 
            # ! Modified to sort out the conversion from a vhdl source describing a random netlist generated by netenos back to netlist format  
            inst = convEntity(@sym_tab[inst_name])
            inst.name = inst_name
            inst.partof = @netlist # Component already registered in etlist.components thus '@netlist << inst' is not needed
            
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

            # No wire possible in theory, the source in the association statement should be a signal.
            
            # port = component.get_port_named(associationStatement.dest.name)

            if port.nil?
                raise "Error: Port not found in netlist.\n-> #{associationStatement.dest.name}"
            end

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

            @netlist.get_inputs.each do |input_port|
                if input_port.fanout.empty? and input_port.name != "clk"
                    raise "Error: Primary input has no component connected.\n-> #{input_port.name}"
                end
            end
        end

    end

end