echo "[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/circ_source"  at  $(date +%FT%T)
ghdl -a --std=08 --work=circ_source_lib -P=. circ_source.vhd
echo " |--[+] compiling circ_source_1_tb"
ghdl -a --std=08 --work=circ_source_lib -P=. circ_source_1_tb.vhd
echo " |--[+] elaborating circ_source_1_tb"
echo " |--[+] simulating circ_source_1_tb"
ghdl --elab-run --std=08 --work=circ_source_lib -P=. circ_source_1_tb  --vcd=circ_source_1_tb.vcd # --read-wave-opt=circ_source_1_tb.opt
 
