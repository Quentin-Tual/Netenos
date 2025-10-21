module SDF
  class Deparser < Visitor
    def initialize path
      @path = path
      @txt = Code.new(indent_sym: " ")
    end

    def visit(subject)
      case subject
      when SDF::Root 
        visit(subject.subnodes.first)
        @txt.save_as(@path)
      when SDF::Node
        visit_node(subject)
      when SDF::DelayNode 
        visit_delaynode(subject)
      when SDF::EdgeNode
        visit_edgenode(subject)
      else
        raise "Error: Unexpected class object encountered #{subject}. Expecting a Node or an EdgeNode"
      end
    end

    def visit_node(subject)
      keyword = subject.class.name.split('::')[1]
      @txt << "(#{keyword}"
      @txt.indent += 1
      subject.subnodes.each{|n| visit(n)}
      @txt.indent -= 1
      @txt << ')'
    end
    
    def visit_edgenode(subject)
      keyword = subject.class.name.split('::')[1]
      value = format_data(subject.data)
      sep_space = ((value == "") ? "" : " ") 
      @txt << "(#{keyword}#{sep_space}#{value})"
    end

    def visit_delaynode(subject)
      keyword = subject.class.name.split('::')[1]
      source,sink = visit_wire(subject.wire)
      formatted_delays = visit_delaytable(subject.delays)

      @txt << "(#{keyword} #{source} #{sink} #{formatted_delays})"
    end

    def visit_wire(subject)
      return subject.source_name.name, subject.sink_name.name
    end
    
    def visit_delaytable(subject)
      "(#{visit_delayarray(subject.rise)}) (#{visit_delayarray(subject.fall)})"
    end

    def visit_delayarray(subject)
      subject.attr_list.join(':')
    end

    def format_data d
      case d 
      when Ident
        d.name
      when Time
        d.val
      when String
        "\"#{d}\""
      else
        raise "Error: unexpected type encountered #{d}"
      end
    end
  end # class
end # module