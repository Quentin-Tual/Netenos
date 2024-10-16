ghdl -a --std=08 --work=circ_source_lib -P=. circ_source.vhd
ghdl -a --std=08 --work=circ_source_lib -P=. circ_source_1_tb.vhd
ghdl --elab-run --std=08 --work=circ_source_lib -P=. circ_source_1_tb --read-wave-opt=circ_source_1_tb.opt --vcd=circ_source_1_tb.vcd
 
