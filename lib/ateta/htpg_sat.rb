require 'English'
module AtetaAddOn
  class HtpgSat
    TMP_SMT_PATH = "#{$TMP_PATH}/htpg_smt"

    def initialize(initCirc, init_dly_db, crit_path, altCirc, alt_dly_db, insertPointName, targetedOutputName,
                   dly_db_col: :typ, path_to_constraint: nil, smt_format: :rec)
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
      @path_to_constraint = path_to_constraint
      @constraint_index = 0
      @smt_format = smt_format

      # If it does not exist, create the temporary dir to store smt files
      Dir.mkdir(TMP_SMT_PATH) unless Dir.exist?(TMP_SMT_PATH)

      smt_file_name = "#{@insertPointName.tr('/', '_')}_#{@targetedOutputName}.smt"
      @SMTS_PATH = "#{TMP_SMT_PATH}/#{@initCirc.name}/#{smt_file_name}"

      if Dir.exist?("#{TMP_SMT_PATH}/#{@initCirc.name}")
        if File.exist?("#{TMP_SMT_PATH}/#{@initCirc.name}/#{smt_file_name}")
          `rm #{"#{TMP_SMT_PATH}/#{@initCirc.name}/#{smt_file_name}"}`
        end
      else
        Dir.mkdir("#{TMP_SMT_PATH}/#{@initCirc.name}")
      end

      # TODO : Check if z3 is installed and accessible (in the path), far more earlier, maybe in the gem requirements ?
      check_z3
    end

    def create_init_circ_basefile
      smt_extractor = SMT::SMTExprExtractor.new(@initCirc, @init_dly_db, crit_path_delay: @crit_path,
                                                                         smt_format: @smt_format)
      targeted_output = @initCirc.get_port_named(@targetedOutputName)
      targeted_output.accept(smt_extractor)
      @on_output_path = smt_extractor.visited
      smt_extractor.save_as(@SMTS_PATH)
    end

    def append_alt_circ_representation
      smt_extractor = SMT::SMTExprExtractor.new(@altCirc, @alt_dly_db, inserted_gates: [@altCirc.components.last],
                                                                       write_constants: false, crit_path_delay: @crit_path, smt_format: @smt_format)
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
      @soft_constraint_value = rise_dly < fall_dly
      "(assert-soft (= (#{@initCirc.name}/#{@initInsertWireName} t_#{@constraint_index}) #{@soft_constraint_value}))"
    end

    def constraint_insert_point
      src = []
      src << "(declare-const t_#{@constraint_index} Int)"
      src << "(assert (> t_#{@constraint_index} 0))"
      src << "(assert (< t_#{@constraint_index} #{@crit_path}))"
      src << "(assert (xor (#{@initCirc.name}/#{@initInsertWireName} t_#{@constraint_index}) (#{@altCirc.name}/#{@altInsertWireName} (- t_#{@constraint_index} 1))))"
      src << soft_constraint_insert_point unless @smt_format
      src << '(check-sat)'
      src << '(push)'
      @constraint_index += 1
      src
    end

    def soft_constraint_targeted_output
      path_lister = Netlist::PathLister.new(@initCirc, @initCirc.get_port_named(@targetedOutputName))
      start_point = @initCirc.get_wire_named(@initInsertWireName)

      paths = start_point.accept(path_lister)
      p = paths.min_by { |path| path.length }
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

      value = if nb_inverter.even?
                @soft_constraint_value
              else
                !@soft_constraint_value
              end

      "(assert-soft (= (#{@initCirc.name}/#{@targetedOutputName} t_#{@constraint_index}) #{value}))"
    end

    def constraint_targeted_output
      src = []
      src << "(declare-const t_#{@constraint_index} Int)"
      src << if @constraint_index.zero?
               "(assert (> t_#{@constraint_index} 0))"
             else
               "(assert (> t_#{@constraint_index} t_#{@constraint_index - 1}))"
             end
      src << "(assert (< t_#{@constraint_index} #{@crit_path}))"
      src << "(assert (xor (#{@initCirc.name}/#{@targetedOutputName} t_#{@constraint_index}) (#{@altCirc.name}/#{@targetedOutputName} t_#{@constraint_index})))"
      src << soft_constraint_targeted_output unless @smt_format
      @constraint_index += 1
      src
    end

    def constraint_targeted_path
      src = []
      @path_to_constraint.each do |obj|
        next if obj.is_a? Netlist::Gate
        next if obj.is_a?(Netlist::Port) and (obj.is_input? and !obj.is_global?)

        obj_name = obj.get_full_name
        src << "(declare-const t_#{@constraint_index} Int)"
        src << if @constraint_index.zero?
                 "(assert (> t_#{@constraint_index} 0))"
               else
                 "(assert (> t_#{@constraint_index} t_#{@constraint_index - 1}))"
               end
        src << "(assert (< t_#{@constraint_index} #{@crit_path}))"
        src << "(assert (xor (#{@initCirc.name}/#{obj_name} t_#{@constraint_index}) (#{@altCirc.name}/#{obj_name} t_#{@constraint_index})))"
        src << '(check-sat)'
        src << '(push)'
        @constraint_index += 1
      end
      src
    end

    def append_constraints
      src = []
      src += constraint_insert_point
      src += if @path_to_constraint.nil?
               constraint_targeted_output
             else
               constraint_targeted_path
               # src << "(assert (<= t_#{@constraint_index} #{@crit_path}))"
             end
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
      `z3 -smt2 #{@SMTS_PATH} -memory:28672`
    end

    def parse_results2(results)
      res_h = Hash.new { |h, k| h[k] = {} }
      return nil if results.include?('unsat')

      results.delete('sat')
      input_values = results.scan(/\(define-fun\si[0-9]+_[ad]\s\(\)\sBool\n\s+\w+\)/).sort
      input_values.each do |input_value|
        input_value.tr!("\n", '')
        input_value = input_value.split(' ')
        input_name, cycle = input_value[1].split('_')
        value = input_value[4].delete_suffix(')')
        res_h[input_name][cycle] = value
      end
      instant_line = results.scan(/\(define-fun\st_[0-9]+\s\(\)\sInt\s+\w+\)/).last
      @transition_instant = instant_line.split[4]
      res_h
    end

    def parse_results(results)
      res_h = Hash.new { |h, k| h[k] = {} }
      return nil unless results[0] == 'sat'

      results[1..].each_cons(2) do |prev_line, line|
        splitted_prev_line = prev_line.split
        next unless splitted_prev_line[0] == '(define-fun'

        if splitted_prev_line[1].match?(/i[0-9]+_[a,d]/)
          input_name, cycle = splitted_prev_line[1].split('_')
          res_h[input_name][cycle] = line.split[0][...-1]
        end
        @transition_instant = line.split[0][...-1] if splitted_prev_line[1] == 't_a'
      end
      res_h.sort_by { |k, v| k[1..].to_i }.to_h
    end

    def results2vec(results)
      raise 'Error: z3 returns empty string.' if results.empty?

      # results = results.split("\n")
      # raise 'Error: z3 returns empty string.' if results.empty?
      # res_h = parse_results(results)

      res_h = parse_results2(results)

      return nil if res_h.nil?

      tmp = res_h.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(var, sub_h), h|
        sub_h.each do |k, val|
          h[k] << val
        end
      end

      vd = tmp['d']
      va = tmp['a']

      # vd.map! { |val| val == 'true' ? '1' : '0' }
      vd.map! do |val|
        case val
        when 'true'
          '1'
        when 'false'
          '0'
        else
          raise 'Unexpected value encountered'
        end
      end

      # va.map! { |val| val == 'true' ? '1' : '0' }
      va.map! do |val|
        case val
        when 'true'
          '1'
        when 'false'
          '0'
        else
          raise 'Unexpected value encountered'
        end
      end

      [vd.join, va.join]
    end

    def run
      # Generate a solving script
      gen_solving_script
      # Run z3
      results = run_solving_script
      # Convert results in Test Vector Pairk
      results2vec results
    end

    private

    def check_z3
      res = `z3 --version`
      raise "Check z3 installation, 'z3 --version' returned : #{res}" if $CHILD_STATUS.exitstatus.positive?
    end
  end
end
