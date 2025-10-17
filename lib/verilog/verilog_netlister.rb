module Verilog
 
  class NetlisterVisitor < Visitor
    attr_reader :netlist
    
    def initialize #, ignore_rise_fall = true
      @netlist=nil
      
      @pdk = JSON.parse(File.read(PDK_JSON))# Récupérer les données dans le hash du PDK
      @wiring = {}
      @sym_tab = {}
    end

    def visit(root)
      if root.class == Verilog::Root
        visitModule(root.mod)
      else
        raise "Error: Expecting a Verilog::Root class, encountered a #{root.class}"
      end
      
      wiringStep
      @netlist
    end

    def visitModule mod
      @netlist = Netlist::Circuit.new(visitIdent(mod.name))
      mod.inputs.each{|o| @netlist << visitInput(o)}
      mod.outputs.each{|o| @netlist << visitOutput(o)}
      mod.instances.each{|o| @netlist << visitInstance(o)}
      mod.wires.each{|o| w=visitWire(o); @netlist << w unless w.nil?;}
    end

    def visitInput ip
      portname = visitIdent(ip.name)
      @sym_tab[portname] = Netlist::Port.new(portname, :in)
    end

    def visitOutput op
      portname = visitIdent(op.name)
      @sym_tab[portname] = Netlist::Port.new(portname, :out)
    end

    def visitInstance inst
      stdcell_name = visitIdent(inst.module_name)
      klassname = stdcell_name.capitalize
      if !Netlist.class_exists?("Netlist::" + klassname)
        klass = Netlist.create_class(klassname, "Gate")
      else
        klass = Netlist.const_get(klassname)
      end
      
      nb_inputs = @pdk[stdcell_name]["inputs"].size # !!! Récupérer l'info dans le JSON généré par le verilog grepper
      nb_outputs = @pdk[stdcell_name]["outputs"].size
      instance_name = visitIdent(inst.instance_name) # ! Replaces every '_' by a '-' for compatibility with Netenos
      comp = @sym_tab[instance_name] = klass.new(instance_name, @netlist, nb_inputs, nb_outputs)
      comp.get_ports.each{|p| @sym_tab[p.get_full_name] = p}

      visitPortmap(inst.port_map, stdcell_name, instance_name) unless inst.port_map.nil?
      comp
    end

    def visitPortmap portmap, stdcell_name, instance_name
      # Convertit le nom des ports "A","B",etc en "i0", "i1", etc
      portmap.elements.each do |pm_elt|
        visitPortmapElt pm_elt, stdcell_name, instance_name
      end 
    end

    def visitPortmapElt portmap_element, stdcell_name, instance_name

      port_name = equivalentPortName(stdcell_name, instance_name, visitIdent(portmap_element.port))
      wire_name = visitIdent(portmap_element.wire) # ! Replaces every '_' by a '-' for compatibility with Netenos
      if @wiring[instance_name].nil?
        @wiring[instance_name] = {port_name => wire_name}
      else
        @wiring[instance_name][port_name] = wire_name
      end
    end

    def visitWire w
      # TODO : Create a Buffer as an object with an input and an output
      wname = visitIdent(w.name) # ! Replaces every '_' by a '-' for compatibility with Netenos
      @sym_tab[wname] = Netlist::Wire.new(wname) if @sym_tab[wname].nil?
    end

    def visitIdent i
      i.name
    end

    def equivalentPortName stdcell_name, inst_name, port_name
      if @pdk[stdcell_name]["inputs"].include? port_name
        "i#{@pdk[stdcell_name]["inputs"].index(port_name)}"
      elsif @pdk[stdcell_name]["outputs"].include? port_name
        "o#{@pdk[stdcell_name]["outputs"].index(port_name)}"
      else
        raise "Error: No port #{port_name} in #{stdcell_name} standard cell. Be assured to load the pdk JSON."
      end
    end

    def wiringStep
      @wiring.each do |instance_name, sub_h|
        sub_h.each do |port_name, wire_name|
        # comp_port, signal = pm_elt.attr_list.collect{|e| visitIdent(e)}
          p = @sym_tab["#{instance_name}#{$FULL_PORT_NAME_SEP}#{port_name}"] 
          
          if p.is_input? # p is the sink
            wiringCompInput(p, wire_name)
          else # p is the source
            wiringCompOutput(p, wire_name)
          end
        end
      end
    end

    def wiringCompInput p, wire_name
      if @sym_tab[wire_name].nil? # p is not connected to a primary port
        if @sym_tab[wire_name].nil? # p is not connected to a wire
          raise "Error: #{wire_name} not generated from the AST."
        else # p is connected to a wire (represented as a Buffer obj in the netlist)
          w = @sym_tab[wire_name]
          p <= w
        end
      else # p is connected to a primary port
        source = @sym_tab[wire_name]
        # if source.is_input?
        p <= source
        # else
        #   # Should not be possible should raise an error
        #   raise "Error: #{p.get_full_name} (a sink) should not be connected to #{wire_name} (also a sink)."
        # end
      end
    end

    def wiringCompOutput p, wire_name
      if @sym_tab[wire_name].nil? # p is not connected to a primary port
        if @sym_tab[wire_name].nil? # p is not connected to a wire
          raise "Error: #{wire_name} not generated from the AST."
        else # p is connected to a wire (represented as a Buffer obj in the netlist)
          w = @sym_tab[wire_name]
          w <= p 
        end
      else # p is connected to a primary port
        sink = @sym_tab[wire_name]
        # if sink.is_output?
        sink <= p
        # else
        #   # Should not be possible should raise an error
        #   raise "Error: #{p.get_full_name} (a source) should not be connected to #{wire_name} (also a source)."
        # end
      end
    end

  end # class
end # module