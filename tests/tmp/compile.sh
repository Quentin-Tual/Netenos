ghdl -a --std=08 --work=circ_source_lib -P=. circ_source.vhd
ghdl -a --std=08 --work=circ_source_lib -P=. circ_source_altered.vhd
ghdl -a --std=08 --work=circ_source_lib -P=. circ_source_11_tb.vhd
ghdl --elab-run --std=08 --work=circ_source_lib -P=. circ_source_11_tb --vcd=circ_source_11_tb.vcd
 
