module AtetaAddOn

    class SmtlibConverter
        attr_reader :instants, :signals

        def initialize circ, delay_model = :one
            @circ = circ
            @signals = Set.new(@circ.get_inputs.collect(&:name))
            @instants = Set.new
            @delay_model = delay_model
            @gate_delays = {
                "not" => Netlist::Not::PROPAG_TIME[delay_model],
                "and" => Netlist::Not::PROPAG_TIME[delay_model],
                "or"  => Netlist::Or2::PROPAG_TIME[delay_model],
                "nand"=> Netlist::Nand2::PROPAG_TIME[delay_model],
                "nor"=> Netlist::Nor2::PROPAG_TIME[delay_model],
                "xor"=> Netlist::Xor2::PROPAG_TIME[delay_model],
                "buf"=> Netlist::Buffer::PROPAG_TIME[delay_model], # ! Check exact keyword used, "buffer" or "buf"
            }

            unless @circ.wires.empty?
                raise "Error : Current version is not compatible with Netlist::Wire usage !"
            end
        end

        def get_output_func_def targetedOutput, func_name = "y" 
            # global_expr = @circ.get_global_expression(targetedOutput.get_full_name)
            # ast_expr = @circ.expr_to_h(global_expr)
            smtlib_expr = get_smtlib_expr2(targetedOutput.get_full_name)
            get_fun_definition(smtlib_expr, func_name)
        end

        def get_smtlib_expr2 sigName, t=0 # ! Not compatible with Netlist::Wire usage !
            expr = ""

            if @circ.is_primary_input_name?(sigName)
                v = "(#{sigName} (- t #{t}))"
                expr << v
            elsif @circ.is_primary_output_name?(sigName)
                sourceSigName = @circ.get_port_named(sigName).get_source.get_full_name
                expr << get_smtlib_expr2(sourceSigName,t)
            else
                comp = @circ.get_component_named(sigName.split('_')[0])
                inPorts = comp.get_inputs

                case comp
                when Netlist::Nand2
                    expr << "(not (and "
                    inPorts.each do |p|
                        expr << get_smtlib_expr2(
                            p.get_source.get_full_name, 
                            t + @gate_delays["nand"])
                        expr << " "
                    end
                    expr << "))"
                when Netlist::Nor2
                    expr << "(not (or "
                    inPorts.each do |p|
                        expr << get_smtlib_expr2(
                            p.get_source.get_full_name, 
                            t + @gate_delays["nor"])
                        expr << " "
                    end
                    expr << "))"
                when Netlist::Not
                    expr << "(not "
                    expr << get_smtlib_expr2(inPorts[0].get_source.get_full_name, t + @gate_delays["not"])
                    expr << ")"
                when Netlist::Buffer
                    expr << get_smtlib_expr2(inPorts[0].get_source.get_full_name, t + @gate_delays["buf"])
                else
                    expr << "(#{comp.class::SMT_NAME} "
                    inPorts.each do |p|
                        expr << get_smtlib_expr2(
                            p.get_source.get_full_name, 
                            t + @gate_delays[comp.class::SMT_NAME])
                        expr << " "
                    end
                    expr << ")"
                end
            end

            return expr
        end

        def get_const_declarations 
            tmp = @signals.collect{|s| "(declare-const #{s}_d Bool)"}
            tmp += @signals.collect{|s| "(declare-const #{s}_a Bool)"}
            tmp << "(declare-const t_a Int)"
            tmp
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