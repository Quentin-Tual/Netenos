module Netlist
  class ForwardDFS < Netlist::CircuitVisitor
    def initialize nl
      super
    end

    def visit_Port p
      # return if visited?(p)
      print_obj_name(p) if $DEBUG

      primary_port = p.is_global?
      input_port = p.is_input?

      # Plusieurs cas selon que p est :
      #   - une sortie primaire 
      #   - la sortie d'une porte
      #   - l'entrée d'une porte ?
      #   - une entrée primaire
      
      case [primary_port, input_port]
      when [false, false] # sortie d'une porte (le + fréquent)
        visit_gate_output(p)
      when [true, true]   # entrée primaire (le 2eme + fréquent) 
        visit_prim_input(p)
      when [true, false]  # sortie primaire (le 3 eme + fréquent)
        visit_prim_output(p)
      when [false, true]
        visit_gate_input(p)
      else # entrée d'une porte (ne devrait jamais arriver)
        raise "Error : unexpected port #{p.get_full_name} encountered during the visit of #{@nl.name}"
      end
    end

    # Modulariser cette méthode
    def visit_Gate g      
      # return if visited?(g)
      print_obj_name(g) if $DEBUG

      # visit sink ports
      sps = g.get_output.get_sinks 
      sps.collect do |sp|
        sp.accept(self)
      end
    end

    def visit_Wire w
      # return if visited?(w)
      print_obj_name(w) if $DEBUG
      w.get_sinks.collect do |sink|
        sink.accept(self)
      end
    end

    private

    def print_obj_name(obj)
      obj_name = obj.is_a?(Netlist::Gate) ? obj.name : obj.get_full_name
      puts obj_name if $DEBUG
    end

    def visit_gate_output(op)
      op.get_sinks.collect do |sink|
        sink.accept(self)
      end
    end

    def visit_gate_input(ip)
      ip.partof.accept(self)
    end

    def visit_prim_input(ip)
      ip.get_sinks.collect do |sink|
        sink.accept(self)
      end
    end

    def visit_prim_output(op)
      # ends the visit branch
    end
  end
end
