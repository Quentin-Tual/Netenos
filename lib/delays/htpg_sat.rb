module AtetaAddOn
  class HtpgSat
    TMP_SMT_PATH = "#{$TMP_PATH}/htpg_smt"

    def initialize initCirc, init_dly_db, crit_path, altCirc, alt_dly_db, insertPointName, targetedOutputName, dly_db_col: :typ
      @initCirc = initCirc
      @init_dly_db = init_dly_db
      @crit_path = crit_path
      @altCirc = altCirc
      @alt_dly_db = alt_dly_db
      @insertPointName = insertPointName
      comp_name, port_name = insertPointName.split('/')
      @initInsertWireName = @initCirc.get_component_named(comp_name).get_port_named(port_name).get_source.name
      @altInsertWireName = @altCirc.get_component_named(comp_name).get_port_named(port_name).get_source.name
      @targetedOutputName = targetedOutputName
      @dly_db_col = dly_db_col
      
      # If it does not exist, create the temporary dir to store smt files 
      Dir.mkdir(TMP_SMT_PATH) unless Dir.exist?(TMP_SMT_PATH)
      @smt_filepath = TMP_SMT_PATH + "/#{@insertPointName.tr('/','_')}_#{@targetedOutputName}.smt"
      
      # TODO : If it does not exist, create a file to contain initial circuit formal representation (self.create_init_circ_basefile)
      # TODO : Append the altered formal representation to it (self.append_alt_circ_representation)

      # TODO : Check if z3 is installed and accessible (in the path), far more earlier, maybe in the gem requirements ?
    end

    def create_init_circ_basefile
      smt_extractor = SMT::SMTExprExtractor.new(@initCirc, @init_dly_db)
      targeted_output = @initCirc.get_port_named(@targetedOutputName)
      targeted_output.accept(smt_extractor)
      smt_extractor.save_as(@smt_filepath)
    end

    def append_alt_circ_representation
      smt_extractor = SMT::SMTExprExtractor.new(@altCirc, @alt_dly_db, inserted_gates: [@altCirc.components.last], write_constants: false)
      targeted_output = @altCirc.get_port_named(@targetedOutputName)
      targeted_output.accept(smt_extractor)
      smt_extractor.save_as(@smt_filepath)
    end

    def append_constraints
      src = []
      src << '(declare-const t_b Int)'
      src << '(assert (> t_b 0))'
      src << "(assert (< t_b #{@crit_path}))"
      src << "(assert (not (= (#{@initCirc.name}/#{@initInsertWireName} t_b) (#{@altCirc.name}/#{@altInsertWireName} t_b))))"
      src << "(check-sat)"
      src << "(push)"

      src << '(declare-const t_a Int)'
      src << '(assert (> t_a t_b))'
      src << "(assert (< t_a #{@crit_path}))"
      src << "(assert (not (= (#{@initCirc.name}/#{@targetedOutputName} t_a) (#{@altCirc.name}/#{@targetedOutputName} t_a))))"

      src << '(check-sat)'
      src << '(get-model)'
      File.write(@smt_filepath, src.join("\n"), mode: 'a')
    end

    def gen_solving_script
      create_init_circ_basefile 
      append_alt_circ_representation
      append_constraints
    end

    def run_solving_script
      `z3 -smt2 #{@smt_filepath}`
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