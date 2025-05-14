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
	signal Nor260_o0 : std_logic;
	signal Xor280_o0 : std_logic;
	signal Nand2100_o0 : std_logic;
	signal Xor2120_o0 : std_logic;
	signal Nor2140_o0 : std_logic;
	signal Not160_o0 : std_logic;
	signal Xor2180_o0 : std_logic;
	signal Nor2200_o0 : std_logic;
	signal Not220_o0 : std_logic;
	signal Nand2240_o0 : std_logic;
	signal Nand2260_o0 : std_logic;
	signal Nand2280_o0 : std_logic;
	signal Nor2300_o0 : std_logic;
	signal Xor2320_o0 : std_logic;
	signal Or2340_o0 : std_logic;
	signal Or2360_o0 : std_logic;
	signal Xor2380_o0 : std_logic;
	signal Xor2400_o0 : std_logic;
	signal And2420_o0 : std_logic;
	signal Nor2440_o0 : std_logic;
	signal Or2460_o0 : std_logic;
	signal Not480_o0 : std_logic;
	signal And2500_o0 : std_logic;
	signal Xor2520_o0 : std_logic;
	signal Or2540_o0 : std_logic;
	signal Xor2560_o0 : std_logic;
	signal Or2580_o0 : std_logic;
	signal Or2600_o0 : std_logic;
	signal Nand2620_o0 : std_logic;
	signal Nor2640_o0 : std_logic;
	signal Nor2660_o0 : std_logic;
	signal Nor2680_o0 : std_logic;
	signal And2700_o0 : std_logic;
	signal Xor2720_o0 : std_logic;
	signal Nand2740_o0 : std_logic;
	signal And2760_o0 : std_logic;
	signal Nand2780_o0 : std_logic;
	signal Not800_o0 : std_logic;
	signal And2820_o0 : std_logic;
	signal Not840_o0 : std_logic;
	signal Nand2860_o0 : std_logic;
	signal And2880_o0 : std_logic;
	signal Xor2900_o0 : std_logic;
	signal Not920_o0 : std_logic;
	signal Or2940_o0 : std_logic;
	signal And2960_o0 : std_logic;
	signal Xor2980_o0 : std_logic;
	signal Or21000_o0 : std_logic;
	signal Nor21020_o0 : std_logic;
	signal And21040_o0 : std_logic;
	signal Or21060_o0 : std_logic;
	signal Xor21080_o0 : std_logic;
	signal Or21100_o0 : std_logic;
	signal Nand21120_o0 : std_logic;
	signal Or21140_o0 : std_logic;
	signal Or21160_o0 : std_logic;
	signal Nand21180_o0 : std_logic;
	signal And21200_o0 : std_logic;
	signal Xor21220_o0 : std_logic;
	signal Or21240_o0 : std_logic;
	signal Nand21260_o0 : std_logic;
	signal Not1280_o0 : std_logic;
	signal And21300_o0 : std_logic;
	signal Nand21320_o0 : std_logic;
	signal Nand21340_o0 : std_logic;
	signal Xor21360_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Nor260 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => i4,
			i1 => i7,
			o0 => Nor260_o0
		);
		Xor280 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => i3,
			i1 => i6,
			o0 => Xor280_o0
		);
		Nand2100 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => i0,
			i1 => i5,
			o0 => Nand2100_o0
		);
		Xor2120 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => i1,
			i1 => i2,
			o0 => Xor2120_o0
		);
		Nor2140 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => i3,
			i1 => i7,
			o0 => Nor2140_o0
		);
		Not160 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Nor260_o0,
			o0 => Not160_o0
		);
		Xor2180 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Xor280_o0,
			i1 => Nand2100_o0,
			o0 => Xor2180_o0
		);
		Nor2200 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Nor2140_o0,
			i1 => Xor2120_o0,
			o0 => Nor2200_o0
		);
		Not220 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Nand2100_o0,
			o0 => Not220_o0
		);
		Nand2240 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => i5,
			i1 => i2,
			o0 => Nand2240_o0
		);
		Nand2260 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nor2200_o0,
			i1 => Not160_o0,
			o0 => Nand2260_o0
		);
		Nand2280 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Xor2180_o0,
			o0 => Nand2280_o0
		);
		Nor2300 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Nand2240_o0,
			i1 => i4,
			o0 => Nor2300_o0
		);
		Xor2320 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Nor2200_o0,
			i1 => i1,
			o0 => Xor2320_o0
		);
		Or2340 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => i0,
			i1 => Not160_o0,
			o0 => Or2340_o0
		);
		Or2360 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Nand2280_o0,
			i1 => Nor2300_o0,
			o0 => Or2360_o0
		);
		Xor2380 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Xor2320_o0,
			i1 => Or2340_o0,
			o0 => Xor2380_o0
		);
		Xor2400 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Nand2260_o0,
			i1 => Xor2320_o0,
			o0 => Xor2400_o0
		);
		And2420 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => i6,
			i1 => Nor2140_o0,
			o0 => And2420_o0
		);
		Nor2440 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Nor2300_o0,
			i1 => Nand2260_o0,
			o0 => Nor2440_o0
		);
		Or2460 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Xor2380_o0,
			i1 => Nor2440_o0,
			o0 => Or2460_o0
		);
		Not480 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Xor2400_o0,
			o0 => Not480_o0
		);
		And2500 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => And2420_o0,
			i1 => Or2360_o0,
			o0 => And2500_o0
		);
		Xor2520 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Xor2180_o0,
			i1 => Not220_o0,
			o0 => Xor2520_o0
		);
		Or2540 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => i3,
			i1 => Xor2120_o0,
			o0 => Or2540_o0
		);
		Xor2560 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => And2500_o0,
			i1 => Xor2520_o0,
			o0 => Xor2560_o0
		);
		Or2580 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Or2460_o0,
			i1 => Not480_o0,
			o0 => Or2580_o0
		);
		Or2600 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Or2540_o0,
			i1 => Or2540_o0,
			o0 => Or2600_o0
		);
		Nand2620 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nor260_o0,
			i1 => And2500_o0,
			o0 => Nand2620_o0
		);
		Nor2640 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Or2360_o0,
			i1 => Nand2240_o0,
			o0 => Nor2640_o0
		);
		Nor2660 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Nand2620_o0,
			i1 => Xor2560_o0,
			o0 => Nor2660_o0
		);
		Nor2680 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Or2580_o0,
			i1 => Or2600_o0,
			o0 => Nor2680_o0
		);
		And2700 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nor2640_o0,
			i1 => Xor2560_o0,
			o0 => And2700_o0
		);
		Xor2720 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Nand2620_o0,
			i1 => Nor2640_o0,
			o0 => Xor2720_o0
		);
		Nand2740 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nor2680_o0,
			i1 => Xor2720_o0,
			o0 => Nand2740_o0
		);
		And2760 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nor2660_o0,
			i1 => And2700_o0,
			o0 => And2760_o0
		);
		Nand2780 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Or2340_o0,
			i1 => Nand2280_o0,
			o0 => Nand2780_o0
		);
		Not800 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Or2600_o0,
			o0 => Not800_o0
		);
		And2820 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nand2780_o0,
			i1 => Nand2740_o0,
			o0 => And2820_o0
		);
		Not840 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => And2760_o0,
			o0 => Not840_o0
		);
		Nand2860 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Not800_o0,
			i1 => Not800_o0,
			o0 => Nand2860_o0
		);
		And2880 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Xor280_o0,
			i1 => Nor2140_o0,
			o0 => And2880_o0
		);
		Xor2900 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => And2880_o0,
			i1 => And2820_o0,
			o0 => Xor2900_o0
		);
		Not920 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Nand2860_o0,
			o0 => Not920_o0
		);
		Or2940 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Not840_o0,
			i1 => Nand2740_o0,
			o0 => Or2940_o0
		);
		And2960 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Xor2120_o0,
			i1 => Nand2100_o0,
			o0 => And2960_o0
		);
		Xor2980 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Not920_o0,
			i1 => Or2940_o0,
			o0 => Xor2980_o0
		);
		Or21000 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Xor2900_o0,
			i1 => And2960_o0,
			o0 => Or21000_o0
		);
		Nor21020 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Xor2320_o0,
			o0 => Nor21020_o0
		);
		And21040 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => i2,
			i1 => Nor2200_o0,
			o0 => And21040_o0
		);
		Or21060 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => And21040_o0,
			i1 => Xor2980_o0,
			o0 => Or21060_o0
		);
		Xor21080 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Nor21020_o0,
			i1 => Or21000_o0,
			o0 => Xor21080_o0
		);
		Or21100 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Not480_o0,
			i1 => And21040_o0,
			o0 => Or21100_o0
		);
		Nand21120 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nand2780_o0,
			i1 => Not920_o0,
			o0 => Nand21120_o0
		);
		Or21140 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Nand21120_o0,
			i1 => Or21100_o0,
			o0 => Or21140_o0
		);
		Or21160 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Xor21080_o0,
			i1 => Or21060_o0,
			o0 => Or21160_o0
		);
		Nand21180 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Or2460_o0,
			i1 => Xor2980_o0,
			o0 => Nand21180_o0
		);
		And21200 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nor2660_o0,
			i1 => Nor21020_o0,
			o0 => And21200_o0
		);
		Xor21220 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => And21200_o0,
			i1 => Nand21180_o0,
			o0 => Xor21220_o0
		);
		Or21240 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Or21160_o0,
			i1 => Or21140_o0,
			o0 => Or21240_o0
		);
		Nand21260 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Or2940_o0,
			i1 => i6,
			o0 => Nand21260_o0
		);
		Not1280 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Xor2900_o0,
			o0 => Not1280_o0
		);
		And21300 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nand21260_o0,
			i1 => Not1280_o0,
			o0 => And21300_o0
		);
		Nand21320 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Xor21220_o0,
			i1 => Or21240_o0,
			o0 => Nand21320_o0
		);
		Nand21340 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Not840_o0,
			i1 => And2960_o0,
			o0 => Nand21340_o0
		);
		Xor21360 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => And2760_o0,
			i1 => And2880_o0,
			o0 => Xor21360_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Xor21360_o0;
	o1 <= Nand21340_o0;
	o2 <= Nand21320_o0;
	o3 <= And21300_o0;
end netenos;
