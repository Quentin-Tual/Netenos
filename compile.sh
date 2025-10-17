ghdl -a --std=08 --work=test_lib -P=. test.vhd
ghdl -a --std=08 --work=test_lib -P=. test_1_tb.vhd
ghdl --elab-run --std=08 --work=test_lib -P=. test_1_tb --read-wave-opt=test_1_tb.opt
 
