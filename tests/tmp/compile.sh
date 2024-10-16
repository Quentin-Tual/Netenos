ghdl -a --std=08 --work=rand_140_lib -P=. rand_140.vhd
ghdl -a --std=08 --work=rand_140_lib -P=. rand_140_1_tb.vhd
ghdl --elab-run --std=08 --work=rand_140_lib -P=. rand_140_1_tb --read-wave-opt=rand_140_1_tb.opt --vcd=rand_140_1_tb.vcd
 
