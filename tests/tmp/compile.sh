echo "[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/rand"  at  $(date +%FT%T)
ghdl -a --std=08 --work=rand_lib -P=. rand.vhd
ghdl -a --std=08 --work=rand_lib -P=. rand_altered.vhd
echo " |--[+] compiling rand_Infinity_tb"
ghdl -a --std=08 --work=rand_lib -P=. rand_Infinity_tb.vhd
echo " |--[+] elaborating rand_Infinity_tb"
echo " |--[+] simulating rand_Infinity_tb"
ghdl --elab-run --std=08 --work=rand_lib -P=. rand_Infinity_tb --read-wave-opt=rand_Infinity_tb.opt --vcd=rand_Infinity_tb.vcd 
 
