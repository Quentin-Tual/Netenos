module AtetaAddOn

    class SmtlibConverter
        attr_reader :instants, :signals

        def initialize circ, delay_model = :one
            @circ = circ
            @signals = Set.new(@circ.get_inputs.collect(&:name))
            @instants = Set.new
            @output_func = nil
            @const_declarations = nil
            @delay_model = delay_model

            
            raise "Error : Current version is not compatible with Netlist::Wire usage !" unless @circ.constants.empty?
        end

        def get_output_func_def targetedOutputName, func_name = "y" 
            # global_expr = @circ.get_global_expression(targetedOutput.get_full_name)
            # ast_expr = @circ.expr_to_h(global_expr)
            if @output_func.nil?
                smtlib_expr = get_smtlib_expr(targetedOutputName)
                @output_func = get_fun_definition(smtlib_expr, func_name)
            else
                @output_func
            end
        end

        # def get_smtlib_expr sigName, t=0 # ! Not compatible with Netlist::Wire usage !
        #     expr = ""

        #     if @circ.is_primary_input_name?(sigName)
        #         v = "(#{sigName} (- t #{t}))"
        #         expr << v
        #     elsif @circ.is_primary_output_name?(sigName)
        #         sourceSigName = @circ.get_port_named(sigName).get_source.get_full_name
        #         expr << get_smtlib_expr(sourceSigName,t)
        #     else
        #         comp = @circ.get_component_named(sigName.split($FULL_PORT_NAME_SEP)[0])
        #         inPorts = comp.get_inputs

        #         expr << comp.class::SMT_EXPR[0]
        #         inPorts.each do |p|
        #             expr << get_smtlib_expr(
        #                 p.get_source.get_full_name, 
        #                 t + comp.propag_time[@delay_model])
        #             expr << " "
        #         end
        #         expr << comp.class::SMT_EXPR[1]
        #     end

        #     return expr
        # end

        def get_smtlib_expr_wire wire, t
            source = wire.get_source
            return get_smtlib_expr_source(source, t + wire.propag_time[@delay_model])
        end

        def get_smtlib_expr_globalinput port, t
            return "(#{port.name} (- t_a #{t}))"
        end
        
        def get_smtlib_expr_compout port, t
            comp = port.partof
            smt_fun_a = comp.class::SMT_EXPR.dup
            case comp
            when Netlist::STDCell
                get_pdk_stdcell_smtlib_expr(smt_fun_a, t, comp)
            when Netlist::Gate
                get_gtech_gate_smtlib_expr(smt_fun_a, t, comp)
            else
                raise "Error: Unknown class object #{comp.class}, not handled."
            end
        end

        def get_pdk_stdcell_smtlib_expr smt_fun_a, t, comp
            smt_fun_a.map! do |word|
                if !word.is_a? String
                  raise "Error: String object is expected, obtained #{word} which is a #{word.class} class object. Check #{comp.name} object."
                elsif $SMT_KEYWORDS.include? word
                    word
                else # It is a port name
                    p = comp.get_port_named(word)
                    raise "Error: port #{word} not found in #{comp}" if p.nil?
                    source = comp.get_port_named(word).get_source
                    begin
                        get_smtlib_expr_source(source, t + comp.propag_time[@delay_model])
                    rescue => e
                        puts t 
                        puts comp.propag_time[@delay_model]
                        puts comp
                        raise e
                    end
                end
            end
            smt_fun_a.flatten
        end

        def get_gtech_gate_smtlib_expr smt_fun_a, t, comp
            pp comp.class
            pp comp
            inPorts = comp.get_inputs
            expr = ""
            expr << comp.class::SMT_EXPR[0]
            inPorts.each do |p|
                expr << get_smtlib_expr_source(
                    p.get_source, 
                    t + comp.propag_time[@delay_model])
                expr << " "
            end
            expr << comp.class::SMT_EXPR[1]
            expr
        end

        def get_smtlib_expr_globaloutput portName, t=0 # Check if it rather be the signal object or its name  
            op = @circ.get_port_named(portName)
            source = op.get_source
            return get_smtlib_expr_source(source, t)
        end
        
        def get_smtlib_expr_source source, t
            if source.instance_of? Netlist::Wire
                return get_smtlib_expr_wire(source,t)
            elsif source.instance_of? Netlist::Port 
                if source.is_global? and source.is_input?
                    return get_smtlib_expr_globalinput(source,t)
                elsif !source.is_global? and source.is_output?
                    return get_smtlib_expr_compout(source,t)
                else
                    raise "Error: The source #{source} can't be a global output or a component input." # The source can't be a global output or a component input
                end
            else
                raise "Error: Object #{source} of class #{source.class} is not handled." # Constants not handled, can't be anything else
            end
        end

        def get_smtlib_expr sigName, t=0
            get_smtlib_expr_globaloutput(sigName,t).join(' ')
        end


        def get_const_declarations 
            if @const_declarations.nil?
                tmp = @signals.collect{|s| "(declare-const #{s}_d Bool)"}
                tmp += @signals.collect{|s| "(declare-const #{s}_a Bool)"}
                tmp << "(declare-const t_a Int)"
                @const_declarations = tmp
            else
                @const_declarations
            end
        end

        def get_input_fun_definition 
            @signals.collect do |sigName|
                "(define-fun #{sigName} ((t Int)) Bool\n\t(ite (< t 0) #{sigName}_d #{sigName}_a))"
            end
        end

        def get_fun_definition smtlib_expr, func_name 
            "(define-fun #{func_name} ((t Int)) Bool #{smtlib_expr})"
        end

    end

end