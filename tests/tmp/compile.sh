echo "[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/rand"  at  $(date +%FT%T)
ghdl -a --std=08 --work=rand_lib -P=. rand.vhd
ghdl -a --std=08 --work=rand_lib -P=. rand_altered.vhd
echo " |--[+] compiling rand_10_tb"
ghdl -a --std=08 --work=rand_lib -P=. rand_10_tb.vhd
echo " |--[+] elaborating rand_10_tb"
echo " |--[+] simulating rand_10_tb"
ghdl --elab-run --std=08 --work=rand_lib -P=. rand_10_tb --vcd=rand_10_tb.vcd
 
