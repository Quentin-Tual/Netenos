require_relative '../lib/netenos'

def get_precedence_grid circuit
  @rank_h = Hash.new(0)
  
  circuit.get_inputs.each do |i|
    i.get_sinks.each do |sink|
      propag_precedence(sink.partof, 1)
    end
  end

  return @grid = @rank_h.each_pair.with_object(Hash.new {|h, k| h[k] = [] }){|(key,val),h| h[val] << key}
end

#get_precedence_grid util
def propag_precedence gate, rank
  if rank > @rank_h[gate] 
    @rank_h[gate] = rank
    
    gate.get_sink_gates.select{|sink| !sink.instance_of?(Netlist::Port)}.each do |sink|
      propag_precedence(sink, rank+1)
    end
  end 
end

c = Converter::ConvBlif2Netlist.new.convert("circ.blif", truth_table_format: false)

grid_a = c.get_netlist_precedence_grid
grid_b = get_precedence_grid(c)

pp grid_a 
pp grid_b

pp grid_a == grid_b