echo "[+] compiling $(basename $(cd .. && pwd))/$(basename $(pwd))/test"  at  $(date +%FT%T)
nvc  --work=test_lib -L ./ --std=08 -a test.vhd
nvc  --work=test_lib -L ./ --std=08 -a alt.vhd
echo " |--[+] compiling test_1_tb"
nvc --work=test_lib -L ./ -M 6g --std=08 -a test_1_tb.vhd
echo " |--[+] elaborating test_1_tb"
nvc  --work=test_lib -L ./ -M 6g --std=08 -e test_1_tb
echo " |--[+] simulating test_1_tb"
nvc  --work=test_lib -L ./  --std=08 -r test_1_tb --format=vcd -w
 
nvc  --work=test_lib -L ./ --std=08 -r test_1_tb --format=vcd -w
 
