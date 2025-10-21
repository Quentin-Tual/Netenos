module Verilog
 
  class NetlisterVisitor < Visitor
    attr_reader :netlist
    
    def initialize #, ignore_rise_fall = true
      @netlist=nil
      
      @pdk = JSON.parse(File.read(PDK_JSON))# Récupérer les données dans le hash du PDK
      @wiring = {}
      @sym_tab = {}
      @primary_io_wires = {}
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
      if @sym_tab[wname].nil?
        @sym_tab[wname] = Netlist::Wire.new(wname) 
      elsif @sym_tab[wname]
        @primary_io_wires[wname] = Netlist::Wire.new(wname)
      else
        raise "Error: the wire #{w} has the same name as another object #{@sym_tab[wname]} already created"
      end
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
      if @primary_io_wires[wire_name].nil?
        if @sym_tab[wire_name].nil?
          raise "Error: #{wire_name} not generated from the AST."
        else # Wire the component input port to a primary input
          p <= @sym_tab[wire_name]
        end
      else # Wire the component input port to a wire, then connect this wire to a primary input with the same name
        if @sym_tab[wire_name].nil?
          raise "Error: #{wire_name} not generated from the AST."
        else
          @primary_io_wires[wire_name] <= @sym_tab[wire_name]
          p <= @primary_io_wires[wire_name]
        end
      end
    end

    def wiringCompOutput p, wire_name
      if @primary_io_wires[wire_name].nil?
        if @sym_tab[wire_name].nil?
          raise "Error: #{wire_name} not generated from the AST."
        else # Wire the component output port to a primary outputs
          @sym_tab[wire_name] <= p
        end
      else # Wire the component output port to a wire, then connect this wire to a primary output with the same name
        if @sym_tab[wire_name].nil?
          raise "Error: #{wire_name} not generated from the AST."
        else
          @sym_tab[wire_name] <= @primary_io_wires[wire_name]
          @primary_io_wires[wire_name] <= p
        end
      end
    end

  end # class
end # module