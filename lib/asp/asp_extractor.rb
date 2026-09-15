module ASP
  class ASPExtractor < Netlist::BackwardUniqDFS
    attr_reader :rules

    def initialize(nl, delays, crit_path_delay, sdf_col: :typ)
      super(nl)
      @delays = delays
      @gate_min_dly = @nl.get_comp_min_delay(:sdf, dly_db: @delays)
      @sdf_col = sdf_col
      @src = []
      @rules = []
      @domains = []
      @signals = []
      @primaries = []
      @crit_path_delay = crit_path_delay
    end

    def save_as(path)
      File.write(path, print, mode: 'a')
    end

    def print
      "#{domains_writeup}\n#{@rules.join("\n")}\n"
    end

    def visit_Gate(g)
      super

      @signals << g.get_output.get_asp_name
      ioarcs = get_ioarcs(g)

      rise_dlys, fall_dlys = get_rise_fall_dlys(g, ioarcs)
      rise_dly = rise_dlys.max
      fall_dly = fall_dlys.max

      @rules << ASP::GateASP.new(
        g.get_inputs.collect { |gip| gip.get_source.get_asp_name },
        g.get_output.get_asp_name,
        g.class::RUBY_FUN_PROC,
        delay_r: rise_dly,
        delay_f: fall_dly
      ).to_asp
    end

    def visit_Wire(w)
      super

      wname = w.get_asp_name
      @signals << wname

      rise_dly = @delays.get_wire_dly(w, :rise, @sdf_col)
      fall_dly = @delays.get_wire_dly(w, :fall, @sdf_col)

      s = w.get_source
      sname = s.get_asp_name

      @rules << "% Wire: #{w.get_full_name}"
      @rules << "level0(#{wname}, 1) :- level0(#{sname}, 1)."
      @rules << "level0(#{wname}, 0) :- level0(#{sname}, 0)."
      @rules << "event(#{wname}, r, T) :- event(#{sname}, r, T-#{rise_dly}), time(T)."
      @rules << "event(#{wname}, f, T) :- event(#{sname}, f, T-#{fall_dly}), time(T)."
    end

    private

    def domains_writeup
      @domains << @signals.collect { |str| "signal(#{str})." }.join(' ')
      @domains << @primaries.collect { |str| "primary(#{str})." }.join(' ')
      @domains << 'edge(r). edge(f).'
      @domains << 'val(0). val(1).'
      @domains << "time(0..#{@crit_path_delay})."
      @domains.join("\n")
    end

    def visit_prim_input(ip)
      pip_name = ip.get_full_name
      @signals << pip_name
      @primaries << pip_name
    end

    def visit_prim_output(op)
      super

      oname = op.get_asp_name
      sname = op.get_source.get_asp_name

      @rules << "% Primary output : #{oname}"
      @rules << "level0(#{oname}, 1) :- level0(#{sname}, 1)."
      @rules << "level0(#{oname}, 0) :- level0(#{sname}, 0)."
      @rules << "event(#{oname}, r, T) :- event(#{sname}, r, T), time(T)."
      @rules << "event(#{oname}, f, T) :- event(#{sname}, f, T), time(T)."

      # Ajouter des choses ici et à la fin de la méthode pour écrire les "domaines" par exemple ?
      pip_name = op.get_asp_name
      @signals << pip_name
    end

    def get_ioarcs(g)
      g.get_inputs.collect do |ip|
        [ip.get_full_name, g.get_output.get_full_name]
      end
    end

    def get_rise_fall_dlys(g, ioarcs)
      %i[rise fall].collect do |transi|
        ioarcs.collect do |ioarc|
          @delays.get_gate_dly(
            g,
            ioarc,
            transi,
            @sdf_col
          )
        end
      end
    end
  end
end
