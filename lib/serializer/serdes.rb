require_relative "../netenos.rb"
require_relative "../code.rb"

class Serializer
  def serialize circuit
    puts "serializing '#{circuit.name}'" if $VERBOSE
    sexp=Code.new
    sexp << "(circuit '#{circuit.name}'"
    sexp.indent=2

    @debug_data = {}  
    @debug_data[:ids] = Set.new #DEBUG

    circuit.ports[:in].each do |port|
      sexp << "(input '#{port.name}' (ref #{port.object_id}))"
      @debug_data[:ids] << port.object_id #DEBUG
    end
    circuit.ports[:out].each do |port|
      sexp << "(output '#{port.name}' (ref #{port.object_id}))"
      @debug_data[:ids] << port.object_id #DEBUG
    end

    circuit.components.each do |comp|
      if comp.is_a? Netlist::Buffer
        sexp << "(component '#{comp.name}' '#{comp.class}' #{comp.propag_time[:int_multi]}"
      else
        sexp << "(component '#{comp.name}' '#{comp.class}'"
      end
        sexp.indent=4
      comp.ports[:in].each do |port|
        sexp << "(input '#{port.name}' (ref #{port.object_id}))"
        @debug_data[:ids] << port.object_id #DEBUG
      end
      comp.ports[:out].each do |port|
        sexp << "(output '#{port.name}' (ref #{port.object_id}))"
        @debug_data[:ids] << port.object_id #DEBUG
      end
      sexp.indent=2
      sexp << ")"
    end

    circuit.constants.each do |const|
      sexp << "(constant '#{const.name}' '#{const.class}' (ref #{const.object_id}))"
      @debug_data[:ids] << const.object_id #DEBUG
    end

    # wiring
    circuit.ports[:in].each do |port|
      port.fanout.each do |dest|
        sexp << "(wire (ref #{port.object_id}) (ref #{dest.object_id}))"

        unless @debug_data[:ids].include?(port.object_id)
          raise "DEBUG: Unknown object_id required for #{port} in #{circuit.name}" #DEBUG
        end
        unless @debug_data[:ids].include?(dest.object_id) #DEBUG
          raise "DEBUG: Unknown object_id required for #{dest} in #{circuit.name}" #DEBUG
        end #DEBUG

      end
    end
    circuit.constants.each do |const|
      const.fanout.each do |dest|
        sexp << "(wire (ref #{const.object_id}) (ref #{dest.object_id}))"
        unless @debug_data[:ids].include?(const.object_id)
          raise "DEBUG: Unknown object_id required for #{port} in #{circuit.name}" #DEBUG
        end
        unless @debug_data[:ids].include?(dest.object_id) #DEBUG
          raise "DEBUG: Unknown object_id required for #{dest} in #{circuit.name}" #DEBUG
        end #DEBUG
      end
    end
    circuit.components.each do |comp|
      comp.ports[:out].each do |port|
        port.fanout.each do |dest|
          sexp << "(wire (ref #{port.object_id}) (ref #{dest.object_id}))"
          unless @debug_data[:ids].include?(port.object_id)
            raise "DEBUG: Unknown object_id required for #{port} in #{circuit.name}" #DEBUG
          end
          unless @debug_data[:ids].include?(dest.object_id) #DEBUG
            raise "DEBUG: Unknown object_id required for #{dest} in #{circuit.name}" #DEBUG
          end #DEBUG
        end
      end
    end
    sexp.indent=0
    sexp << ")"
    puts sexp.finalize if $VERBOSE
    @sexp=sexp
  end

  def save_as filename
    File.open(filename,'w'){|f| f.puts @sexp}
  end
end

require 'sxp'
class Deserializer

  def initialize
    @refs={}
    @wires=Hash.new {|h,k| h[k] = []}
  end

  def deserialize filename
    puts "deserializing file '#{filename}'" if $VERBOSE
    sexp=SXP.read(IO.read(filename))
    name=parse_name(sexp)
    netlist=Netlist::Circuit.new(name)
    while sexp.any?
      case header(sexp.first)
      when :input
        netlist << parse_input(sexp.shift)
      when :output
        netlist << parse_output(sexp.shift)
      when :component
        netlist << parse_component(sexp.shift)
      when :constant
        netlist << parse_constant(sexp.shift)
      when :wire
        parse_wire(sexp.shift)
      end
    end
    fix_port_partof(netlist)
    apply_interconnect()
    return netlist
  end

  def parse_name sexp
     sexp.shift #circuit
     sexp.shift #name
  end

  def parse_type sexp
    sexp.shift
  end

  def header sexp
    sexp.first
  end

  def parse_constant sexp
    constant, name, clazzname, sexp_ref=*sexp
    ref,id=sexp_ref
    clazz = Object.const_get(clazzname)
    @refs[id]=constant=clazz.new(name)
  end

  def parse_input sexp
    puts "parsing input" if $VERBOSE
    _,name,sexp_ref=*sexp
    _,id=sexp_ref
    @refs[id]=port=Netlist::Port.new(name,:in,nil)
  end

  def parse_output sexp
    puts "parsing output" if $VERBOSE
    _,name,sexp_ref=*sexp
    _,id=sexp_ref
    @refs[id]=port=Netlist::Port.new(name,:out,nil)
  end
  
  def parse_port sexp, comp
    puts "parsing output" if $VERBOSE
    _,name,sexp_ref=*sexp
    _,id=sexp_ref
    @refs[id] = comp.get_port_named(name)
  end

  def parse_propag_time sexp
    return sexp.shift
  end

  def parse_component sexp
    puts "parsing component" if $VERBOSE
    name=parse_name(sexp)
    type = parse_type(sexp)
    clazz = Object.const_get(type)
    if clazz == Netlist::Buffer
      propag_time = parse_propag_time(sexp)
      comp=clazz.new(name, nil, 1, 1, propag_time: propag_time)
    else
      comp=clazz.new(name)
    end
    while sexp.any?
      parse_port(sexp.shift, comp)
      # case header(sexp.first)
      # when :input
      #   comp << parse_input(sexp.shift, comp)
      # when :output
      #   comp << parse_output(sexp.shift)
      # end
    end
    fix_port_partof(comp)
    comp
  end

  def parse_wire sexp
    puts "parsing wire" if $VERBOSE
    _,ref_src,ref_dst=*sexp
    _,src=*ref_src
    _,dst=*ref_dst
    @wires[src] << dst
  end

  def fix_port_partof comp
    comp.ports.each do |dir,ports|
      ports.each do |port|
        port.partof=comp
      end
    end
  end

  def apply_interconnect
    puts "interconnect..." if $VERBOSE
    @wires.each do |src,dests|
      dests.each do |dst|
        source = @refs[src]
        sink   = @refs[dst]
        puts "connecting #{src}->#{dst}" if $VERBOSE
        sink <= source
      end
    end
  end
end
