require_relative "../netenos.rb"
require_relative "../converter/code.rb"

class Serializer
  def serialize circuit
    puts "serializing '#{circuit.name}'" if $VERBOSE
    sexp=Code.new
    sexp << "(circuit '#{circuit.name}'"
    sexp.indent=2

    circuit.ports[:in].each do |port|
      sexp << "(input '#{port.name}' (ref #{port.object_id}))"
    end
    circuit.ports[:out].each do |port|
      sexp << "(output '#{port.name}' (ref #{port.object_id}))"
    end

    circuit.components.each do |comp|
      if comp.is_a? Netlist::Buffer
        sexp << "(component '#{comp.name}' '#{comp.class}' #{comp.propag_time[:int_multi]})"
      else
        sexp << "(component '#{comp.name}' '#{comp.class}'"
      end
        sexp.indent=4
      comp.ports[:in].each do |port|
        sexp << "(input '#{port.name}' (ref #{port.object_id}))"
      end
      comp.ports[:out].each do |port|
        sexp << "(output '#{port.name}' (ref #{port.object_id}))"
      end
      sexp.indent=2
      sexp << ")"
    end

    circuit.constants.each do |const|
      sexp << "(constant '#{const.class}' (ref #{const.object_id}))"
    end

    # wiring
    circuit.ports[:in].each do |port|
      port.fanout.each do |dest|
        sexp << "(wire (ref #{port.object_id}) (ref #{dest.object_id}))"
      end
    end
    circuit.constants.each do |const|
      const.fanout.each do |dest|
        sexp << "(wire (ref #{const.object_id}) (ref #{dest.object_id}))"
      end
    end
    circuit.components.each do |comp|
      comp.ports[:out].each do |port|
        port.fanout.each do |dest|
          sexp << "(wire (ref #{port.object_id}) (ref #{dest.object_id}))"
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
    @wires={}
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
    constant, clazzname, sexp_ref=*sexp
    ref,id=sexp_ref
    clazz = Object.const_get(clazzname)
    @refs[id]=constant=clazz.new()
  end

  def parse_input sexp
    puts "parsing input" if $VERBOSE
    input,name,sexp_ref=*sexp
    ref,id=sexp_ref
    @refs[id]=port=Netlist::Port.new(name,:in,nil)
  end

  def parse_output sexp
    puts "parsing output" if $VERBOSE
    input,name,sexp_ref=*sexp
    ref,id=sexp_ref
    @refs[id]=port=Netlist::Port.new(name,:out,nil)
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
      comp=clazz.new(propag_time, name, nil, 0, 0)
    else
      comp=clazz.new(name, nil, 0, 0)
    end
    while sexp.any?
      case header(sexp.first)
      when :input
        comp << parse_input(sexp.shift)
      when :output
        comp << parse_output(sexp.shift)
      end
    end
    fix_port_partof(comp)
    comp
  end

  def parse_wire sexp
    puts "parsing wire" if $VERBOSE
    wire,ref_src,ref_dst=*sexp
    ref,src=*ref_src
    ref,dst=*ref_dst
    @wires[src]||=[]
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
