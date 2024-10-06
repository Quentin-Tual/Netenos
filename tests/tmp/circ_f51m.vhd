library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity circ_f51m is
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
		o3 : out std_logic;
		o4 : out std_logic;
		o5 : out std_logic;
		o6 : out std_logic;
		o7 : out std_logic
	);
end circ_f51m;
 
architecture netenos of circ_f51m is
	signal Not140_o0 : std_logic;
	signal Not160_o0 : std_logic;
	signal Not180_o0 : std_logic;
	signal Not200_o0 : std_logic;
	signal Not220_o0 : std_logic;
	signal Not240_o0 : std_logic;
	signal Not260_o0 : std_logic;
	signal Not280_o0 : std_logic;
	signal Or2300_o0 : std_logic;
	signal Nand2320_o0 : std_logic;
	signal And2340_o0 : std_logic;
	signal Nand2360_o0 : std_logic;
	signal And2380_o0 : std_logic;
	signal Nand2400_o0 : std_logic;
	signal Nand2420_o0 : std_logic;
	signal And2440_o0 : std_logic;
	signal Nand2460_o0 : std_logic;
	signal And2480_o0 : std_logic;
	signal Not500_o0 : std_logic;
	signal Or2520_o0 : std_logic;
	signal Nand2540_o0 : std_logic;
	signal Nand2560_o0 : std_logic;
	signal And2580_o0 : std_logic;
	signal Nand2600_o0 : std_logic;
	signal Nand2620_o0 : std_logic;
	signal Nand2640_o0 : std_logic;
	signal And2660_o0 : std_logic;
	signal Not680_o0 : std_logic;
	signal Or2700_o0 : std_logic;
	signal Nand2720_o0 : std_logic;
	signal Nand2740_o0 : std_logic;
	signal Or2760_o0 : std_logic;
	signal Nand2780_o0 : std_logic;
	signal Nand2800_o0 : std_logic;
	signal Or2820_o0 : std_logic;
	signal Nand2840_o0 : std_logic;
	signal Nand2860_o0 : std_logic;
	signal Nand2880_o0 : std_logic;
	signal Nand2900_o0 : std_logic;
	signal Or2920_o0 : std_logic;
	signal Nand2940_o0 : std_logic;
	signal Or2960_o0 : std_logic;
	signal Nand2980_o0 : std_logic;
	signal Nand21000_o0 : std_logic;
	signal Nand21020_o0 : std_logic;
	signal Or21040_o0 : std_logic;
	signal Nand21060_o0 : std_logic;
	signal Or21080_o0 : std_logic;
	signal Nand21100_o0 : std_logic;
	signal Nand21120_o0 : std_logic;
	signal Or21140_o0 : std_logic;
	signal And21160_o0 : std_logic;
	signal Not1180_o0 : std_logic;
	signal Or21200_o0 : std_logic;
	signal And21220_o0 : std_logic;
	signal Nand21240_o0 : std_logic;
	signal Nand21260_o0 : std_logic;
	signal Nand21280_o0 : std_logic;
	signal Nand21300_o0 : std_logic;
	signal And21320_o0 : std_logic;
	signal Nand21340_o0 : std_logic;
	signal Or21360_o0 : std_logic;
	signal Nand21380_o0 : std_logic;
	signal Nand21400_o0 : std_logic;
	signal Or21420_o0 : std_logic;
	signal Nand21440_o0 : std_logic;
	signal Nand21460_o0 : std_logic;
	signal Or21480_o0 : std_logic;
	signal Nand21500_o0 : std_logic;
	signal Nand21520_o0 : std_logic;
	signal Or21540_o0 : std_logic;
	signal Or21560_o0 : std_logic;
	signal And21580_o0 : std_logic;
	signal Nand21600_o0 : std_logic;
	signal Nand21620_o0 : std_logic;
	signal Nand21640_o0 : std_logic;
	signal Nand21660_o0 : std_logic;
	signal Nand21680_o0 : std_logic;
	signal Nand21700_o0 : std_logic;
	signal Nand21720_o0 : std_logic;
	signal Nand21740_o0 : std_logic;
	signal Nand21760_o0 : std_logic;
	signal And21780_o0 : std_logic;
	signal Nand21800_o0 : std_logic;
	signal Nand21820_o0 : std_logic;
	signal Nand21840_o0 : std_logic;
	signal Nand21860_o0 : std_logic;
	signal Nand21880_o0 : std_logic;
	signal And21900_o0 : std_logic;
	signal And21920_o0 : std_logic;
	signal And21940_o0 : std_logic;
	signal Nand21960_o0 : std_logic;
	signal And21980_o0 : std_logic;
	signal Nand22000_o0 : std_logic;
	signal Or22020_o0 : std_logic;
	signal And22040_o0 : std_logic;
	signal Nand22060_o0 : std_logic;
	signal Nand22080_o0 : std_logic;
	signal And22100_o0 : std_logic;
	signal Nand22120_o0 : std_logic;
	signal Or22140_o0 : std_logic;
	signal And22160_o0 : std_logic;
	signal Not2180_o0 : std_logic;
	signal Or22200_o0 : std_logic;
	signal Nand22220_o0 : std_logic;
	signal Nand22240_o0 : std_logic;
	signal And22260_o0 : std_logic;
	signal Nand22280_o0 : std_logic;
	signal Nand22300_o0 : std_logic;
	signal Nand22320_o0 : std_logic;
	signal And22340_o0 : std_logic;
	signal Nand22360_o0 : std_logic;
	signal And22380_o0 : std_logic;
	signal Nand22400_o0 : std_logic;
	signal Nand22420_o0 : std_logic;
	signal Nand22440_o0 : std_logic;
	signal Or22460_o0 : std_logic;
	signal Or22480_o0 : std_logic;
	signal And22500_o0 : std_logic;
	signal Nand22520_o0 : std_logic;
	signal Nand22540_o0 : std_logic;
	signal Nand22560_o0 : std_logic;
	signal And22580_o0 : std_logic;
	signal And22600_o0 : std_logic;
	signal Nand22620_o0 : std_logic;
	signal Or22640_o0 : std_logic;
	signal Nand22660_o0 : std_logic;
	signal Nand22680_o0 : std_logic;
	signal And22700_o0 : std_logic;
	signal Or22720_o0 : std_logic;
	signal And22740_o0 : std_logic;
	signal Nand22760_o0 : std_logic;
	signal Nand22780_o0 : std_logic;
	signal Nand22800_o0 : std_logic;
	signal Nand22820_o0 : std_logic;
	signal Nand22840_o0 : std_logic;
	signal Nand22860_o0 : std_logic;
	signal Nand22880_o0 : std_logic;
	signal Nand22900_o0 : std_logic;
	signal Or22920_o0 : std_logic;
	signal Or22940_o0 : std_logic;
	signal Nand22960_o0 : std_logic;
	signal Nand22980_o0 : std_logic;
	signal Or23000_o0 : std_logic;
	signal Nand23020_o0 : std_logic;
	signal Nand23040_o0 : std_logic;
	signal Nand23060_o0 : std_logic;
	signal Xor23080_o0 : std_logic;
	signal Xor23100_o0 : std_logic;
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
		Not240 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			o0 => Not240_o0
		);
		Not260 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			o0 => Not260_o0
		);
		Not280 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i7,
			o0 => Not280_o0
		);
		Or2300 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Not240_o0,
			o0 => Or2300_o0
		);
		Nand2320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Or2300_o0,
			o0 => Nand2320_o0
		);
		And2340 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => i4,
			o0 => And2340_o0
		);
		Nand2360 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And2340_o0,
			o0 => Nand2360_o0
		);
		And2380 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i7,
			o0 => And2380_o0
		);
		Nand2400 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => And2380_o0,
			o0 => Nand2400_o0
		);
		Nand2420 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2360_o0,
			i1 => Nand2400_o0,
			o0 => Nand2420_o0
		);
		And2440 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2320_o0,
			i1 => Nand2420_o0,
			o0 => And2440_o0
		);
		Nand2460 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => And2440_o0,
			o0 => Nand2460_o0
		);
		And2480 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => i7,
			o0 => And2480_o0
		);
		Not500 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2480_o0,
			o0 => Not500_o0
		);
		Or2520 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Not500_o0,
			o0 => Or2520_o0
		);
		Nand2540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Or2520_o0,
			o0 => Nand2540_o0
		);
		Nand2560 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand2540_o0,
			o0 => Nand2560_o0
		);
		And2580 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i5,
			o0 => And2580_o0
		);
		Nand2600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
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
			i0 => Not180_o0,
			i1 => Nand2620_o0,
			o0 => Nand2640_o0
		);
		And2660 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => i7,
			o0 => And2660_o0
		);
		Not680 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2660_o0,
			o0 => Not680_o0
		);
		Or2700 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i5,
			o0 => Or2700_o0
		);
		Nand2720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Or2700_o0,
			o0 => Nand2720_o0
		);
		Nand2740 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not680_o0,
			i1 => Nand2720_o0,
			o0 => Nand2740_o0
		);
		Or2760 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i5,
			o0 => Or2760_o0
		);
		Nand2780 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2740_o0,
			i1 => Or2760_o0,
			o0 => Nand2780_o0
		);
		Nand2800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Nand2780_o0,
			o0 => Nand2800_o0
		);
		Or2820 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i3,
			o0 => Or2820_o0
		);
		Nand2840 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2800_o0,
			i1 => Or2820_o0,
			o0 => Nand2840_o0
		);
		Nand2860 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand2840_o0,
			o0 => Nand2860_o0
		);
		Nand2880 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2640_o0,
			i1 => Nand2860_o0,
			o0 => Nand2880_o0
		);
		Nand2900 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Nand2880_o0,
			o0 => Nand2900_o0
		);
		Or2920 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Or2920_o0
		);
		Nand2940 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Or2920_o0,
			o0 => Nand2940_o0
		);
		Or2960 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i5,
			o0 => Or2960_o0
		);
		Nand2980 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Or2960_o0,
			o0 => Nand2980_o0
		);
		Nand21000 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2940_o0,
			i1 => Nand2980_o0,
			o0 => Nand21000_o0
		);
		Nand21020 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand21000_o0,
			o0 => Nand21020_o0
		);
		Or21040 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Not200_o0,
			o0 => Or21040_o0
		);
		Nand21060 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Or21040_o0,
			o0 => Nand21060_o0
		);
		Or21080 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => i6,
			o0 => Or21080_o0
		);
		Nand21100 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Or21080_o0,
			o0 => Nand21100_o0
		);
		Nand21120 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Nand21100_o0,
			o0 => Nand21120_o0
		);
		Or21140 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => i7,
			o0 => Or21140_o0
		);
		And21160 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => Or21140_o0,
			o0 => And21160_o0
		);
		Not1180 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And21160_o0,
			o0 => Not1180_o0
		);
		Or21200 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => And21160_o0,
			o0 => Or21200_o0
		);
		And21220 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21120_o0,
			i1 => Or21200_o0,
			o0 => And21220_o0
		);
		Nand21240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21060_o0,
			i1 => And21220_o0,
			o0 => Nand21240_o0
		);
		Nand21260 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Nand21240_o0,
			o0 => Nand21260_o0
		);
		Nand21280 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21020_o0,
			i1 => Nand21260_o0,
			o0 => Nand21280_o0
		);
		Nand21300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Nand21280_o0,
			o0 => Nand21300_o0
		);
		And21320 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2900_o0,
			i1 => Nand21300_o0,
			o0 => And21320_o0
		);
		Nand21340 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2460_o0,
			i1 => And21320_o0,
			o0 => Nand21340_o0
		);
		Or21360 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not240_o0,
			i1 => Not680_o0,
			o0 => Or21360_o0
		);
		Nand21380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Or21360_o0,
			o0 => Nand21380_o0
		);
		Nand21400 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand21380_o0,
			o0 => Nand21400_o0
		);
		Or21420 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Not1180_o0,
			o0 => Or21420_o0
		);
		Nand21440 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21400_o0,
			i1 => Or21420_o0,
			o0 => Nand21440_o0
		);
		Nand21460 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Nand21440_o0,
			o0 => Nand21460_o0
		);
		Or21480 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i7,
			o0 => Or21480_o0
		);
		Nand21500 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Or21480_o0,
			o0 => Nand21500_o0
		);
		Nand21520 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not260_o0,
			i1 => Nand21500_o0,
			o0 => Nand21520_o0
		);
		Or21540 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => And2580_o0,
			o0 => Or21540_o0
		);
		Or21560 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i7,
			o0 => Or21560_o0
		);
		And21580 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or21540_o0,
			i1 => Or21560_o0,
			o0 => And21580_o0
		);
		Nand21600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21520_o0,
			i1 => And21580_o0,
			o0 => Nand21600_o0
		);
		Nand21620 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand21600_o0,
			o0 => Nand21620_o0
		);
		Nand21640 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21460_o0,
			i1 => Nand21620_o0,
			o0 => Nand21640_o0
		);
		Nand21660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Nand21640_o0,
			o0 => Nand21660_o0
		);
		Nand21680 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Or2960_o0,
			o0 => Nand21680_o0
		);
		Nand21700 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Or21080_o0,
			o0 => Nand21700_o0
		);
		Nand21720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21680_o0,
			i1 => Nand21700_o0,
			o0 => Nand21720_o0
		);
		Nand21740 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand21720_o0,
			o0 => Nand21740_o0
		);
		Nand21760 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Nand21700_o0,
			o0 => Nand21760_o0
		);
		And21780 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not240_o0,
			i1 => Not680_o0,
			o0 => And21780_o0
		);
		Nand21800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => And21780_o0,
			o0 => Nand21800_o0
		);
		Nand21820 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21760_o0,
			i1 => Nand21800_o0,
			o0 => Nand21820_o0
		);
		Nand21840 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Nand21820_o0,
			o0 => Nand21840_o0
		);
		Nand21860 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21740_o0,
			i1 => Nand21840_o0,
			o0 => Nand21860_o0
		);
		Nand21880 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nand21860_o0,
			o0 => Nand21880_o0
		);
		And21900 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Not220_o0,
			o0 => And21900_o0
		);
		And21920 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => And21900_o0,
			o0 => And21920_o0
		);
		And21940 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not240_o0,
			i1 => And2660_o0,
			o0 => And21940_o0
		);
		Nand21960 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And21920_o0,
			i1 => And21940_o0,
			o0 => Nand21960_o0
		);
		And21980 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21880_o0,
			i1 => Nand21960_o0,
			o0 => And21980_o0
		);
		Nand22000 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21660_o0,
			i1 => And21980_o0,
			o0 => Nand22000_o0
		);
		Or22020 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Not220_o0,
			o0 => Or22020_o0
		);
		And22040 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => i7,
			o0 => And22040_o0
		);
		Nand22060 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And22040_o0,
			o0 => Nand22060_o0
		);
		Nand22080 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or22020_o0,
			i1 => Nand22060_o0,
			o0 => Nand22080_o0
		);
		And22100 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2760_o0,
			i1 => Nand22080_o0,
			o0 => And22100_o0
		);
		Nand22120 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => And22100_o0,
			o0 => Nand22120_o0
		);
		Or22140 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Not220_o0,
			o0 => Or22140_o0
		);
		And22160 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not260_o0,
			i1 => i7,
			o0 => And22160_o0
		);
		Not2180 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And22160_o0,
			o0 => Not2180_o0
		);
		Or22200 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Not2180_o0,
			o0 => Or22200_o0
		);
		Nand22220 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or22140_o0,
			i1 => Or22200_o0,
			o0 => Nand22220_o0
		);
		Nand22240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand22220_o0,
			o0 => Nand22240_o0
		);
		And22260 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Not220_o0,
			o0 => And22260_o0
		);
		Nand22280 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And22260_o0,
			o0 => Nand22280_o0
		);
		Nand22300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22240_o0,
			i1 => Nand22280_o0,
			o0 => Nand22300_o0
		);
		Nand22320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => Nand22300_o0,
			o0 => Nand22320_o0
		);
		And22340 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Not500_o0,
			o0 => And22340_o0
		);
		Nand22360 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => And22340_o0,
			o0 => Nand22360_o0
		);
		And22380 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Not1180_o0,
			o0 => And22380_o0
		);
		Nand22400 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And22380_o0,
			o0 => Nand22400_o0
		);
		Nand22420 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22360_o0,
			i1 => Nand22400_o0,
			o0 => Nand22420_o0
		);
		Nand22440 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Nand22420_o0,
			o0 => Nand22440_o0
		);
		Or22460 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => And2660_o0,
			o0 => Or22460_o0
		);
		Or22480 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Or22460_o0,
			o0 => Or22480_o0
		);
		And22500 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Not260_o0,
			o0 => And22500_o0
		);
		Nand22520 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => And22500_o0,
			o0 => Nand22520_o0
		);
		Nand22540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or22480_o0,
			i1 => Nand22520_o0,
			o0 => Nand22540_o0
		);
		Nand22560 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not240_o0,
			i1 => Nand22540_o0,
			o0 => Nand22560_o0
		);
		And22580 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22440_o0,
			i1 => Nand22560_o0,
			o0 => And22580_o0
		);
		And22600 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22320_o0,
			i1 => And22580_o0,
			o0 => And22600_o0
		);
		Nand22620 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22120_o0,
			i1 => And22600_o0,
			o0 => Nand22620_o0
		);
		Or22640 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not240_o0,
			i1 => Not260_o0,
			o0 => Or22640_o0
		);
		Nand22660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not2180_o0,
			i1 => Or22640_o0,
			o0 => Nand22660_o0
		);
		Nand22680 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand22660_o0,
			o0 => Nand22680_o0
		);
		And22700 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => Or21560_o0,
			o0 => And22700_o0
		);
		Or22720 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => And22700_o0,
			o0 => Or22720_o0
		);
		And22740 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or21360_o0,
			i1 => Or22720_o0,
			o0 => And22740_o0
		);
		Nand22760 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22680_o0,
			i1 => And22740_o0,
			o0 => Nand22760_o0
		);
		Nand22780 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nand22760_o0,
			o0 => Nand22780_o0
		);
		Nand22800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or21140_o0,
			i1 => Or22460_o0,
			o0 => Nand22800_o0
		);
		Nand22820 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => Nand22800_o0,
			o0 => Nand22820_o0
		);
		Nand22840 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not240_o0,
			i1 => And22700_o0,
			o0 => Nand22840_o0
		);
		Nand22860 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22820_o0,
			i1 => Nand22840_o0,
			o0 => Nand22860_o0
		);
		Nand22880 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not200_o0,
			i1 => Nand22860_o0,
			o0 => Nand22880_o0
		);
		Nand22900 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22780_o0,
			i1 => Nand22880_o0,
			o0 => Nand22900_o0
		);
		Or22920 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not240_o0,
			i1 => Not2180_o0,
			o0 => Or22920_o0
		);
		Or22940 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not260_o0,
			i1 => i7,
			o0 => Or22940_o0
		);
		Nand22960 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or22920_o0,
			i1 => Or22940_o0,
			o0 => Nand22960_o0
		);
		Nand22980 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not220_o0,
			i1 => Nand22960_o0,
			o0 => Nand22980_o0
		);
		Or23000 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => And2480_o0,
			o0 => Or23000_o0
		);
		Nand23020 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not680_o0,
			i1 => Or23000_o0,
			o0 => Nand23020_o0
		);
		Nand23040 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand23020_o0,
			o0 => Nand23040_o0
		);
		Nand23060 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22980_o0,
			i1 => Nand23040_o0,
			o0 => Nand23060_o0
		);
		Xor23080 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => And22160_o0,
			o0 => Xor23080_o0
		);
		Xor23100 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not260_o0,
			i1 => o7,
			o0 => Xor23100_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand21340_o0;
	o1 <= Nand22000_o0;
	o2 <= Nand22620_o0;
	o3 <= Nand22900_o0;
	o4 <= Nand23060_o0;
	o5 <= Xor23080_o0;
	o6 <= Xor23100_o0;
	o7 <= Not280_o0;
end netenos;
