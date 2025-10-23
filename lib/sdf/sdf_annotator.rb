module SDF

  class Annotator < Visitor
    def initialize netlist, function = :max
      @netlist = netlist
      @fun = function
      @pdk = JSON.parse(File.read($PDK_JSON))
      @SDF_PORT_NAME_SEP = '.' # !!! Extract it from the AST, Modify the parser to get it.

      # TODO : Add DIVIDER statement handling in the SDF parser
      # TODO : Add Wire declaration having the same name as an input in the Verilog parser
    end

    def check_name(ast_name, netlist_name)
      ast_name == netlist_name
    end

    def visit(subject)
      case subject
      when Root 
        visit(subject.subnodes.first)
      when DELAYFILE
        visitDelayFile(subject)
      else
        raise "Error: Unexpected AST object encountered #{subject}, not handled."
      end
    end

    def visitRoot subject
      visit(subject.subnodes.first)
    end

    def visitDelayFile subject
      visitDesign(subject.design)
      subject.cells.each{|n| visitCell(n)}
    end

    def visitDesign(subject)
      # visitDesign(subject)
        raise "Error: AST design name #{subject.data} does not match netlist name #{netlist.name}" unless check_name(subject.data, @netlist.name)
    end

    def visitCell(subject)
      celltype = visitCellType(subject.celltype)
      instance_name = visitInstance(subject.instance)
      if celltype == @netlist.name and instance_name == ""  # interconnection delays
        interconnections = subject.delay.absolute.interconnects
        interconnections.each{|i| visitInterconnection(i)}
      else                    # standard cells delays
        comp = @netlist.get_component_named(instance_name)
        # Check celltype of the comp 
        netlist_comp_celltype = comp.class.name.split('::').last.downcase
        if netlist_comp_celltype != celltype
          raise "Error: instance #{instance_name} celltype #{celltype} is different than expected in the netlist #{netlist_comp_celltype}"
        end
        delay = visitDelay(subject.delay)
        comp.propag_time[:sdf] = ((delay.to_f)*1000).to_i
      end
    end
    
    def visitCellType(subject)
      subject.data # String expected as data
    end

    def visitInstance(subject)
      subject.data.name # Ident expected as data
    end

    def visitDelay(subject)
      visitAbsolute(subject.absolute)
    end

    def visitAbsolute(subject)
      subject.apply_fun(@fun)
    end

    def visitInterconnection(subject)
      w = subject.wire
      # Find corresponding source in the netlist
      source_name = w.source_name.name
      if source_name.include?(@SDF_PORT_NAME_SEP) # the source is a port of an standard cell instance 
        source_name = get_eq_name(source_name)
      end # else the source is a primary input

      # Find corresponding sink in the netlist
      sink_name = w.sink_name.name
      if sink_name.include?(@SDF_PORT_NAME_SEP) # the source is a port of an standard cell instance 
        sink_name = get_eq_name(sink_name)
      end # else the source is a primary input
        
      # Find corresponding wire in the netlist if it exists
      found_wire = @netlist.wires.find do |w|
        # source has computed source_name as name
        valid_source = w.get_source.get_full_name == source_name
        # sink has computed sink_name as name
        valid_sink = w.get_sinks.collect{|sink| sink.get_full_name}.include? sink_name
        valid_source and valid_sink 
      end
      if found_wire.nil?
        # Raise an error if not found
        raise "Error: No wire matching with the INTERCONNECTION #{subject}, connecting #{subject.wire.source_name.name} (#{source_name} in the netlist) to #{subject.wire.sink_name.name} (#{sink_name} in the netlist)"
      else
        # Annotate the sdf delay to the wire according to the function specified at instanciation 
        found_wire.propag_time[:sdf] = (subject.apply_fun(@fun)*1000).to_i 
      end 
    end
    
    def get_eq_name name
      instance_name, port_name = name.split(@SDF_PORT_NAME_SEP)
      celltype = @netlist.get_component_named(instance_name).class.name.split('::').last.downcase
      # Convert source_name using PDK_JSON and celltype
      if @pdk[celltype]["inputs"].include? port_name
        "#{instance_name}#{$FULL_PORT_NAME_SEP}i#{@pdk[celltype]["inputs"].index(port_name)}" 
      elsif @pdk[celltype]["outputs"].include? port_name
        "#{instance_name}#{$FULL_PORT_NAME_SEP}o#{@pdk[celltype]["outputs"].index(port_name)}" 
      end
    end

  end
end