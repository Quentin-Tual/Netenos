module AtetaAddOn
  class HtpgSat
    TMP_SMT_PATH = "#{$TMP_PATH}/htpg_smt"

    def initialize initCirc, init_dly_db, crit_path, altCirc, alt_dly_db, insertPointName, targetedOutputName, dly_db_col: :typ
      @initCirc = initCirc
      @init_dly_db = init_dly_db
      @altCirc = altCirc
      @alt_dly_db = alt_dly_db
      
      @crit_path = crit_path
      @insertPointName = insertPointName
      comp_name, port_name = insertPointName.split('/')
      @initInsertWireName = @initCirc.get_component_named(comp_name).get_port_named(port_name).get_source.name
      @altInsertWireName = @altCirc.get_component_named(comp_name).get_port_named(port_name).get_source.name
      @targetedOutputName = targetedOutputName

      @dly_db_col = dly_db_col
      
      # If it does not exist, create the temporary dir to store smt files 
      Dir.mkdir(TMP_SMT_PATH) unless Dir.exist?(TMP_SMT_PATH)
      @SMTS_PATH = TMP_SMT_PATH + '/' + @initCirc.name + "/#{@insertPointName.tr('/','_')}_#{@targetedOutputName}.smt"
      Dir.mkdir(TMP_SMT_PATH + '/' + @initCirc.name) unless Dir.exist?(TMP_SMT_PATH + '/' + @initCirc.name)

      # TODO : If it does not exist, create a file to contain initial circuit formal representation (self.create_init_circ_basefile)
      # TODO : Append the altered formal representation to it (self.append_alt_circ_representation)

      # TODO : Check if z3 is installed and accessible (in the path), far more earlier, maybe in the gem requirements ?
    end

    def create_init_circ_basefile
      smt_extractor = SMT::SMTExprExtractor.new(@initCirc, @init_dly_db)
      targeted_output = @initCirc.get_port_named(@targetedOutputName)
      targeted_output.accept(smt_extractor)
      @on_output_path = smt_extractor.visited
      smt_extractor.save_as(@SMTS_PATH)
    end

    def append_alt_circ_representation
      smt_extractor = SMT::SMTExprExtractor.new(@altCirc, @alt_dly_db, inserted_gates: [@altCirc.components.last], write_constants: false)
      targeted_output = @altCirc.get_port_named(@targetedOutputName)
      targeted_output.accept(smt_extractor)
      smt_extractor.save_as(@SMTS_PATH)
    end

    def soft_constraint_insert_point
      # Récupérer le port "sink" et sa porte qui est sur le chemin entre le point d'insertion et la sortie ciblée
      g_name, ip_name = @insertPointName.split('/')
      g = @initCirc.get_component_named(g_name)
      # ip = g.get_port_named(ip_name)
      op_name = g.get_output.get_full_name
      # Récupérer le front pour lequel le délai est minimale pour cette entrée de cette porte
      rise_dly = @init_dly_db.get_gate_dly(g, [@insertPointName, op_name], :rise, @dly_db_col)
      fall_dly = @init_dly_db.get_gate_dly(g, [@insertPointName, op_name], :fall, @dly_db_col)
      # Formuler la contrainte faible 
      if rise_dly < fall_dly
        @soft_constraint_value = true
      else
        @soft_constraint_value = false
      end
      "(assert-soft (= (#{@initCirc.name}/#{@initInsertWireName} t_b) #{@soft_constraint_value.to_s}))"
    end

    def constraint_insert_point
      src = []
      src << '(declare-const t_b Int)'
      src << '(assert (> t_b 0))'
      src << "(assert (< t_b #{@crit_path}))"
      src << "(assert (not (= (#{@initCirc.name}/#{@initInsertWireName} t_b) (#{@altCirc.name}/#{@altInsertWireName} t_b))))"
      src << soft_constraint_insert_point
      src << "(check-sat)"
      src << "(push)"
      src
    end

    def soft_constraint_targeted_output
      path_lister = Netlist::PathLister.new(@initCirc, @initCirc.get_port_named(@targetedOutputName))
      start_point = @initCirc.get_wire_named(@initInsertWireName)
      
      paths = start_point.accept(path_lister)
      p = paths.min_by{|path| path.length}
      # gate_path = p.select{|obj| obj.is_a?(Netlist::Gate)}
      nb_inverter = p.count do |obj|
        if obj.is_a?(Netlist::Gate)
          obj.class.name.split('_')[-2].include?('oi') or \
          obj.class.name.split('_')[-2].include?('nand') or \
          obj.class.name.split('_')[-2].include?('nor') or \
          obj.class.name.split('_')[-2].include?('xnor')
        elsif obj.instance_of?(Netlist::Port) and obj.is_input? and !obj.is_global?
          obj.partof.scl_ios[obj.name].include?('_N')
        else
          next
        end
      end
      # nb_gate_inverter = gate_path.count{|g| g.class.name.split('_')[-2].include?('oi') } # !!! Not what we want, functions are not built this way !

      if nb_inverter % 2 == 0
        value = @soft_constraint_value
      else
        value = !@soft_constraint_value
      end

      "(assert-soft (= (#{@initCirc.name}/#{@targetedOutputName} t_a) #{value.to_s}))"
    end

    def constraint_targeted_output
      src = []
      src << '(declare-const t_a Int)'
      src << '(assert (> t_a t_b))'
      src << "(assert (< t_a #{@crit_path}))"
      src << "(assert (not (= (#{@initCirc.name}/#{@targetedOutputName} t_a) (#{@altCirc.name}/#{@targetedOutputName} t_a))))"
      src << soft_constraint_targeted_output
      src
    end

    def append_constraints
      src = []
      src += constraint_insert_point
      src += constraint_targeted_output
      src << '(check-sat)'
      src << '(get-model)'
      File.write(@SMTS_PATH, src.join("\n"), mode: 'a')
    end

    def gen_solving_script
      create_init_circ_basefile 
      append_alt_circ_representation
      append_constraints
    end

    def run_solving_script
      `z3 -smt2 #{@SMTS_PATH}`
    end

    def parse_results results
        res_h = Hash.new { |h, k| h[k] = Hash.new}
        if results[0] == "sat"
            results[1..].each_cons(2) do |prev_line,line|
                splitted_prev_line = prev_line.split
                if splitted_prev_line[0] == "(define-fun"
                    if splitted_prev_line[1].match?(/i[0-9]+_[a,d]/)
                        input_name, cycle = splitted_prev_line[1].split("_")
                        res_h[input_name][cycle] = line.split[0][...-1]
                    end
                    if splitted_prev_line[1] == "t_a"
                        @transition_instant = line.split[0][...-1]
                    end 
                else
                    next
                end
            end
            return res_h.sort_by{|k,v| k[1..].to_i}.to_h
        else
            return nil
        end
    end 

    def results2vec results
      raise "Error: z3 returns empty string." if results.empty?

      results = results.split("\n")
      
      res_h = parse_results(results)

      if res_h.nil?
          return nil
      end

      tmp = res_h.each_with_object(Hash.new {|h,k| h[k] = Array.new}) do |(var, sub_h), h|
          sub_h.each do |k,val|
              h[k] << val
          end
      end

      vd = tmp["d"]
      va = tmp["a"]

      vd.map!{|val| (val == "true" ? "1" : "0")}
      va.map!{|val| (val == "true" ? "1" : "0")}

      return vd.join, va.join
    end

    def run 
      # Generate a solving script
      gen_solving_script
      # Run z3
      results=run_solving_script
      # Convert results in Test Vector Pairk
      results2vec results
    end
  end
end