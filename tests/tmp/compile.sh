ghdl -a --std=08 --work=circ_C17_lib -P=. circ_C17.vhd
ghdl -a --std=08 --work=circ_C17_lib -P=. circ_C17_1_tb.vhd
ghdl --elab-run --std=08 --work=circ_C17_lib -P=. circ_C17_1_tb --read-wave-opt=circ_C17_1_tb.opt --vcd=circ_C17_1_tb.vcd
 
