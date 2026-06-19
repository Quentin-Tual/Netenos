module Librelane
  class BlifRenamer 
      def initialize 
        @sym_tab = {}
        @new_file = []
        @nb_inputs = 0
        @nb_outputs = 0
        @nb_wires = 0
        @continued_line = nil
      end

      def rename_model line_a
        line_a[-1] = line_a[-1].split('.').first
        line_a
      end

      def rename_inputs line_a
        if @continued_line == :inputs
          last_i = -2
        else 
          last_i = -1
        end
        line_a[1..last_i].each_with_index do |name, i| 
          @sym_tab[name] = line_a[i+1] ="i#{@nb_inputs}"
          @nb_inputs += 1
        end
        line_a
      end

      def rename_continued_inputs line_a
        if @continued_line == :inputs
          last_i = -2
        else 
          last_i = -1
        end
        line_a[0..last_i].each_with_index do |name, i| 
          @sym_tab[name] = line_a[i] = "i#{@nb_inputs}"
          @nb_inputs += 1
        end
        line_a
      end

      def rename_outputs line_a
        if @continued_line == :outputs
          last_o = -2
        else 
          last_o = -1
        end
        line_a[1..last_o].each_with_index do |name, i| 
          @sym_tab[name] = line_a[i+1] = "o#{@nb_outputs}"
          @nb_outputs += 1
        end
        line_a
      end

      def rename_continued_outputs line_a
        if @continued_line == :outputs
          last_o = -2
        else 
          last_o = -1
        end
        line_a[0..last_o].each_with_index do |name, i| 
          @sym_tab[name] = line_a[i] = "o#{@nb_outputs}"
          @nb_outputs += 1
        end
        line_a
      end

      def rename_names line_a
        if @continued_line == :names
          last_n = -2
        else
          last_n = -1
        end
        line_a[1..last_n].each_with_index do |name,i|
          if @sym_tab[name]
            line_a[i+1] = @sym_tab[name]
          else
            line_a[i+1] = @sym_tab[name] = "w#{@nb_wires}"
            @nb_wires += 1
          end
        end
        line_a
      end

      def rename_continued_names line_a
        if @continued_line == :names
          last_n = -2
        else
          last_n = -1
        end
        line_a[0..last_n].each_with_index do |name,i|
          if @sym_tab[name]
            line_a[i] = @sym_tab[name]
          else
            line_a[i] = @sym_tab[name] = "w#{@nb_wires}"
            @nb_wires += 1
          end
        end
        line_a
      end

      def rename path
        puts " > Renaming BLIF file elements"
        circ_name = File.basename(path).split('.').first

        File.foreach(path) do |line|
          line_a = line.split(' ')

          case line_a.first
          when ".model"
            #if line_a.last.include?('.')
            #  line_a = rename_model(line_a)
            #end
            if line_a.last != circ_name
              line_a[-1] = circ_name
            end
          when ".inputs"
            # Lancer rename_inputs, récupérer la ligne modifiée et si le dernier élément est un '\', stocker `:inputs` dans @continued_line
            @continued_line = :inputs if line_a.last == '\\'
            line_a = rename_inputs(line_a)
          when ".outputs"
            # Lancer rename_outputs, récupérer la ligne modifiée et si le dernier élément est un '\', stocker `:outputs` dans @continued_line
            @continued_line = :outputs if line_a.last == '\\'
            line_a = rename_outputs(line_a)
          when ".names"
            # Lancer rename_wiring, récupérer la ligne modifiée et si le dernier élément est un '\', stocker `:names` dans @continued_line
            @continued_line = :names if line_a.last == '\\'
            line_a = rename_names(line_a)
          when ".end"
            
          else # truth table / behavioral description
            case @continued_line
            when :inputs 
              @continued_line = nil unless line_a.last == '\\'
              line_a = rename_continued_inputs(line_a)
            when :outputs
              @continued_line = nil unless line_a.last == '\\'
              line_a = rename_continued_outputs(line_a)
            when :names
              @continued_line = nil unless line_a.last == '\\'
              line_a = rename_continued_names(line_a)
            else
              
            end 
          end

          @new_file << line_a.join(' ')
        end

        # Renommer `path` en `path + ".old"`
        # Stocker `@new_file` dans le fichier `path`
        `mv #{path} #{path}.old`
        File.write(path, @new_file.join("\n"))
      end

  end  
end
