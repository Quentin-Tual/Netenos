module SDF

  class DelayGenerator < Visitor
    def initialize netlist, function = :max, inserted_gates: []
      @netlist = netlist
      @delays = nil
      @fun = function
      @pdk_ios = JSON.parse(File.read($PDK_IOS_JSON))
      @SDF_PORT_NAME_SEP = '.' # !!! Extract it from the AST, Modify the parser to get it.
      @inserted_gates = inserted_gates

      # TODO : Add DIVIDER statement handling in the SDF parser
      # TODO : Add Wire declaration having the same name as an input in the Verilog parser
      @current_instance = nil

      # #!DEBUG
      # @netlist.name = @netlist.name + '_alt'
      # @netlist.get_dot_graph
      # @netlist.name.delete_suffix!('_alt')
    end

    def check_name(ast_name, netlist_name)
      ast_name == netlist_name
    end

    def visit_Root subject
      @delays = Delays::SDFDelays.new(@netlist, subject.name)
      subject.subnodes.first.accept(self)
      @delays
    end

    def visit_DELAYFILE subject
      subject.design.accept(self)
      subject.cells.each{|n| n.accept(self)}
    end

    def visit_DESIGN(subject)
      # visitDesign(subject)
        raise "Error: AST design name #{subject.data} does not match netlist name #{@netlist.name}" unless check_name(subject.data, @netlist.name)
    end

    def visit_CELL(subject)
      celltype = subject.celltype.accept(self)
      instance_name = subject.instance.accept(self)
      @current_instance = instance_name
      if celltype == @netlist.name and instance_name == ""  # interconnection delays
        # interconnections = subject.delay.absolute.interconnects
        # interconnections.each{|i| visitInterconnection(i)}
        subject.delay.accept(self)
      else                    # standard cells delays
        comp = @netlist.get_component_named(instance_name)
        # Check celltype of the comp 
        netlist_comp_celltype = comp.class.name.split('::').last.downcase
        if netlist_comp_celltype != celltype
          raise "Error: instance #{instance_name} celltype #{celltype} is different than expected in the netlist #{netlist_comp_celltype}"
        end
        @delays.add(comp, subject.delay.accept(self))
        # comp.propag_time[:sdf] = ((delay.to_f)*1000).to_i
      end
    end
    
    def visit_CELLTYPE(subject)
      subject.data # String expected as data
    end

    def visit_INSTANCE(subject)
      subject.data.name # Ident expected as data
    end

    def visit_DELAY(subject)
      subject.absolute.accept(self)
    end

    def visit_ABSOLUTE(subject)
      comp_delays = []

      subject.subnodes.each do |n|
        if n.instance_of? INTERCONNECT
          n.accept(self)
        else
          comp_delays << n.accept(self)
        end
      end

      if subject.contains_class? IOPATH
        Delays::ArcDelays.new(*comp_delays)
      else 
        nil
      end
    end

    # Possible de traiter les interconnexions comme les iopath ? \
    # en modifiant la fonction add de l'object SDFDelays
    # par exemple quand l'instance est nil ou "" la fonction add ajoute le délai entre deux fils via ArcDelays et 
    def visit_INTERCONNECT(subject)
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
        found_wire = @netlist.wires.find do |w|
          # source has computed source_name as name
          valid_source = w.get_source.get_full_name == source_name
          # sink has computed sink_name as name
          sink_gates = w.get_sinks.collect{|sink| sink.partof}
          valid_sink = sink_gates.one?{|sink_g| @inserted_gates.include? sink_g}
          valid_source and valid_sink
        end

        if found_wire.nil?
        #   found_wire = found_wire.first
        # else
          # Raise an error if not found or multiple possibilities
          raise "Error: No wire matching with the INTERCONNECTION #{subject}, connecting #{subject.wire.source_name.name} (#{source_name} in the netlist) to #{subject.wire.sink_name.name} (#{sink_name} in the netlist)"
        else
          @delays.add(found_wire, Delays::RiseFallDelay.new(*subject.delays.accept(self)))
        end
      else
        @delays.add(found_wire, Delays::RiseFallDelay.new(*subject.delays.accept(self)))
      end 
    end
    
    def visit_IOPATH(subject)
      if @current_instance.nil?
        raise "Error: No current instance defined."
      end
      
      source_name = get_eq_name("#{@current_instance}#{@SDF_PORT_NAME_SEP}#{subject.wire.source_name.name}")
      sink_name = get_eq_name("#{@current_instance}#{@SDF_PORT_NAME_SEP}#{subject.wire.sink_name.name}")

      return source_name, sink_name, Delays::RiseFallDelay.new(*subject.delays.accept(self))
    end

    def visit_DelayTable subject
      return Delays::MinTypMaxDelay.new(*subject.rise.accept(self)), Delays::MinTypMaxDelay.new(*subject.fall.accept(self))
    end

    def visit_DelayArray subject
      min_dly = (subject.max.to_f * 1000).to_i
      typ_dly = (subject.max.to_f * 1000).to_i
      max_dly = (subject.max.to_f * 1000).to_i
      return min_dly, typ_dly, max_dly
    end

    # def visit_Ident subject
    #   subject.name
    # end

    # def visit_Time subject
    #   subject.val
    # end

    def get_eq_name name
      instance_name, port_name = name.split(@SDF_PORT_NAME_SEP)
      celltype = @netlist.get_component_named(instance_name).class.name.split('::').last.downcase
      # Convert source_name using PDK_JSON and celltype
      if @pdk_ios[celltype]["inputs"].include? port_name
        "#{instance_name}#{$FULL_PORT_NAME_SEP}i#{@pdk_ios[celltype]["inputs"].index(port_name)}" 
      elsif @pdk_ios[celltype]["outputs"].include? port_name
        "#{instance_name}#{$FULL_PORT_NAME_SEP}o#{@pdk_ios[celltype]["outputs"].index(port_name)}" 
      end
    end

  end
end