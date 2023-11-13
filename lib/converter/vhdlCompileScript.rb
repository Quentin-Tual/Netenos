# require_relative '../vhdl.rb'
require_relative '../netlist.rb'

module Converter

    class VhdlCompiler

        def gtech_makefile path, compiler
            # * Compilation de la GTECH
            code=Code.new

            code << "compile_gtech:"
            code.indent=1
            code << "echo \"[+] compiling gtech\""
            # ent_name_list = "("
            $GTECH.each do |klass|
                entity=klass.to_s.downcase.split('::').last.concat("_d")
                code << "echo \" |--[+] compiling #{entity}.vhd\""
                # ent_name_list.concat "#{entity} "    
                case compiler
                when :nvc
                    code << "nvc --work=gtech_lib -a #{entity}.vhd"
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
                code << "compile_circ#{i}:"
                code.indent=1
                code << "cd circ#{i} && ./compile.sh"
                code.indent=0
                code.newline
            end

            code << "clean:"
            code.indent=1
            batch_size.times do |i|
                code << "rm circ#{i}/*.o"
                code << "rm circ#{i}/*.cf"
                code << "rm circ#{i}/*.vcd"
                code << "rm circ#{i}/*.vhd" # might be removed
                code << "find circ0 -name 'circ#{i}_*_tb' -delete"
            end
            code.indent=0
            code.newline

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

            # code << "gen_env:"
            # code.indent=1
            # code << "ruby gen_env.rb"
            # code.indent=0
            # code.newline

            code << "compile_gtech:"
            code.indent=1
            code << "$(MAKE) -C gtech"
            code.indent=0
            code.newline

            nb_batch.times do |i|
                code << "compile_batch#{i}:"
                code.indent=1
                code << "$(MAKE) -C batch#{i}"# -j#{batch_size}"
                code.indent=0
                code.newline
            end

            code << "clean:"
            code.indent=1
            nb_batch.times do |i|
                code << "$(MAKE) -C batch#{i} clean"
            end
            code.indent=0
            code.newline

            code.save_as("#{path}/makefile")
        end

        def circ_compile_script path, circ_init_name, freq_list, compiler=:ghdl, append = false
            code = Code.new
            case compiler
            when :nvc

                code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                code << "nvc --work=#{circ_init_name}_lib -L ../../gtech/ -a #{circ_init_name}.vhd"
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end 
                freq_list.each do |freq|
                    code << "echo \" |-- [+] compiling #{circ_init_name}_#{freq}_tb\""
                    code << "nvc --work=#{circ_init_name}_lib -L ../../gtech/ -M 1g -a #{circ_init_name}_#{freq}_tb.vhd "
                    code << "echo \" |-- [+] elaborating #{circ_init_name}_#{freq}_tb\""
                    code << "nvc --work=#{circ_init_name}_lib -L ../../gtech/ -M 1g -e #{circ_init_name}_#{freq}_tb"
                    code << "echo \" |-- [+] simulating #{circ_init_name}_#{freq}_tb\""
                    code << "nvc --work=#{circ_init_name}_lib -L ../../gtech/ -r #{circ_init_name}_#{freq}_tb --format=vcd -w #{circ_init_name}_#{freq}_tb.vcd"
                    code.newline
                end
            when :ghdl2
                code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=../../gtech/ #{circ_init_name}.vhd"
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end
                freq_list.each do |freq|
                    code << "echo \" |-- [+] compiling #{circ_init_name}_#{freq}_tb\""
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=../../gtech/ #{circ_init_name}_#{freq}_tb.vhd"
                    code << "echo \" |-- [+] elaborating #{circ_init_name}_#{freq}_tb\""
                    code << "echo \" |-- [+] simulating #{circ_init_name}_#{freq}_tb\""
                    code << "ghdl --elab-run --std=08 --work=#{circ_init_name}_lib -P=../../gtech/ #{circ_init_name}_#{freq}_tb --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    # code << "echo \" |-- [+] simulating #{circ_init_name}_#{freq}_tb\""
                    # code << "ghdl -r #{circ_init_name}_#{freq}_tb --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    code.newline
                end
            else # :ghdl3 as default option
                code << "echo \"[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/#{circ_init_name}\"  at  $(date +%FT%T)"
                code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=../../gtech/ #{circ_init_name}.vhd"
                freq_list = freq_list.collect do |freq|
                    freq.to_s.split('.').join
                end
                freq_list.each do |freq|
                    code << "echo \" |-- [+] compiling #{circ_init_name}_#{freq}_tb\""
                    code << "ghdl -a --std=08 --work=#{circ_init_name}_lib -P=../../gtech/ #{circ_init_name}_#{freq}_tb.vhd"
                    code << "echo \" |-- [+] elaborating #{circ_init_name}_#{freq}_tb\""
                    code << "ghdl -e --std=08 --work=#{circ_init_name}_lib -P=../../gtech/ #{circ_init_name}_#{freq}_tb"
                    code << "echo \" |-- [+] simulating #{circ_init_name}_#{freq}_tb\""
                    code << "ghdl -r #{circ_init_name}_#{freq}_tb --vcd=#{circ_init_name}_#{freq}_tb.vcd"
                    code.newline
                end
            end
            
            code.save_as("#{path}/compile.sh",append)
            system("chmod +x #{path}/compile.sh")
        end

        def generate_compile_script circuit, test_frequencies = nil
            code=Code.new
            # code << "echo \"[+] cleaning\""
            # code << "rm -rf *.o #{circuit.name}_tb.ghw #{circuit.name}_tb"
            # * Compilation de la GTECH
            code << "echo \"[+] compiling gtech\""
            # ent_name_list = "("
            $GTECH.each do |klass|
                entity=klass.to_s.downcase.split('::').last.concat("_d")
                code << "echo \" |--[+] compiling #{entity}.vhd\""
                # ent_name_list.concat "#{entity} "    
                code << "ghdl -a --work=gtech_lib #{entity}.vhd"
            end
            # * Initial circuit compilation
            code << "echo \"[+] compiling #{circuit.name}.vhd\""
            code << "ghdl -a #{circuit.name}.vhd"

            # * Testbench compilation at each frequency
            test_frequencies.each do |freq|
                code << "echo \"[+] compiling #{circuit.name}_#{freq.to_s.split('.').join}_tb.vhd\""
                code << "ghdl -a #{circuit.name}_#{freq.to_s.split('.').join}_tb.vhd"
            end
            
            # * Elaboration & Simulation
            test_frequencies.each do |freq|
                code << "echo \"[+] elaboration #{circuit.name}_#{freq.to_s.split('.').join}_tb\""
                code << "ghdl -e #{circuit.name}_#{freq.to_s.split('.').join}_tb"

                code << "echo \"[+] running simulation\""
                code << "./#{circuit.name}_#{freq.to_s.split('.').join}_tb --vcd=#{circuit.name}_#{freq.to_s.split('.').join}_tb.vcd"
                # code << "echo \"[+] launching viewer on #{circuit.name}_tb.vcd\""
                # code << "gtkwave #{circuit.name}_tb.vcd #{circuit.name}_tb.sav"
            end

            code << "echo \"[+] cleaning temporary files\""
            code << "rm #{circuit.name}_*_tb"  
            code << "rm #{circuit.name}.o"
            test_frequencies.each do |freq|
                code << "rm e~#{circuit.name}_#{freq.to_s.split('.').join}_tb.o #{circuit.name}_#{freq.to_s.split('.').join}_tb.o"
            end

            code # ?? nécessaire ??

            filename=code.save_as("compile_#{circuit.name}.x")
            system("chmod +x #{filename}")
        end
        
        def run_compile_script circuit
            puts "[+] run script..."
            system("./compile_#{circuit.name}.x")
        end

    end

end