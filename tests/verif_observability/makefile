compile_gtech:
	echo "[+] compiling gtech"
	echo " |--[+] compiling and2_d.vhd"
	ghdl -a --std=08 --work=gtech_lib and2_d.vhd
	echo " |--[+] compiling or2_d.vhd"
	ghdl -a --std=08 --work=gtech_lib or2_d.vhd
	echo " |--[+] compiling xor2_d.vhd"
	ghdl -a --std=08 --work=gtech_lib xor2_d.vhd
	echo " |--[+] compiling not_d.vhd"
	ghdl -a --std=08 --work=gtech_lib not_d.vhd
	echo " |--[+] compiling nand2_d.vhd"
	ghdl -a --std=08 --work=gtech_lib nand2_d.vhd
	echo " |--[+] compiling nor2_d.vhd"
	ghdl -a --std=08 --work=gtech_lib nor2_d.vhd
	echo " |--[+] compiling buffer_d.vhd"
	ghdl -a --std=08 --work=gtech_lib buffer_d.vhd
 
clean:
	rm ./*.o
	rm ./*.cf
