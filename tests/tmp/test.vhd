library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity test is
	port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		i5 : in  std_logic;
		i6 : in  std_logic;
		i7 : in  std_logic;
		o0 : out std_logic;
		o1 : out std_logic;
		o2 : out std_logic;
		o3 : out std_logic
	);
end test;
 
architecture netenos of test is
	signal Not60_o0 : std_logic;
	signal Or280_o0 : std_logic;
	signal Nor2100_o0 : std_logic;
	signal Nand2120_o0 : std_logic;
	signal And2140_o0 : std_logic;
	signal Not160_o0 : std_logic;
	signal Nand2180_o0 : std_logic;
	signal Not200_o0 : std_logic;
	signal Or2220_o0 : std_logic;
	signal Or2240_o0 : std_logic;
	signal And2260_o0 : std_logic;
	signal Nand2280_o0 : std_logic;
	signal Nand2300_o0 : std_logic;
	signal Nand2320_o0 : std_logic;
	signal Nand2340_o0 : std_logic;
	signal Nand2360_o0 : std_logic;
	signal Nor2380_o0 : std_logic;
	signal Or2400_o0 : std_logic;
	signal Nand2420_o0 : std_logic;
	signal And2440_o0 : std_logic;
	signal Nor2460_o0 : std_logic;
	signal Nor2480_o0 : std_logic;
	signal Xor2500_o0 : std_logic;
	signal And2520_o0 : std_logic;
	signal Nand2540_o0 : std_logic;
	signal Nand2560_o0 : std_logic;
	signal Not580_o0 : std_logic;
	signal Xor2600_o0 : std_logic;
	signal Xor2620_o0 : std_logic;
	signal And2640_o0 : std_logic;
	signal And2660_o0 : std_logic;
	signal Not680_o0 : std_logic;
	signal Or2700_o0 : std_logic;
	signal And2720_o0 : std_logic;
	signal Nor2740_o0 : std_logic;
	signal Not760_o0 : std_logic;
	signal And2780_o0 : std_logic;
	signal Or2800_o0 : std_logic;
	signal Or2820_o0 : std_logic;
	signal Xor2840_o0 : std_logic;
	signal And2860_o0 : std_logic;
	signal Or2880_o0 : std_logic;
	signal Nand2900_o0 : std_logic;
	signal Nand2920_o0 : std_logic;
	signal Nand2940_o0 : std_logic;
	signal Nor2960_o0 : std_logic;
	signal Not980_o0 : std_logic;
	signal Xor21000_o0 : std_logic;
	signal Not1020_o0 : std_logic;
	signal Nor21040_o0 : std_logic;
	signal Xor21060_o0 : std_logic;
	signal Or21080_o0 : std_logic;
	signal Nor21100_o0 : std_logic;
	signal Nand21120_o0 : std_logic;
	signal Nand21140_o0 : std_logic;
	signal Nand21160_o0 : std_logic;
	signal Nor21180_o0 : std_logic;
	signal Or21200_o0 : std_logic;
	signal Xor21220_o0 : std_logic;
	signal Not1240_o0 : std_logic;
	signal Nand21260_o0 : std_logic;
	signal Xor21280_o0 : std_logic;
	signal Or21300_o0 : std_logic;
	signal Xor21320_o0 : std_logic;
	signal And21340_o0 : std_logic;
	signal And21360_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Not60 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			o0 => Not60_o0
		);
		Or280 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => i3,
			o0 => Or280_o0
		);
		Nor2100 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i7,
			i1 => i4,
			o0 => Nor2100_o0
		);
		Nand2120 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i0,
			o0 => Nand2120_o0
		);
		And2140 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i6,
			o0 => And2140_o0
		);
		Not160 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2140_o0,
			o0 => Not160_o0
		);
		Nand2180 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2100_o0,
			i1 => Or280_o0,
			o0 => Nand2180_o0
		);
		Not200 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not60_o0,
			o0 => Not200_o0
		);
		Or2220 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2120_o0,
			i1 => Nor2100_o0,
			o0 => Or2220_o0
		);
		Or2240 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Or280_o0,
			o0 => Or2240_o0
		);
		And2260 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Or2240_o0,
			o0 => And2260_o0
		);
		Nand2280 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or2220_o0,
			i1 => Nand2180_o0,
			o0 => Nand2280_o0
		);
		Nand2300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Not60_o0,
			o0 => Nand2300_o0
		);
		Nand2320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i3,
			o0 => Nand2320_o0
		);
		Nand2340 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => And2140_o0,
			o0 => Nand2340_o0
		);
		Nand2360 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2320_o0,
			i1 => Nand2340_o0,
			o0 => Nand2360_o0
		);
		Nor2380 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => And2260_o0,
			i1 => Nand2300_o0,
			o0 => Nor2380_o0
		);
		Or2400 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2280_o0,
			i1 => Not200_o0,
			o0 => Or2400_o0
		);
		Nand2420 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i7,
			i1 => Nand2180_o0,
			o0 => Nand2420_o0
		);
		And2440 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2120_o0,
			i1 => Or2220_o0,
			o0 => And2440_o0
		);
		Nor2460 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2360_o0,
			i1 => Nand2420_o0,
			o0 => Nor2460_o0
		);
		Nor2480 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => And2440_o0,
			i1 => Or2400_o0,
			o0 => Nor2480_o0
		);
		Xor2500 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2380_o0,
			i1 => Not160_o0,
			o0 => Xor2500_o0
		);
		And2520 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Or2240_o0,
			o0 => And2520_o0
		);
		Nand2540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => Nand2340_o0,
			o0 => Nand2540_o0
		);
		Nand2560 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2540_o0,
			i1 => Nor2480_o0,
			o0 => Nand2560_o0
		);
		Not580 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2520_o0,
			o0 => Not580_o0
		);
		Xor2600 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2500_o0,
			i1 => Nor2460_o0,
			o0 => Xor2600_o0
		);
		Xor2620 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nor2460_o0,
			o0 => Xor2620_o0
		);
		And2640 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => Nand2120_o0,
			o0 => And2640_o0
		);
		And2660 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2600_o0,
			i1 => And2640_o0,
			o0 => And2660_o0
		);
		Not680 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not580_o0,
			o0 => Not680_o0
		);
		Or2700 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2620_o0,
			i1 => Nand2560_o0,
			o0 => Or2700_o0
		);
		And2720 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2140_o0,
			i1 => i4,
			o0 => And2720_o0
		);
		Nor2740 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not680_o0,
			i1 => And2720_o0,
			o0 => Nor2740_o0
		);
		Not760 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or2700_o0,
			o0 => Not760_o0
		);
		And2780 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2660_o0,
			i1 => Or280_o0,
			o0 => And2780_o0
		);
		Or2800 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2480_o0,
			i1 => Nor2100_o0,
			o0 => Or2800_o0
		);
		Or2820 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Or2800_o0,
			i1 => Not760_o0,
			o0 => Or2820_o0
		);
		Xor2840 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And2780_o0,
			i1 => Nor2740_o0,
			o0 => Xor2840_o0
		);
		And2860 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2400_o0,
			i1 => And2440_o0,
			o0 => And2860_o0
		);
		Or2880 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2420_o0,
			i1 => Nand2320_o0,
			o0 => Or2880_o0
		);
		Nand2900 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2860_o0,
			i1 => Xor2840_o0,
			o0 => Nand2900_o0
		);
		Nand2920 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or2820_o0,
			i1 => Or2880_o0,
			o0 => Nand2920_o0
		);
		Nand2940 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or2700_o0,
			i1 => And2780_o0,
			o0 => Nand2940_o0
		);
		Nor2960 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not60_o0,
			i1 => Or2820_o0,
			o0 => Nor2960_o0
		);
		Not980 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor2960_o0,
			o0 => Not980_o0
		);
		Xor21000 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2940_o0,
			i1 => Nand2900_o0,
			o0 => Xor21000_o0
		);
		Not1020 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand2920_o0,
			o0 => Not1020_o0
		);
		Nor21040 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2560_o0,
			i1 => Not680_o0,
			o0 => Nor21040_o0
		);
		Xor21060 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not980_o0,
			i1 => Nor21040_o0,
			o0 => Xor21060_o0
		);
		Or21080 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not1020_o0,
			i1 => Xor21000_o0,
			o0 => Or21080_o0
		);
		Nor21100 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Nand2920_o0,
			o0 => Nor21100_o0
		);
		Nand21120 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not980_o0,
			i1 => Not1020_o0,
			o0 => Nand21120_o0
		);
		Nand21140 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor21100_o0,
			i1 => Xor21060_o0,
			o0 => Nand21140_o0
		);
		Nand21160 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or21080_o0,
			i1 => Nand21120_o0,
			o0 => Nand21160_o0
		);
		Nor21180 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2840_o0,
			i1 => And2720_o0,
			o0 => Nor21180_o0
		);
		Or21200 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2940_o0,
			i1 => Not160_o0,
			o0 => Or21200_o0
		);
		Xor21220 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nor21180_o0,
			i1 => Nand21140_o0,
			o0 => Xor21220_o0
		);
		Not1240 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or21200_o0,
			o0 => Not1240_o0
		);
		Nand21260 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21160_o0,
			i1 => Xor2500_o0,
			o0 => Nand21260_o0
		);
		Xor21280 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And2660_o0,
			i1 => Nand2180_o0,
			o0 => Xor21280_o0
		);
		Or21300 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor21280_o0,
			i1 => Nand21260_o0,
			o0 => Or21300_o0
		);
		Xor21320 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor21220_o0,
			i1 => Not1240_o0,
			o0 => Xor21320_o0
		);
		And21340 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2360_o0,
			i1 => Nor2380_o0,
			o0 => And21340_o0
		);
		And21360 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2360_o0,
			i1 => Nor2380_o0,
			o0 => And21360_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= And21340_o0;
	o1 <= Xor21320_o0;
	o2 <= Or21300_o0;
	o3 <= And21360_o0;
end netenos;
