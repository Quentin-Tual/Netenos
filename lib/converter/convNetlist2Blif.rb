module Converter
  
  class ConvNetlist2Blif 
    BLIF_IN_NAME_SEP='_'

    def initialize
    end

    def blif_full_name p
      p.get_full_name.tr($FULL_PORT_NAME_SEP,BLIF_IN_NAME_SEP)
    end

    def print circuit, filename="#{circuit.name}.blif"
      blif=Code.new
      blif << header(circuit.name)
      blif << inputs(circuit.get_inputs)
      blif << outputs(circuit.get_outputs)
      blif << gates(circuit)
      blif.save_as filename
      filename
    end

    def header name
      code=Code.new
      code << ".model #{name}"
    end

    def inputs inputs_list
      code=Code.new
      input_str = inputs_list.collect{|i| i.name}.join(" ")
      code << ".inputs #{input_str}"
      code
    end

    def outputs outputs_list
      code=Code.new
      output_str = outputs_list.collect{|o| o.name}.join(" ")
      code << ".outputs #{output_str}"
      code
    end

    def gates circuit
      code=Code.new

      @grid = circuit.get_netlist_precedence_grid
      get_sym_tab(circuit)

      inputs_list = circuit.get_inputs

      @grid.each do |rank, gate_list|
        gate_list.each do |g|
          code << gate(g)
        end
      end
      code
    end

    # def get_precedence_grid circuit
    #   @rank_h = Hash.new(0)
      
    #   circuit.inputs.each do |i|
    #     i.sinks.each do |sink|
    #       propag_precedence(sink.component, 1)
    #     end
    #   end

    #   return @grid = @rank_h.each_pair.with_object(Hash.new {|h, k| h[k] = [] }){|(key,val),h| h[val] << key}
    # end

    # #get_precedence_grid util
    # def propag_precedence gate, rank
    #   if rank > @rank_h[gate]
    #     @rank_h[gate] = rank
        
    #     gate.sinks.select{|sink| !sink.component.instance_of?(Circuit)}.each do |sink|
    #       propag_precedence(sink.component, rank+1)
    #     end
    #   end 
    # end

    def get_sym_tab(circuit)
      @sym_tab = Hash.new

      circuit.get_inputs.each do |i|
        @sym_tab[i] = i.name
      end

      circuit.get_outputs.each do |o|
        @sym_tab[o] = o.name
      end

      circuit.components.each do |g|
        prim_out = g.get_sink_gates.find{|sink| circuit.get_outputs.include? sink}
        if prim_out.nil? # Si la sortie de la porte n'est pas reliée à une sortie primaire, lui donné un nouveau symbole (son nom)
          g.get_outputs.each do |o|
            @sym_tab[o] = blif_full_name(o)
          end
        else # Si la sortie de la porte est reliée à une sortie primaire, associé le même symbole (celui de la sortie primaire) à la sortie de la porte
          g.get_outputs.each do |o|
            @sym_tab[o] = blif_full_name(prim_out)
          end
        end
      end
    end

    def gate g
      code=Code.new
      fanin = [*('A'..'X')]
      sources = g.get_inputs.collect.with_index{|i,n| "#{fanin[n]}=#{@sym_tab[i.get_source]}"}.join(" ")
      sink = "Y=#{@sym_tab[g.get_outputs[0]]}"
      code << ".gate #{gate_type(g)} #{sources} #{sink}" # #{g.name}"
      code
    end

    def gate_type g
      case g
      when Netlist::Not
          return "INV1"
      when Netlist::Buffer
          return "BUF1"
      else
          return g.class.name.split(":")[-1].upcase
      end
    end

  end

end