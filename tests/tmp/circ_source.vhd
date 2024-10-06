library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity circ_source is
	port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		o0 : out std_logic;
		o1 : out std_logic;
		o2 : out std_logic;
		o3 : out std_logic;
		o4 : out std_logic;
		o5 : out std_logic;
		o6 : out std_logic;
		o7 : out std_logic;
		o8 : out std_logic;
		o9 : out std_logic;
		o10 : out std_logic;
		o11 : out std_logic;
		o12 : out std_logic;
		o13 : out std_logic
	);
end circ_source;
 
architecture netenos of circ_source is
	signal Not140_o0 : std_logic;
	signal Not160_o0 : std_logic;
	signal Not180_o0 : std_logic;
	signal Not200_o0 : std_logic;
	signal Not220_o0 : std_logic;
	signal And2240_o0 : std_logic;
	signal And2260_o0 : std_logic;
	signal And2280_o0 : std_logic;
	signal And2300_o0 : std_logic;
	signal And2320_o0 : std_logic;
	signal And2340_o0 : std_logic;
	signal And2360_o0 : std_logic;
	signal And2380_o0 : std_logic;
	signal And2400_o0 : std_logic;
	signal And2420_o0 : std_logic;
	signal And2440_o0 : std_logic;
	signal And2460_o0 : std_logic;
	signal And2480_o0 : std_logic;
	signal And2500_o0 : std_logic;
	signal Nand2520_o0 : std_logic;
	signal Nand2540_o0 : std_logic;
	signal Nand2560_o0 : std_logic;
	signal And2580_o0 : std_logic;
	signal Nand2600_o0 : std_logic;
	signal Nand2620_o0 : std_logic;
	signal Nand2640_o0 : std_logic;
	signal And2660_o0 : std_logic;
	signal And2680_o0 : std_logic;
	signal Nand2700_o0 : std_logic;
	signal Nand2720_o0 : std_logic;
	signal And2740_o0 : std_logic;
	signal And2760_o0 : std_logic;
	signal And2780_o0 : std_logic;
	signal Or2800_o0 : std_logic;
	signal Nand2820_o0 : std_logic;
	signal And2840_o0 : std_logic;
	signal And2860_o0 : std_logic;
	signal Nand2880_o0 : std_logic;
	signal Nand2900_o0 : std_logic;
	signal And2920_o0 : std_logic;
	signal Xor2940_o0 : std_logic;
	signal Not960_o0 : std_logic;
	signal Or2980_o0 : std_logic;
	signal Xor21000_o0 : std_logic;
	signal Nand21020_o0 : std_logic;
	signal Or21040_o0 : std_logic;
	signal Nand21060_o0 : std_logic;
	signal Nand21080_o0 : std_logic;
	signal Nand21100_o0 : std_logic;
	signal Nand21120_o0 : std_logic;
	signal Nand21140_o0 : std_logic;
	signal Nand21160_o0 : std_logic;
	signal Nand21180_o0 : std_logic;
	signal Or21200_o0 : std_logic;
	signal And21220_o0 : std_logic;
	signal Nand21240_o0 : std_logic;
	signal Nand21260_o0 : std_logic;
	signal Or21280_o0 : std_logic;
	signal Nand21300_o0 : std_logic;
	signal Nand21320_o0 : std_logic;
	signal And21340_o0 : std_logic;
	signal And21360_o0 : std_logic;
	signal Nand21380_o0 : std_logic;
	signal Nand21400_o0 : std_logic;
	signal Nand21420_o0 : std_logic;
	signal And21440_o0 : std_logic;
	signal Nand21460_o0 : std_logic;
	signal Nand21480_o0 : std_logic;
	signal Nand21500_o0 : std_logic;
	signal Nand21520_o0 : std_logic;
	signal Xor21540_o0 : std_logic;
	signal Nand21560_o0 : std_logic;
	signal Nand21580_o0 : std_logic;
	signal Nand21600_o0 : std_logic;
	signal Nand21620_o0 : std_logic;
	signal And21640_o0 : std_logic;
	signal Nand21660_o0 : std_logic;
	signal Nand21680_o0 : std_logic;
	signal And21700_o0 : std_logic;
	signal Nand21720_o0 : std_logic;
	signal Nand21740_o0 : std_logic;
	signal Nand21760_o0 : std_logic;
	signal Nand21780_o0 : std_logic;
	signal Nand21800_o0 : std_logic;
	signal Nand21820_o0 : std_logic;
	signal And21840_o0 : std_logic;
	signal Xor21860_o0 : std_logic;
	signal And21880_o0 : std_logic;
	signal And21900_o0 : std_logic;
	signal And21920_o0 : std_logic;
	signal Or21940_o0 : std_logic;
	signal Nand21960_o0 : std_logic;
	signal Nand21980_o0 : std_logic;
	signal Nand22000_o0 : std_logic;
	signal Nand22020_o0 : std_logic;
	signal And22040_o0 : std_logic;
	signal And22060_o0 : std_logic;
	signal And22080_o0 : std_logic;
	signal Nand22100_o0 : std_logic;
	signal And22120_o0 : std_logic;
	signal Nand22140_o0 : std_logic;
	signal Nand22160_o0 : std_logic;
	signal Nand22180_o0 : std_logic;
	signal Xor22200_o0 : std_logic;
	signal Nand22220_o0 : std_logic;
	signal Nand22240_o0 : std_logic;
	signal Nand22260_o0 : std_logic;
	signal And22280_o0 : std_logic;
	signal Nand22300_o0 : std_logic;
	signal Nand22320_o0 : std_logic;
	signal Nand22340_o0 : std_logic;
	signal Nand22360_o0 : std_logic;
	signal Nand22380_o0 : std_logic;
	signal Nand22400_o0 : std_logic;
	signal Nand22420_o0 : std_logic;
	signal Nand22440_o0 : std_logic;
	signal Nand22460_o0 : std_logic;
	signal And22480_o0 : std_logic;
	signal Nand22500_o0 : std_logic;
	signal Nand22520_o0 : std_logic;
	signal Nand22540_o0 : std_logic;
	signal Xor22560_o0 : std_logic;
	signal And22580_o0 : std_logic;
	signal Or22600_o0 : std_logic;
	signal And22620_o0 : std_logic;
	signal Nand22640_o0 : std_logic;
	signal Nand22660_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Not140 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			o0 => Not140_o0
		);
		Not160 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			o0 => Not160_o0
		);
		Not180 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			o0 => Not180_o0
		);
		Not200 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			o0 => Not200_o0
		);
		Not220 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			o0 => Not220_o0
		);
		And2240 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Not160_o0,
			o0 => And2240_o0
		);
		And2260 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And2240_o0,
			o0 => And2260_o0
		);
		And2280 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => And2260_o0,
			o0 => And2280_o0
		);
		And2300 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => And2280_o0,
			o0 => And2300_o0
		);
		And2320 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => i1,
			o0 => And2320_o0
		);
		And2340 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And2320_o0,
			o0 => And2340_o0
		);
		And2360 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => And2340_o0,
			o0 => And2360_o0
		);
		And2380 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => And2360_o0,
			o0 => And2380_o0
		);
		And2400 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => And2360_o0,
			o0 => And2400_o0
		);
		And2420 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Not160_o0,
			o0 => And2420_o0
		);
		And2440 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => And2420_o0,
			o0 => And2440_o0
		);
		And2460 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => And2440_o0,
			o0 => And2460_o0
		);
		And2480 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => And2460_o0,
			o0 => And2480_o0
		);
		And2500 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Not180_o0,
			o0 => And2500_o0
		);
		Nand2520 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And2500_o0,
			o0 => Nand2520_o0
		);
		Nand2540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand2520_o0,
			o0 => Nand2540_o0
		);
		Nand2560 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand2540_o0,
			o0 => Nand2560_o0
		);
		And2580 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Not220_o0,
			o0 => And2580_o0
		);
		Nand2600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2320_o0,
			i1 => And2580_o0,
			o0 => Nand2600_o0
		);
		Nand2620 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2560_o0,
			i1 => Nand2600_o0,
			o0 => Nand2620_o0
		);
		Nand2640 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nand2620_o0,
			o0 => Nand2640_o0
		);
		And2660 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Not220_o0,
			o0 => And2660_o0
		);
		And2680 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And2660_o0,
			o0 => And2680_o0
		);
		Nand2700 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2420_o0,
			i1 => And2680_o0,
			o0 => Nand2700_o0
		);
		Nand2720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2640_o0,
			i1 => Nand2700_o0,
			o0 => Nand2720_o0
		);
		And2740 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => And2740_o0
		);
		And2760 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Not180_o0,
			o0 => And2760_o0
		);
		And2780 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2660_o0,
			i1 => And2760_o0,
			o0 => And2780_o0
		);
		Or2800 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => And2740_o0,
			i1 => And2780_o0,
			o0 => Or2800_o0
		);
		Nand2820 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Or2800_o0,
			o0 => Nand2820_o0
		);
		And2840 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Not220_o0,
			o0 => And2840_o0
		);
		And2860 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And2840_o0,
			o0 => And2860_o0
		);
		Nand2880 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2320_o0,
			i1 => And2860_o0,
			o0 => Nand2880_o0
		);
		Nand2900 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2820_o0,
			i1 => Nand2880_o0,
			o0 => Nand2900_o0
		);
		And2920 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Not220_o0,
			o0 => And2920_o0
		);
		Xor2940 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Not220_o0,
			o0 => Xor2940_o0
		);
		Not960 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Xor2940_o0,
			o0 => Not960_o0
		);
		Or2980 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Not200_o0,
			o0 => Or2980_o0
		);
		Xor21000 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Not200_o0,
			o0 => Xor21000_o0
		);
		Nand21020 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not960_o0,
			i1 => Xor21000_o0,
			o0 => Nand21020_o0
		);
		Or21040 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Not180_o0,
			o0 => Or21040_o0
		);
		Nand21060 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Or21040_o0,
			o0 => Nand21060_o0
		);
		Nand21080 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand21060_o0,
			o0 => Nand21080_o0
		);
		Nand21100 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => And2580_o0,
			o0 => Nand21100_o0
		);
		Nand21120 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21080_o0,
			i1 => Nand21100_o0,
			o0 => Nand21120_o0
		);
		Nand21140 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Nand21120_o0,
			o0 => Nand21140_o0
		);
		Nand21160 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21020_o0,
			i1 => Nand21140_o0,
			o0 => Nand21160_o0
		);
		Nand21180 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Nand21160_o0,
			o0 => Nand21180_o0
		);
		Or21200 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => And2680_o0,
			o0 => Or21200_o0
		);
		And21220 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Or21200_o0,
			o0 => And21220_o0
		);
		Nand21240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => And21220_o0,
			o0 => Nand21240_o0
		);
		Nand21260 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21180_o0,
			i1 => Nand21240_o0,
			o0 => Nand21260_o0
		);
		Or21280 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Not180_o0,
			o0 => Or21280_o0
		);
		Nand21300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Or21280_o0,
			o0 => Nand21300_o0
		);
		Nand21320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Nand21300_o0,
			o0 => Nand21320_o0
		);
		And21340 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2520_o0,
			i1 => Nand21320_o0,
			o0 => And21340_o0
		);
		And21360 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Not220_o0,
			o0 => And21360_o0
		);
		Nand21380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2320_o0,
			i1 => And21360_o0,
			o0 => Nand21380_o0
		);
		Nand21400 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And21340_o0,
			i1 => Nand21380_o0,
			o0 => Nand21400_o0
		);
		Nand21420 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Nand21400_o0,
			o0 => Nand21420_o0
		);
		And21440 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand21300_o0,
			o0 => And21440_o0
		);
		Nand21460 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => And21440_o0,
			o0 => Nand21460_o0
		);
		Nand21480 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2600_o0,
			i1 => Nand21460_o0,
			o0 => Nand21480_o0
		);
		Nand21500 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nand21480_o0,
			o0 => Nand21500_o0
		);
		Nand21520 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21420_o0,
			i1 => Nand21500_o0,
			o0 => Nand21520_o0
		);
		Xor21540 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Not160_o0,
			o0 => Xor21540_o0
		);
		Nand21560 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Xor21540_o0,
			o0 => Nand21560_o0
		);
		Nand21580 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And2740_o0,
			o0 => Nand21580_o0
		);
		Nand21600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21560_o0,
			i1 => Nand21580_o0,
			o0 => Nand21600_o0
		);
		Nand21620 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Nand21600_o0,
			o0 => Nand21620_o0
		);
		And21640 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Not960_o0,
			o0 => And21640_o0
		);
		Nand21660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And21640_o0,
			o0 => Nand21660_o0
		);
		Nand21680 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21620_o0,
			i1 => Nand21660_o0,
			o0 => Nand21680_o0
		);
		And21700 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => i4,
			o0 => And21700_o0
		);
		Nand21720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => And21700_o0,
			o0 => Nand21720_o0
		);
		Nand21740 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => And2840_o0,
			o0 => Nand21740_o0
		);
		Nand21760 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21720_o0,
			i1 => Nand21740_o0,
			o0 => Nand21760_o0
		);
		Nand21780 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Nand21760_o0,
			o0 => Nand21780_o0
		);
		Nand21800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2420_o0,
			i1 => And2840_o0,
			o0 => Nand21800_o0
		);
		Nand21820 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21780_o0,
			i1 => Nand21800_o0,
			o0 => Nand21820_o0
		);
		And21840 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Nand21820_o0,
			o0 => And21840_o0
		);
		Xor21860 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Xor21860_o0
		);
		And21880 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Xor21860_o0,
			o0 => And21880_o0
		);
		And21900 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => And21880_o0,
			o0 => And21900_o0
		);
		And21920 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And21900_o0,
			o0 => And21920_o0
		);
		Or21940 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Not220_o0,
			o0 => Or21940_o0
		);
		Nand21960 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Or21940_o0,
			o0 => Nand21960_o0
		);
		Nand21980 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Nand21960_o0,
			o0 => Nand21980_o0
		);
		Nand22000 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And2920_o0,
			o0 => Nand22000_o0
		);
		Nand22020 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21980_o0,
			i1 => Nand22000_o0,
			o0 => Nand22020_o0
		);
		And22040 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Nand22020_o0,
			o0 => And22040_o0
		);
		And22060 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And22040_o0,
			o0 => And22060_o0
		);
		And22080 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i2,
			o0 => And22080_o0
		);
		Nand22100 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And22080_o0,
			o0 => Nand22100_o0
		);
		And22120 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Not180_o0,
			o0 => And22120_o0
		);
		Nand22140 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => And22120_o0,
			o0 => Nand22140_o0
		);
		Nand22160 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22100_o0,
			i1 => Nand22140_o0,
			o0 => Nand22160_o0
		);
		Nand22180 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor21860_o0,
			i1 => Nand22160_o0,
			o0 => Nand22180_o0
		);
		Xor22200 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Not220_o0,
			o0 => Xor22200_o0
		);
		Nand22220 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Xor22200_o0,
			o0 => Nand22220_o0
		);
		Nand22240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2940_o0,
			i1 => Nand22220_o0,
			o0 => Nand22240_o0
		);
		Nand22260 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Nand22240_o0,
			o0 => Nand22260_o0
		);
		And22280 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i4,
			o0 => And22280_o0
		);
		Nand22300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2420_o0,
			i1 => And22280_o0,
			o0 => Nand22300_o0
		);
		Nand22320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22260_o0,
			i1 => Nand22300_o0,
			o0 => Nand22320_o0
		);
		Nand22340 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Nand22320_o0,
			o0 => Nand22340_o0
		);
		Nand22360 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22180_o0,
			i1 => Nand22340_o0,
			o0 => Nand22360_o0
		);
		Nand22380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And21700_o0,
			o0 => Nand22380_o0
		);
		Nand22400 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => And2840_o0,
			o0 => Nand22400_o0
		);
		Nand22420 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22380_o0,
			i1 => Nand22400_o0,
			o0 => Nand22420_o0
		);
		Nand22440 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Nand22420_o0,
			o0 => Nand22440_o0
		);
		Nand22460 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Or2980_o0,
			o0 => Nand22460_o0
		);
		And22480 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Nand22460_o0,
			o0 => And22480_o0
		);
		Nand22500 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And22480_o0,
			o0 => Nand22500_o0
		);
		Nand22520 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22440_o0,
			i1 => Nand22500_o0,
			o0 => Nand22520_o0
		);
		Nand22540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Nand22520_o0,
			o0 => Nand22540_o0
		);
		Xor22560 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => i4,
			o0 => Xor22560_o0
		);
		And22580 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Xor22560_o0,
			o0 => And22580_o0
		);
		Or22600 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => And2680_o0,
			i1 => And22580_o0,
			o0 => Or22600_o0
		);
		And22620 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Or22600_o0,
			o0 => And22620_o0
		);
		Nand22640 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And22620_o0,
			o0 => Nand22640_o0
		);
		Nand22660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22540_o0,
			i1 => Nand22640_o0,
			o0 => Nand22660_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= And2300_o0;
	o1 <= And2380_o0;
	o2 <= And2400_o0;
	o3 <= And2480_o0;
	o4 <= Nand2720_o0;
	o5 <= Nand2900_o0;
	o6 <= Nand21260_o0;
	o7 <= Nand21520_o0;
	o8 <= Nand21680_o0;
	o9 <= And21840_o0;
	o10 <= And21920_o0;
	o11 <= And22060_o0;
	o12 <= Nand22360_o0;
	o13 <= Nand22660_o0;
end netenos;
