
module Verilog

  class Token
    attr_reader :kind,:val,:line
    def initialize kind,val,line
       @kind,@val,@line=kind,val,line
    end
  end

  class Grepper

    SYMBOL="+-*/,.()\";:`!=&|$><@'~^".chars.map{|c| "\\#{c}"}.join

    attr_accessor :src,:line,:tokens

    def open filename
      puts "grepping #{filename}"
      @basename=File.basename(filename,'.v')
      @src=IO.read(filename)
      @line=1
    end

    def lex
      puts "lexing..."
      @tokens=[]
      comment_section = false
      while src.size>0 # and @line < 5000 # DEBUG
        token=nil
      
        if comment_section
          case src
          when /\A.*\*\//
            comment_section = false
          when /\A.*$\n/
            @line += 1
          else
            # Never expected
            raise "Internal error, unexpected state encountered."
          end
        else
          case src
          when /\A\/\*/ # Comment section
            # raise "WIP"
            # Matcher et supprimer tout le texte jusqu'au prochain '*/'
            comment_section = true
          when /\A\/\/.*$/ # One line comment
            # @line += 1
          when /\A\s+/
            @line += $&.count("\n")
          when /\A(`.*\n)+/
            @line += $&.count("\n")
          when /\A[#{SYMBOL}]/
          when /\A\d+/
          when /\A[\n]+/
            @line += $&.count("\n")
          when /\Amodule/
            token=Token.new(:module,$&,line)
          when /\Aendmodule/
            token=Token.new(:endmodule,$&,line)
          when /\Ainput/
            token=Token.new(:input,$&,line)
          when /\Aoutput/
            token=Token.new(:output,$&,line)
          when /\A\w+/
            token=Token.new(:ident,$&,line)
          else
            puts
            raise "unknown lexeme : #{src[0...10]}"
          end
        end
        
        src.delete_prefix!($&)
        if token
          @tokens << token
          #percent=(100*token.line/@nb_lines.to_f).round(1)
          #puts "#{percent.to_s.rjust(6)} %  line #{token.line.to_s.rjust(8)} : #tokens....#{@tokens.size.to_s.rjust(8,'.')}" if (@tokens.size % 2000 == 0)
        end
      end
    end

    def show_next
      @tokens.first
    end

    def expect kind
      next_tok=show_next
      if next_tok.kind==kind
        return accept_it
      else
        puts "parsing error at #{next_tok.line} : expecting #{kind}. Got #{next_tok.kind} '#{next_tok.val}'"
        raise
      end
    end

    def accept_it
      @tokens.shift
    end

    def up_to kind
      while @tokens.any? and @tokens.first.kind!=kind
        @tokens.shift
      end
    end

    def parse
      @modules={}
      puts "parsing"
      while @tokens.any?
        begin
          up_to :module
          mod_name, mod_h = parse_module 
          unless mod_h[:inputs].include?("VPWR") or mod_h[:inputs].include?("VGND")
            @modules[mod_name] = mod_h 
          end
        rescue Exception => e
        end
      end
      puts "found #{@modules.size} modules"
    end

    def parse_module
      modul={}
      expect :module
      mod_name = expect(:ident).val
      modul[:inputs]=[]
      modul[:outputs]=[]
      while show_next && show_next.kind!=:endmodule
        case show_next.kind
        when :input
          modul[:inputs]  << parse_input
        when :output
          modul[:outputs] << parse_output
        else
          accept_it
        end
      end
      return mod_name, modul
    end

    def parse_input
      expect :input
      name=expect(:ident).val
    end

    def parse_output
      expect :output
      name=expect(:ident).val
    end

    def filtering
      @modules.reject!{|mod_name,_| !mod_name.start_with?("sky130")}
      # @modules.reject!{|_, mod_h| mod_h[:inputs].empty? or mod_h[:outputs].empty?}
      puts "keeping #{@modules.size} modules"
    end

    def dump_as_json
      json_filename=@basename+".json"
      File.open("../#{json_filename}",'w') do |f|
        f.puts JSON.pretty_generate(@modules)
      end
      puts "written pdk as '#{json_filename}'"
    end
  end

end

verilog_filename=ARGV.first
start=Time.now
grepper=Verilog::Grepper.new
grepper.open(verilog_filename)
commande = "wc -l \"#{verilog_filename}\""
nb_lines = `#{commande}`.strip.split.first.to_i
observer = Thread.new do
  # lines_processed = 0
  loop do
    print "\r"
    # lines_processed = grepper.line
    percent=(100.0*grepper.line/nb_lines)
    line_rate=(grepper.line / (Time.now - start))
    visuel="["+"="*(percent/2)+" "*(50-(percent/2))+"]"
    print "#{percent.round(1).to_s.rjust(5)} %  #lines..#{grepper.line.to_s.rjust(6,'.')} #tokens..#{grepper.tokens.size.to_s.rjust(6,'.')} #line/sec..#{line_rate.to_s.rjust(6,'.')} #{visuel}"
    break if grepper.line >= nb_lines
    sleep 2
  end
end
grepper.lex
observer.join
grepper.parse
grepper.filtering
grepper.dump_as_json
ending=Time.now
puts "time to process : #{(ending-start).round(1)} seconds"
