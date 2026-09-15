require 'English'
module AtetaAddOn
  class HtpgAsp
    TMP_ASP_PATH = "#{$TMP_PATH}/htpg_asp"

    def initialize(initCirc, init_dly_db, crit_path, altCirc, alt_dly_db, insertPointName, targetedOutputName,
                   dly_db_col: :typ)
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

      @dly_db_col = @sdf_col = dly_db_col

      # If it does not exist, create the temporary dir to store smt files
      Dir.mkdir(TMP_ASP_PATH) unless Dir.exist?(TMP_ASP_PATH)
      @src = []
      asp_file_name = "#{@insertPointName.tr('/', '_')}_#{@targetedOutputName}.lp"
      @ASPS_PATH = "#{TMP_ASP_PATH}/#{@initCirc.name}/#{asp_file_name}"

      if Dir.exist?("#{TMP_ASP_PATH}/#{@initCirc.name}")
        if File.exist?("#{TMP_ASP_PATH}/#{@initCirc.name}/#{asp_file_name}")
          `rm #{"#{TMP_ASP_PATH}/#{@initCirc.name}/#{asp_file_name}"}`
        end
      else
        Dir.mkdir("#{TMP_ASP_PATH}/#{@initCirc.name}")
      end

      # TODO : Check if z3 is installed and accessible (in the path), far more earlier, maybe in the gem requirements ?
      check_clingo
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

    def check_clingo
      res = `clingo --version`
      raise "Check clingo installation, 'clingo --version' returned : #{res}" if $CHILD_STATUS.exitstatus.positive?
    end

    def gen_solving_script
      global_clauses
      init_circ_representation
      alt_circ_representation
      append_target_event
      File.write(@ASPS_PATH, @src.join("\n"), mode: 'a')
    end

    def global_clauses
      @src << ASP::ASPGlobalClausesGenerator.new.print
    end

    def init_circ_representation
      asp_extractor = ASP::ASPExtractor.new(@initCirc, @init_dly_db, @crit_path, sdf_col: @sdf_col)
      targeted_output = @initCirc.get_port_named(@targetedOutputName)
      targeted_output.accept(asp_extractor)
      @src << asp_extractor.print # (@ASPS_PATH)
    end

    def alt_circ_representation
      asp_extractor = ASP::ASPExtractor.new(@altCirc, @alt_dly_db, @crit_path, sdf_col: @sdf_col)
      targeted_output = @altCirc.get_port_named(@targetedOutputName)
      targeted_output.accept(asp_extractor)
      @src << asp_extractor.print # (@ASPS_PATH)
    end

    def append_target_event
      init_output_name = "#{@initCirc.name}_#{@targetedOutputName}"
      alt_output_name = "#{@altCirc.name}_#{@targetedOutputName}"

      @src << '% ---------- Target: force y and yp to diverge (reveal the extra delay) ----------'
      @src << "diverges(T) :- event(#{init_output_name}, Tr, T), not event(#{alt_output_name}, Tr, T), edge(Tr), time(T)."
      @src << "diverges(T) :- event(#{alt_output_name}, Tr, T), not event(#{init_output_name}, Tr, T), edge(Tr), time(T)."
      @src << 'found_divergence :- diverges(T).'
      @src << ':- not found_divergence.'

      @src << '#show.'
      @src << '#show level0(S,V) : level0(S,V), primary(S).'
      @src << '#show level(S,V,0) : level(S,V,0), primary(S).'
      @src.join("\n")
    end

    def run_solving_script
      `clingo --outf=2 #{@ASPS_PATH}`
    end

    def results2vec(results)
      res_h = JSON.parse(results)
      return nil if res_h['Result'] == 'UNSATISFIABLE'
      # Not sat but not unsat => certainly an error
      raise "Error: clingo error -> #{results}." if res_h['Result'] != 'SATISFIABLE'

      before, after = parse_results(res_h)

      vd = []
      va = []

      @initCirc.get_inputs.each do |ip|
        vd << (before[ip.name] || '1')
        va << (after[ip.name] || '1')
      end

      [vd.join, va.join]
    end

    def parse_results(res_h)
      values = res_h['Call'].first['Witnesses'].first['Value']

      before = {}
      after = {}
      values.each do |word|
        tmp = word.delete_suffix(')').split('(').last
        sig, val = tmp.split(',')

        if word.include?('level0')
          before[sig] = val
        else
          after[sig] = val
        end
      end

      [before, after]
    end
  end
end
