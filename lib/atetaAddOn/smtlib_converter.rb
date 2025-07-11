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

            unless @circ.wires.empty?
                raise "Error : Current version is not compatible with Netlist::Wire usage !"
            end
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

        def get_smtlib_expr sigName, t=0 # ! Not compatible with Netlist::Wire usage !
            expr = ""

            if @circ.is_primary_input_name?(sigName)
                v = "(#{sigName} (- t #{t}))"
                expr << v
            elsif @circ.is_primary_output_name?(sigName)
                sourceSigName = @circ.get_port_named(sigName).get_source.get_full_name
                expr << get_smtlib_expr(sourceSigName,t)
            else
                comp = @circ.get_component_named(sigName.split('_')[0])
                inPorts = comp.get_inputs

                expr << comp.class::SMT_EXPR[0]
                inPorts.each do |p|
                    expr << get_smtlib_expr(
                        p.get_source.get_full_name, 
                        t + comp.propag_time[@delay_model])
                    expr << " "
                end
                expr << comp.class::SMT_EXPR[1]
            end

            return expr
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