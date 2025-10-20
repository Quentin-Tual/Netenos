class Code

  attr_accessor :indent,:lines

  def initialize str=nil, indent_sym: "\t"
    @lines=[]
    (@lines << str) if str
    @indent=0
    @indent_sym=indent_sym
  end

  def <<(thing)
    if (code=thing).is_a? Code
      code.lines.each do |line|
        @lines << @indent_sym*@indent+line.to_s
      end
    elsif thing.is_a? Array
      thing.each do |kode|
        @lines << kode
      end
    elsif thing.nil?
    else
      @lines << @indent_sym*@indent+thing.to_s
    end
  end

  def finalize
    return @lines.join("\n") if @lines.any?
    ""
  end

  def to_s
    finalize
  end

  def newline
    @lines << " "
  end

  def save_as filename,append=false,verbose=false,sep="\n"
    str=self.finalize
    if File.exist?(filename) and append
      File.open(filename, 'a'){|f| f.puts(str)}
    else
      File.open(filename,'w'){|f| f.puts(str)}
    # puts "=> code saved as : #{filename}" if verbose
    end
    
    return filename
  end

  def size
    @lines.size
  end

end
