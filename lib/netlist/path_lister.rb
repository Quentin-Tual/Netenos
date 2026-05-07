module Netlist
  class PathLister < Netlist::ForwardDFS 
    attr_reader :authorized_list
    def initialize nl, stop_sig, authorized_list = []
      super(nl)
      
      @stop_sig = stop_sig
      if authorized_list.empty?
        all_nl_obj = nl.components + \
          nl.get_inputs + \
          nl.get_outputs + \
          nl.wires + \
          nl.components.collect{|g| g.get_inputs + g.get_outputs}.flatten
        @authorized_list = Set.new(all_nl_obj)
      else 
        @authorized_list = authorized_list
      end
    end

    def visit_Port p
      return [p] if is_stopsig?(p)
      forward_paths = super if authorized?(p)
      forward_paths.flatten!(1) if forward_paths.depth > 2
      forward_paths.map! do |path|
        [p] + path
      end
    end

    # Modulariser cette méthode
    def visit_Gate g      
      return [g] if is_stopsig?(g)
      forward_paths = super if authorized?(g)
      forward_paths.flatten!(1) if forward_paths.depth > 2
      forward_paths.map! do |path|
        [g] + path
      end
    end

    def visit_Wire w
      return [w] if is_stopsig?(w)
      forward_paths = super if authorized?(w)
      forward_paths.flatten!(1) if forward_paths.depth > 2
      forward_paths.map! do |path|
        [w] + path
      end
    end

    private

    def is_stopsig? obj
      obj == @stop_sig
    end

    def authorized? obj
      @authorized_list.include?(obj)
    end

    # def visit_gate_output(op)
    #   super 
      
    # end

    # def visit_gate_input(ip)
    #   super 

    # end

    # def visit_prim_input(ip)
    #   super 

    # end

    def visit_prim_output(op)
      # super
      [[op]]
    end
  end
end
