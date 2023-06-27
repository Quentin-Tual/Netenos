require './lib/vhdl.rb'
require './lib/netlist.rb'

module Netlist

    class VhdlCompiler

        def generate_compile_script circuit, test_frequencies = nil
            code=Code.new
            # code << "echo \"[+] cleaning\""
            # code << "rm -rf *.o #{circuit.name}_tb.ghw #{circuit.name}_tb"
            # if !File.exists? "gtech_lib-obj93.cf"
            # * Compilation de la GTECH
                code << "echo \"[+] compiling gtech\""
                ent_name_list = "("
                $GTECH.each do |klass|
                    entity=klass.to_s.downcase.split('::').last.concat("_d")
                    code << "echo \" |--[+] compiling #{entity}.vhd\""
                    ent_name_list.concat "#{entity} "    
                    code << "ghdl -a --work=gtech_lib #{entity}.vhd"
                end
            # end
            # * Initial circuit compilation
            code << "echo \"[+] compiling #{circuit.name}.vhd\""
            code << "ghdl -a #{circuit.name}.vhd"

            # * Testbench compilation at each frequency
            test_frequencies.each do |freq|
                code << "echo \"[+] compiling #{circuit.name}_#{freq.to_s.split('.').join}_tb.vhd\""
                code << "ghdl -a #{circuit.name}_#{freq.to_s.split('.').join}_tb.vhd"
            end
            
            # * Elaboration & Simulation
            sim_name_list = "("
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