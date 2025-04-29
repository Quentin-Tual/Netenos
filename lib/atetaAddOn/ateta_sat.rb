require_relative 'code.rb'

module AtetaAddOn
    class AtetaSat 
        # ! Avec un AtetaSat pour chaque point d'insertion
        # ! Avec les méthodes suivantes
        # !     
        # !     - genSmtlibExpr : génération d'expressions smtlib pour le initCirc et altCirc  
        # !     - génération de script smtlib complet 
        # !     - parsing des résultats de script smtlib
        # !     - conversion des résultats de script en couple de vecteurs de test

        def initialize initCirc, altCirc, insertionPoint, targetedOutput, delayModel, forbiddenVectors
            @initCirc = initCirc
            @altCirc = altCirc
            @insertionPoint = insertionPoint
            @targetedOutput = targetedOutput
            @delayModel = delayModel
            @forbiddenVectors = forbiddenVectors

            @initExprExtractor = SmtlibConverter.new(initCirc, @delayModel)
            @altExprExtractor = SmtlibConverter.new(altCirc, @delayModel)

            # TODO : Check if z3 is installed and accessible (in the path)
        end

        def genSmtlibExprInit
            @initExprExtractor.get_output_func_def(@targetedOutput)
        end
        
        def genSmtlibExprAlt
            @altExprExtractor.get_output_func_def(@targetedOutput, "yp")    
        end

        def genVariablesDeclaration
            (@initExprExtractor.get_var_declarations + @altExprExtractor.get_var_declarations).uniq
        end  

        def genVariablesConstraints
            var_decl = genVariablesDeclaration
            var_h = Hash.new { |h, k| h[k] = Hash.new}
            var_decl.collect do |line|
                var = line.split(" ")[1]
                input_name, instant = var.split("_")
                var_h[input_name][instant] = var
            end

            constraints = []
            # TODO : For each inputs 
            oldestInstant = var_h.values.collect{|e| e.keys}.flatten.uniq.sort_by{|x| x.to_i}[0]
            # ! What if the the transition instant is not the oldest one ?
            # ! We miss a lot of solutions.
            # ! We wwant a transition instant before which values won't change from an instant to the other, and after which the values won't change anymore.

            var_h.each do |input_name, sub_h|
                # TODO :    Add an equality between all other instants than the first
                if sub_h.length > 1 # No need if there is two elements or less
                    sub_h.to_a.sort_by{|a| a[0].to_i}.each_cons(2) do |prev, curr|
                        unless prev[0] == oldestInstant
                            constraints << "(assert (= #{prev[-1]} #{curr[-1]}))" 
                        end
                    end
                end     
            end
            
            constraints
        end

        def genVariablesConstraints2
            # signals, instants = getAllSigAndInstants
            constraints = []

            if @instants.length > 2
                
                constraints = @instants[1...].collect do |transition_instant|
                    genVarConstrFor(transition_instant)
                end
                # if c_list.length > 2
                
                # elsif c_list.length == 1
                #     constraints << "(assert #{c_list})"
            end
            # end
            return constraints
        end

        def genVariablesAssertion 
            c_list = @instants[1...].collect{|t| "c_#{t}"}
            if c_list.length < 2
                return ""
            else            
                return "(assert (or #{c_list.join(" ")}))" 
            end
        end

        def getAllSigAndInstants 
            signals = (@initExprExtractor.signals).uniq.sort_by{|s| s[1..].to_i}
            
            initInstants = @initExprExtractor.instants
            altInstants = @altExprExtractor.instants 
            # initInstants = (initInstants.min..initInstants.max).to_a
            # altInstants = (altInstants.min..altInstants.max).to_a
            
            instants = initInstants + altInstants 
            instants = (instants.min..instants.max).to_a.sort_by{|t| t.to_i}
            # instants = (initInstants + altInstants).uniq.sort_by{|t| t.to_i}

            return signals, instants
        end

        def genVarConstrFor t
            constraints = []
            # signals, instants = getAllSigAndInstants

            transition_index = @instants.index(t)

            # TODO : Pour chaque instant de 0 à t-1 (each_cons do |t1, t2|)
            @instants[0...transition_index].each_cons(2) do |t1, t2|
                @signals.each do |s|
                    constraints << genVarEqFor(s, t1, t2)
                end
            end

            # TODO : Pour chaque instant >= à t
            @instants[transition_index..].each_cons(2) do |t1, t2|
                @signals.each do |s|
                    constraints << genVarEqFor(s, t1, t2)
                end
            end

            return "(define-fun c_#{t} () Bool (and #{constraints.join(" ")}))"
        end

        def genVarEqFor sig, t1, t2
            return "(= #{sig}_#{t1} #{sig}_#{t2})"
        end

        def genForbiddenVecConstraints
            constraints = []

            unless @forbiddenVectors.empty? 
                @forbiddenVectors.each_with_index do |fv, vecId|
                    if fv.length > @signals.length
                        raise "Error : Invalid vector size for the given circuit, #{fv.length} bits for #{@signals.length} inputs."
                    end
                    line = "(define-fun fv_#{vecId} () Bool (or "
                    @instants.each do |t|
                        line << "(and"
                        @signals.each_with_index do |s, i|
                            line << " "
                            line << "(= #{s}_#{t} #{fv[s[1..].to_i] == "0" ? "false" : "true"})"
                        end
                        line << ")"
                    end
                    line << "))"
                    constraints << line
                end
            end

            return constraints
        end

        def genForbiddenVecAssertion 
            if @forbiddenVectors.empty?
                line = ""
            elsif @forbiddenVectors.length > 1
                line = "(assert (not (or"
                @forbiddenVectors.each_with_index do |fv, vecId|
                    line << " "
                    line << "fv_#{vecId}"
                end
                line << ")))"
            else
                line = "(assert (not"
                @forbiddenVectors.each_with_index do |fv, vecId|
                    line << " "
                    line << "fv_#{vecId}"
                end
                line << "))"
            end 
            return line
        end

        def genSolvingScript saveAs = nil

            initExpr = genSmtlibExprInit # ! Should not be computed again each time, see how to optimize it properly by reloading it or passing it 
            altExpr = genSmtlibExprAlt

            @signals, @instants = getAllSigAndInstants

            if initExpr == altExpr 
                raise "Error : Initial and Altered circuit gave the same expression for targeted output."
            end

            src = Code.new

            src << "; #{@initCirc.name}, #{@insertionPoint.get_full_name}, #{@targetedOutput.get_full_name}"
            src << "; Variable Declarations"
            src << genVariablesDeclaration.join("\n")
            src.newline

            src << "; Function Definitions"
            src << initExpr
            src << altExpr
            src.newline

            src << "; Synchronous Stimulation Constraints"
            src << genVariablesConstraints2.join("\n")
            src.newline
            
            src << "; Fobidden Vectors Constraints"
            src << genForbiddenVecConstraints.join("\n")
            src.newline

            src << "; Assertions"
            src << genVariablesAssertion
            src << genForbiddenVecAssertion
            src << "(assert (= y (not yp)))"
            src.newline

            src << "; Solve"
            src << "(check-sat)"
            src << "(get-model)"
            
            if saveAs.nil?
                return src.to_s
            else
                src.save_as(saveAs)
            end
        end

        def runSolvingScript scriptName
            `z3 -smt2 #{scriptName}`
        end 

        def parse_results results
            res_h = Hash.new { |h, k| h[k] = Hash.new}
            if results[0] == "sat"
                last_id = nil
                results[1..].each do |line|
                    splitted_line = line.split
                    if splitted_line.length == 1 
                        if splitted_line[0] == "(" or splitted_line[0] == ")" # ignore single parenthesis
                            next
                        else
                            input_name, instant = last_id.split("_")
                            res_h[input_name][instant] = splitted_line[0][...-1] # register value, remove parenthesis
                        end
                    else
                        if splitted_line[0] == "(error"
                            raise "z3 err output : " + line
                        else
                            var = splitted_line[1]
                            if var == "y" or var == "yp" # ignore cone expressions
                                break # end the search, usually they are the last variables defined in the returned prompt
                            else 
                                last_id = var
                            end
                        end
                    end
                end
                return res_h
            else
                return nil
            end
        end

        def results2vec results
            # * Returns a vector couple or nil if no solution found 
            # TODO : Mettre ce bloc de code dans une fonction à part "parse_results"
            results = results.split("\n")
            
            res_h = parse_results(results)
            
            if res_h.nil?
                return nil
            end

            # Convertir le hash associant des valeurs booléenne à des variables en deux vecteurs de test
            vo = Array.new(@initCirc.get_inputs.length, nil)
            va = Array.new(@initCirc.get_inputs.length, nil)
            

            tmp = res_h.sort_by{|k,v| k[1..].to_i}.to_h
            tmp = tmp.each_with_object(Hash.new {|h,k| h[k] = Array.new}) do |(var, sub_h), h|
                sub_h.sort_by{|k,v| k.to_i}.each do |k,val|
                    h[k] << val
                end
            end

            vecCouple = tmp.values.uniq
            if vecCouple.length > 2 
                raise "Error : More than one vector necessary to satisfy given constraints. Verify constraints."
            end

            vo, va = vecCouple

            vo.map!{|val| (val == "true" ? "1" : "0")}
            va.map!{|val| (val == "true" ? "1" : "0")}

            # # TODO : Recover the transition instant 
            # oldestInstant = res_h.values.collect{|e| e.keys}.flatten.sort_by{|e| e.to_i}.uniq[0]
            # transitionInstant = nil

            # # Récupérer les valeurs sur chaque port à chaque instant
            # res_h.each do |var, sub_h|
            #     sub_h.sort_by{|k,v| k.to_i}.each do |instant, val|
            #         binVal = (val == "true" ? "1" : "0")
            #         inputID = var[1..].to_i
            #         # Les stocker dans deux vecteurs de la taille du nombre d'entrées aux endroits correspondant
            #         if instant == oldestInstant
            #             vo[inputID] = binVal
            #         else
            #             if binVal != vo[inputID]
            #                 transitionInstant = instant
            #                 if va[inputID].nil?
            #                     va[inputID] = binVal
            #                 elsif va[inputID] != binVal
            #                     raise "Error : Conflict encountered."
            #                 end
            #             end
            #         end
            #     end
            # end

            # # TODO : Remplir les valeurs nil de vo et va par des 1 (par défaut, possible de tenter d'autres approches par la suite)
            # vo.map!{|e| e.nil? ? "1" : e}
            # va.map!.with_index{|e,i| e.nil? ? vo[i] : e}
            # # va.map!.with_index do |e,i| 
            # #     if e.nil? 
            # #         vo[i] 
            # #     else
            # #         e
            # #     end
            # # end

            return vo.join , va.join
        end

        def run 
            genSolvingScript "tmp.smt"
            res = runSolvingScript "tmp.smt"
            results2vec res
        end
    end
end