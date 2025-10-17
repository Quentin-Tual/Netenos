# require_relative '../vhdl.rb'
require_relative '../netlist'

module Converter

    class VhdlCompiler

        def gtech_makefile path, compiler
            # * Compilation de la GTECH
            code=Code.new

            code << "compile_gtech:"
            code.indent=1
            if $VERBOSE
                code << "echo \"[+] compiling gtech\""
            end
            gtech = Netlist::get_gtech
            gtech.each do |klass|
                entity=klass.to_s.downcase.split('::').last.concat("_d")
                if $VERBOSE
                    code << "echo \" |--[+] compiling #{entity}.vhd\""
                end
                case compiler
                when :nvc
                    code << "nvc --work=gtech_lib --std=08 -a #{entity}.vhd "
                else
                    code << "ghdl -a --std=08 --work=gtech_lib #{entity}.vhd"
                end
            end
            code.indent=0
            code.newline
            code << "clean:"
	        code.indent=1
            code << "rm #{path}/*.o"
	        code << "rm #{path}/*.cf"

            code.save_as("#{path}/makefile")
        end

        def batch_makefile path, batch_size
            code = Code.new

            all_statement = "all: "
            batch_size.times do |i|
                all_statement.concat("compile_circ#{i} ")
            end
            code << all_statement
            code.newline

            batch_size.times do |i|
                code << "clean#{i}:"
                code.indent=1
                code << "rm circ#{i}/*.o"
                code << "rm circ#{i}/*.cf"
                code << "find circ#{i} -type f -not -iname \"*.*\" -delete"

                code.indent=0
                code.newline

                code << "compile_circ#{i}:"
                code.indent=1
                code << "cd circ#{i} && ./compile.sh"

                code.indent=0
                code.newline

                code.indent=0
                code.newline

            end

            code.save_as("#{path}/makefile")
        end

        def experience_makefile path, nb_batch, batch_size
            code = Code.new
            all_statement = "all: compile_gtech "
            nb_batch.times do |i|
                all_statement.concat "compile_batch#{i} "
            end
            code << all_statement
            code.newline

            code << "compile_gtech:"
            code.indent=1
            code << "$(MAKE) -C gtech"
            code.indent=0
            code.newline

            nb_batch.times do |i|
                code << "compile_batch#{i}:"
                code.indent=1
                code << "$(MAKE) -C batch#{i} all -j#{batch_size}"
                code.indent=0
                code.newline
            

                code << "clean#{i}:"
                code.indent=1
                code << "$(MAKE) -C batch#{i} clean#{i}"
                code.indent=0
                code.newline
            end
            
            code.save_as("#{path}/makefile")
        end

        def comp_tb_compile_script path, circ_init_name, circ_alt_name, freq_list, compiler=[:ghdl, :minimal_sig], append = false, gtech_path: "../../gtech", vcd: true
            code = Code.new
            if compiler.is_a? Array
               opt =  compiler[1]
               compiler = compiler[0]
            else
                opt = :minimal_sig
            end 
            case compiler
            when :nvc
                if $VERBOSE
                    code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                end
                code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} --std=08 -a #{circ_init_name}.vhd"
                code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} --std=08 -a #{circ_alt_name}.vhd"
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end 
                freq_list.each do |freq|
                    if $VERBOSE
                        code << "echo \" |--[+] compiling #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "nvc --work=#{circ_init_name}_lib -L #{gtech_path} -M 6g --std=08 -a #{circ_init_name}_#{freq}_tb.vhd"
                    if $VERBOSE
                        code << "echo \" |--[+] elaborating #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} -M 6g --std=08 -e #{circ_init_name}_#{freq}_tb"
                    if $VERBOSE
                        code << "echo \" |--[+] simulating #{circ_init_name}_#{freq}_tb\""
                    end
                    if opt == :minimal_sig
                        generate_include_file "#{circ_init_name}_#{freq}_tb", path, ["*"]
                        generate_exclude_file "#{circ_init_name}_#{freq}_tb", path, ["*:*"]
                    elsif opt == :uut_sig
                        generate_include_file "#{circ_init_name}_#{freq}_tb", path, ["*"]
                        generate_exclude_file "#{circ_init_name}_#{freq}_tb", path, ["uut:*:*", "ref_unit:*:*"]
                    end
                    code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} -M 6g --std=08 -r #{circ_init_name}_#{freq}_tb --format=vcd -w"
                    code.newline
                    # code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} --std=08 -r #{circ_init_name}_#{freq}_tb --format=vcd -w"
                    # code.newline
                end
            when :ghdl2
                if $VERBOSE
                    code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                end
                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}.vhd"
                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_alt_name}.vhd"
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end
                freq_list.each do |freq|
                    if $VERBOSE
                        code << "echo \" |--[+] compiling #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb.vhd"
                    if $VERBOSE 
                        code << "echo \" |--[+] elaborating #{circ_init_name}_#{freq}_tb\""
                        code << "echo \" |--[+] simulating #{circ_init_name}_#{freq}_tb\""
                    end
                    if opt == :minimal_sig
                        code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb --read-wave-opt=#{circ_init_name}_#{freq}_tb.opt --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path
                    elsif opt == :uut_sig
                        code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb --read-wave-opt=#{circ_init_name}_#{freq}_tb.opt --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path, "uut/*"
                    else
                        code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    end

                    code.newline
                    
                end
                
            else # :ghdl3 as default option
                if $VERBOSE
                    code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                end
                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}.vhd"
                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_alt_name}.vhd"                
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end
                freq_list.each do |freq|
                    if $VERBOSE
                        code << "echo \" |--[+] compiling #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb.vhd"
                    if $VERBOSE
                        code << "echo \" |--[+] elaborating #{circ_init_name}_#{freq}_tb\""
                    end
                    # code << "ghdl -e --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb"
                    if $VERBOSE
                        code << "echo \" |--[+] simulating #{circ_init_name}_#{freq}_tb\""
                    end 
                    # code << "ghdl -r #{circ_init_name}_#{freq}_tb --read-wave-opt=#{circ_init_name}_#{freq}_tb.opt --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    
                    opt_args = ""

                    if opt == :minimal_sig
                        opt_args += "--read-wave-opt=#{circ_init_name}_#{freq}_tb.opt "
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path
                    elsif opt == :uut_sig
                        opt_args += "--read-wave-opt=#{circ_init_name}_#{freq}_tb.opt "
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path, ["uut/*"]
                    end

                    if vcd
                        opt_args += "--vcd=#{circ_init_name}_#{freq}_tb.vcd "
                    end

                    code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb #{opt_args}"

                    code.newline
                end 
            end
            
            code.save_as("#{path}/compile.sh",append)
            system("chmod +x #{path}/compile.sh")
        end

        def circ_compile_script path, circ_init_name, freq_list, compiler=[:ghdl, :minimal_sig], append = false, gtech_path: "../../gtech", vcd: true
            code = Code.new
            if compiler.is_a? Array
               opt =  compiler[1]
               compiler = compiler[0]
            else
                opt = :minimal_sig
            end 
            case compiler
            when :nvc
                if $VERBOSE
                    code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                end
                code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} --std=08 -a #{circ_init_name}.vhd "
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end 
                freq_list.each do |freq|
                    if $VERBOSE
                        code << "echo \" |--[+] compiling #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} -M 6g --std=08 -a #{circ_init_name}_#{freq}_tb.vhd"
                    if $VERBOSE
                        code << "echo \" |--[+] elaborating #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} -M 6g --std=08 -e #{circ_init_name}_#{freq}_tb -"
                    if $VERBOSE
                        code << "echo \" |--[+] simulating #{circ_init_name}_#{freq}_tb\""
                    end
                    if opt == :minimal_sig
                        generate_include_file "#{circ_init_name}_#{freq}_tb", path, ["*"]
                        generate_exclude_file "#{circ_init_name}_#{freq}_tb", path, ["*:*"]
                    elsif opt == :uut_sig
                        generate_include_file "#{circ_init_name}_#{freq}_tb", path, ["*"]
                        generate_exclude_file "#{circ_init_name}_#{freq}_tb", path, ["uut:*:*", "ref_unit:*:*"]
                    end
                    code << "nvc  --work=#{circ_init_name}_lib -L #{gtech_path} -std=08 -r #{circ_init_name}_#{freq}_tb --format=vcd -w"
                    code.newline
                    
                end
            when :ghdl2
                if $VERBOSE
                    code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                end
                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}.vhd"
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end
                freq_list.each do |freq|
                    if $VERBOSE
                        code << "echo \" |--[+] compiling #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb.vhd"
                    if $VERBOSE 
                        code << "echo \" |--[+] elaborating #{circ_init_name}_#{freq}_tb\""
                        code << "echo \" |--[+] simulating #{circ_init_name}_#{freq}_tb\""
                    end
                    if opt == :minimal_sig
                        code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb --read-wave-opt=#{circ_init_name}_#{freq}_tb.opt --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path
                    elsif opt == :uut_sig
                        code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb --read-wave-opt=#{circ_init_name}_#{freq}_tb.opt --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path, "uut/*"
                    else
                        code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    end
                    code.newline 
                end
            else # :ghdl3 as default option
                if $VERBOSE
                    code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                end

                if File.exist?("event_monitor_pkg.vhdl")
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} event_monitor_pkg.vhdl" 
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} event_monitor.vhdl" 
                end

                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}.vhd"
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end
                freq_list.each do |freq|
                    if $VERBOSE
                        code << "echo \" |--[+] compiling #{circ_init_name}_#{freq}_tb\""
                    end
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb.vhd"
                    if $VERBOSE
                        code << "echo \" |--[+] elaborating #{circ_init_name}_#{freq}_tb\""
                    end
                    # code << "ghdl -e --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb"
                    if $VERBOSE
                        code << "echo \" |--[+] simulating #{circ_init_name}_#{freq}_tb\""
                    end 
                    # code << "ghdl -r #{circ_init_name}_#{freq}_tb --read-wave-opt=#{circ_init_name}_#{freq}_tb.opt --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    
                    opt_args = ""

                    if opt == :minimal_sig
                        opt_args += "--read-wave-opt=#{circ_init_name}_#{freq}_tb.opt"
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path
                    elsif opt == :uut_sig
                        opt_args += "--read-wave-opt=#{circ_init_name}_#{freq}_tb.opt"
                        generate_wave_opt_file "#{circ_init_name}_#{freq}_tb", path, ["uut/*"]
                    end

                    if vcd
                        opt_args += " --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    end

                    code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=#{gtech_path} #{circ_init_name}_#{freq}_tb #{opt_args}"

                    code.newline
                end 
            end
            
            code.save_as("#{path}/compile.sh",append)
            system("chmod +x #{path}/compile.sh")
        end

        def generate_include_file testbench_name, path, signals = []
            str = "# include file\n"
            if !signals.empty?
                signals.each do |s|
                    str << ":*:#{s}\n"
                end
            end

            File.open("#{path}/#{testbench_name}.include",'w'){|f| f.puts(str)}
        end

        def generate_exclude_file testbench_name, path, signals = []
            str = "# include file\n"
            if !signals.empty?
                signals.each do |s|
                    str << ":*:#{s}\n"
                end
            end

            File.open("#{path}/#{testbench_name}.exclude",'w'){|f| f.puts(str)}
        end

        def generate_wave_opt_file testbench_name, path, signals = []
            
            str = "$ version 1.1\n# Signals in packages :\n# Signals in entities :\n/#{testbench_name}/*"
            if !signals.empty?
                signals.each do |s|
                    str << "\n/#{testbench_name}/#{s}"
                end
            end

            File.open("#{path}/#{testbench_name}.opt",'w'){|f| f.puts(str)}
        end

        # ! LEGACY
        def generate_compile_script circuit, test_frequencies = nil
            code=Code.new
            
            # * Compilation de la GTECH
            if $VERBOSE
                code << "echo \"[+] compiling gtech\""
            end

            Netlist::Gate.subclasses.each do |klass|
                entity=klass.to_s.downcase.split('::').last.concat("_d")
                if $VERBOSE
                    code << "echo \" |--[+] compiling #{entity}.vhd\""
                end
                code << "ghdl -a --work=gtech_lib #{entity}.vhd"
            end
            # * Initial circuit compilation
            if $VERBOSE
                code << "echo \"[+] compiling #{circuit.name}.vhd\""
            end
            code << "ghdl -a #{circuit.name}.vhd"

            # * Testbench compilation at each frequency
            test_frequencies.each do |freq|
                if $VERBOSE
                    code << "echo \"[+] compiling #{circuit.name}_#{freq.to_s.split('.').join}_tb.vhd\""
                end
                code << "ghdl -a #{circuit.name}_#{freq.to_s.split('.').join}_tb.vhd"
            end
            
            # * Elaboration & Simulation
            test_frequencies.each do |freq|
                if $VERBOSE
                    code << "echo \"[+] elaboration #{circuit.name}_#{freq.to_s.split('.').join}_tb\""
                end
                code << "ghdl -e #{circuit.name}_#{freq.to_s.split('.').join}_tb"

                if $VERBOSE
                    code << "echo \"[+] running simulation\""
                end
                code << "./#{circuit.name}_#{freq.to_s.split('.').join}_tb --vcd=#{circuit.name}_#{freq.to_s.split('.').join}_tb.vcd"
            end

            if $VERBOSE
                code << "echo \"[+] cleaning temporary files\""
            end
            code << "rm #{circuit.name}_*_tb"  
            code << "rm #{circuit.name}.o"
            test_frequencies.each do |freq|
                code << "rm e~#{circuit.name}_#{freq.to_s.split('.').join}_tb.o #{circuit.name}_#{freq.to_s.split('.').join}_tb.o"
            end

            filename=code.save_as("compile_#{circuit.name}.x")
            system("chmod +x #{filename}")
        end
        
        def run_compile_script circuit
            if $VERBOSE
                puts "[+] run script..."
            end
            system("./compile_#{circuit.name}.x")
        end

    end

end