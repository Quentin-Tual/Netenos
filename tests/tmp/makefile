compile_gtech:
	echo "[+] compiling gtech"
	echo " |--[+] compiling and2_d.vhd"
	nvc --work=gtech_lib --std=08 -a and2_d.vhd 
	echo " |--[+] compiling or2_d.vhd"
	nvc --work=gtech_lib --std=08 -a or2_d.vhd 
	echo " |--[+] compiling xor2_d.vhd"
	nvc --work=gtech_lib --std=08 -a xor2_d.vhd 
	echo " |--[+] compiling not_d.vhd"
	nvc --work=gtech_lib --std=08 -a not_d.vhd 
	echo " |--[+] compiling nand2_d.vhd"
	nvc --work=gtech_lib --std=08 -a nand2_d.vhd 
	echo " |--[+] compiling nor2_d.vhd"
	nvc --work=gtech_lib --std=08 -a nor2_d.vhd 
	echo " |--[+] compiling buffer_d.vhd"
	nvc --work=gtech_lib --std=08 -a buffer_d.vhd 
 
clean:
	rm ./*.o
	rm ./*.cf
