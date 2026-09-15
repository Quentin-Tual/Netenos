module ASP
  class ASPGlobalClausesGenerator
    def initialize
      @src = []
    end

    def print
      vd_values
      va_values
      vd_va_impossible_transitions
      bhv_depends_on_va_vd
      level_persistence
      consistency
      steady_shorthand
      @src
    end

    private

    def vd_values
      @src << '% ---------- Vd : settled state BEFORE the clock edge (T=0) ----------'
      @src << '% Guessed only for primary inputs...'
      @src << '1 { level0(S, V) : val(V) } 1 :- primary(S).'
    end

    def va_values
      @src << '% ---------- Va : the clock edge (T=0) applies Vd -> Va on primary inputs ----------'
      @src << '% 0 or 1 edge event per primary signal, exactly at the clock edge (T=0).'
      @src << '0 { event(S, Tr, 0) : edge(Tr) } 1 :- primary(S).'
    end

    def vd_va_impossible_transitions
      @src << "% Can't rise if Vd already had it at 1, can't fall if Vd already had it at 0."
      @src << ':- event(S, r, 0), level0(S, 1).'
      @src << ':- event(S, f, 0), level0(S, 0).'
    end

    def bhv_depends_on_va_vd
      @src << '% ---------- level(S,V,0): the value FROM the clock edge onward (= Va) ----------'
      @src << 'level(S, 1, 0) :- level0(S, 0), event(S, r, 0), signal(S).'
      @src << 'level(S, 0, 0) :- level0(S, 1), event(S, f, 0), signal(S).'
      @src << 'level(S, V, 0) :- level0(S, V), not event(S, r, 0), not event(S, f, 0), val(V), signal(S).'
    end

    def level_persistence
      @src << '% ---------- Frame axioms : level persists unless a transition flips it ----------'
      @src << 'level(S, 1, T) :- level(S, 0, T-1), event(S, r, T), signal(S), time(T).'
      @src << 'level(S, 0, T) :- level(S, 1, T-1), event(S, f, T), signal(S), time(T).'
      @src << 'level(S, V, T) :- level(S, V, T-1), not event(S, r, T), not event(S, f, T), val(V), signal(S), time(T).'
    end

    def consistency
      @src << "% ---------- Consistency : can't rise if already 1, can't fall if already 0 ----------"
      @src << ':- event(S, r, T), level(S, 1, T-1).'
      @src << ':- event(S, f, T), level(S, 0, T-1).'
    end

    def steady_shorthand
      @src << '% ---------- Derive S0/S1 "steady" shorthand from level ----------'
      @src << 'steady(S, s0, T) :- level(S, 0, T).'
      @src << 'steady(S, s1, T) :- level(S, 1, T).'
    end
  end
end
