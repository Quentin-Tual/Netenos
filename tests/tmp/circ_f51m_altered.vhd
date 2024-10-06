library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity circ_f51m_altered is
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
end circ_f51m_altered;
 
architecture netenos of circ_f51m_altered is
	signal Not60_o0 : std_logic;
	signal Not80_o0 : std_logic;
	signal Not100_o0 : std_logic;
	signal Not120_o0 : std_logic;
	signal Not140_o0 : std_logic;
	signal Not160_o0 : std_logic;
	signal Not180_o0 : std_logic;
	signal Not200_o0 : std_logic;
	signal Or2220_o0 : std_logic;
	signal Nand2240_o0 : std_logic;
	signal And2260_o0 : std_logic;
	signal Nand2280_o0 : std_logic;
	signal And2300_o0 : std_logic;
	signal Nand2320_o0 : std_logic;
	signal Nand2340_o0 : std_logic;
	signal And2360_o0 : std_logic;
	signal Nand2380_o0 : std_logic;
	signal And2400_o0 : std_logic;
	signal Not420_o0 : std_logic;
	signal Or2440_o0 : std_logic;
	signal Nand2460_o0 : std_logic;
	signal Nand2480_o0 : std_logic;
	signal And2500_o0 : std_logic;
	signal Nand2520_o0 : std_logic;
	signal Nand2540_o0 : std_logic;
	signal Nand2560_o0 : std_logic;
	signal And2580_o0 : std_logic;
	signal Not600_o0 : std_logic;
	signal Or2620_o0 : std_logic;
	signal Nand2640_o0 : std_logic;
	signal Nand2660_o0 : std_logic;
	signal Or2680_o0 : std_logic;
	signal Nand2700_o0 : std_logic;
	signal Nand2720_o0 : std_logic;
	signal Or2740_o0 : std_logic;
	signal Nand2760_o0 : std_logic;
	signal Nand2780_o0 : std_logic;
	signal Nand2800_o0 : std_logic;
	signal Nand2820_o0 : std_logic;
	signal Or2840_o0 : std_logic;
	signal Nand2860_o0 : std_logic;
	signal Or2880_o0 : std_logic;
	signal Nand2900_o0 : std_logic;
	signal Nand2920_o0 : std_logic;
	signal Nand2940_o0 : std_logic;
	signal Or2960_o0 : std_logic;
	signal Nand2980_o0 : std_logic;
	signal Or21000_o0 : std_logic;
	signal Nand21020_o0 : std_logic;
	signal Nand21040_o0 : std_logic;
	signal Or21060_o0 : std_logic;
	signal And21080_o0 : std_logic;
	signal Not1100_o0 : std_logic;
	signal Or21120_o0 : std_logic;
	signal And21140_o0 : std_logic;
	signal Nand21160_o0 : std_logic;
	signal Nand21180_o0 : std_logic;
	signal Nand21200_o0 : std_logic;
	signal Nand21220_o0 : std_logic;
	signal And21240_o0 : std_logic;
	signal Nand21260_o0 : std_logic;
	signal Or21280_o0 : std_logic;
	signal Nand21300_o0 : std_logic;
	signal Nand21320_o0 : std_logic;
	signal Or21340_o0 : std_logic;
	signal Nand21360_o0 : std_logic;
	signal Nand21380_o0 : std_logic;
	signal Or21400_o0 : std_logic;
	signal Nand21420_o0 : std_logic;
	signal Nand21440_o0 : std_logic;
	signal Or21460_o0 : std_logic;
	signal Or21480_o0 : std_logic;
	signal And21500_o0 : std_logic;
	signal Nand21520_o0 : std_logic;
	signal Nand21540_o0 : std_logic;
	signal Nand21560_o0 : std_logic;
	signal Nand21580_o0 : std_logic;
	signal Nand21600_o0 : std_logic;
	signal Nand21620_o0 : std_logic;
	signal Nand21640_o0 : std_logic;
	signal Nand21660_o0 : std_logic;
	signal Nand21680_o0 : std_logic;
	signal And21700_o0 : std_logic;
	signal Nand21720_o0 : std_logic;
	signal Nand21740_o0 : std_logic;
	signal Nand21760_o0 : std_logic;
	signal Nand21780_o0 : std_logic;
	signal Nand21800_o0 : std_logic;
	signal And21820_o0 : std_logic;
	signal And21840_o0 : std_logic;
	signal And21860_o0 : std_logic;
	signal Nand21880_o0 : std_logic;
	signal And21900_o0 : std_logic;
	signal Nand21920_o0 : std_logic;
	signal Or21940_o0 : std_logic;
	signal And21960_o0 : std_logic;
	signal Nand21980_o0 : std_logic;
	signal Nand22000_o0 : std_logic;
	signal And22020_o0 : std_logic;
	signal Nand22040_o0 : std_logic;
	signal Or22060_o0 : std_logic;
	signal And22080_o0 : std_logic;
	signal Not2100_o0 : std_logic;
	signal Or22120_o0 : std_logic;
	signal Nand22140_o0 : std_logic;
	signal Nand22160_o0 : std_logic;
	signal And22180_o0 : std_logic;
	signal Nand22200_o0 : std_logic;
	signal Nand22220_o0 : std_logic;
	signal Nand22240_o0 : std_logic;
	signal And22260_o0 : std_logic;
	signal Nand22280_o0 : std_logic;
	signal And22300_o0 : std_logic;
	signal Nand22320_o0 : std_logic;
	signal Nand22340_o0 : std_logic;
	signal Nand22360_o0 : std_logic;
	signal Or22380_o0 : std_logic;
	signal Or22400_o0 : std_logic;
	signal And22420_o0 : std_logic;
	signal Nand22440_o0 : std_logic;
	signal Nand22460_o0 : std_logic;
	signal Nand22480_o0 : std_logic;
	signal And22500_o0 : std_logic;
	signal And22520_o0 : std_logic;
	signal Nand22540_o0 : std_logic;
	signal Or22560_o0 : std_logic;
	signal Nand22580_o0 : std_logic;
	signal Nand22600_o0 : std_logic;
	signal And22620_o0 : std_logic;
	signal Or22640_o0 : std_logic;
	signal And22660_o0 : std_logic;
	signal Nand22680_o0 : std_logic;
	signal Nand22700_o0 : std_logic;
	signal Nand22720_o0 : std_logic;
	signal Nand22740_o0 : std_logic;
	signal Nand22760_o0 : std_logic;
	signal Nand22780_o0 : std_logic;
	signal Nand22800_o0 : std_logic;
	signal Nand22820_o0 : std_logic;
	signal Or22840_o0 : std_logic;
	signal Or22860_o0 : std_logic;
	signal Nand22880_o0 : std_logic;
	signal Nand22900_o0 : std_logic;
	signal Or22920_o0 : std_logic;
	signal Nand22940_o0 : std_logic;
	signal Nand22960_o0 : std_logic;
	signal Nand22980_o0 : std_logic;
	signal Xor23000_o0 : std_logic;
	signal Xor23020_o0 : std_logic;
	signal Or23360_o0 : std_logic;
	signal Nor23380_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Not60 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			o0 => Not60_o0
		);
		Not80 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			o0 => Not80_o0
		);
		Not100 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			o0 => Not100_o0
		);
		Not120 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			o0 => Not120_o0
		);
		Not140 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			o0 => Not140_o0
		);
		Not160 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			o0 => Not160_o0
		);
		Not180 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			o0 => Not180_o0
		);
		Not200 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i7,
			o0 => Not200_o0
		);
		Or2220 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not80_o0,
			i1 => Not160_o0,
			o0 => Or2220_o0
		);
		Nand2240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not120_o0,
			i1 => Or2220_o0,
			o0 => Nand2240_o0
		);
		And2260 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => i4,
			o0 => And2260_o0
		);
		Nand2280 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not60_o0,
			i1 => And2260_o0,
			o0 => Nand2280_o0
		);
		And2300 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i7,
			o0 => And2300_o0
		);
		Nand2320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => And2300_o0,
			o0 => Nand2320_o0
		);
		Nand2340 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2280_o0,
			i1 => Nand2320_o0,
			o0 => Nand2340_o0
		);
		And2360 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2240_o0,
			i1 => Nand2340_o0,
			o0 => And2360_o0
		);
		Nand2380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => And2360_o0,
			o0 => Nand2380_o0
		);
		And2400 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => i7,
			o0 => And2400_o0
		);
		Not420 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2400_o0,
			o0 => Not420_o0
		);
		Or2440 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Not420_o0,
			o0 => Or2440_o0
		);
		Nand2460 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not120_o0,
			i1 => Or2440_o0,
			o0 => Nand2460_o0
		);
		Nand2480 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand2460_o0,
			o0 => Nand2480_o0
		);
		And2500 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i5,
			o0 => And2500_o0
		);
		Nand2520 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => And2500_o0,
			o0 => Nand2520_o0
		);
		Nand2540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2480_o0,
			i1 => Nand2520_o0,
			o0 => Nand2540_o0
		);
		Nand2560 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => Nand2540_o0,
			o0 => Nand2560_o0
		);
		And2580 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => i7,
			o0 => And2580_o0
		);
		Not600 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2580_o0,
			o0 => Not600_o0
		);
		Or2620 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i5,
			o0 => Or2620_o0
		);
		Nand2640 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Or2620_o0,
			o0 => Nand2640_o0
		);
		Nand2660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not600_o0,
			i1 => Nand2640_o0,
			o0 => Nand2660_o0
		);
		Or2680 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i5,
			o0 => Or2680_o0
		);
		Nand2700 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2660_o0,
			i1 => Or2680_o0,
			o0 => Nand2700_o0
		);
		Nand2720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Nand2700_o0,
			o0 => Nand2720_o0
		);
		Or2740 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i3,
			o0 => Or2740_o0
		);
		Nand2760 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2720_o0,
			i1 => Or2740_o0,
			o0 => Nand2760_o0
		);
		Nand2780 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand2760_o0,
			o0 => Nand2780_o0
		);
		Nand2800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2560_o0,
			i1 => Nand2780_o0,
			o0 => Nand2800_o0
		);
		Nand2820 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not60_o0,
			i1 => Nand2800_o0,
			o0 => Nand2820_o0
		);
		Or2840 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Or2840_o0
		);
		Nand2860 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Or2840_o0,
			o0 => Nand2860_o0
		);
		Or2880 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i5,
			o0 => Or2880_o0
		);
		Nand2900 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Or2880_o0,
			o0 => Nand2900_o0
		);
		Nand2920 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2860_o0,
			i1 => Nand2900_o0,
			o0 => Nand2920_o0
		);
		Nand2940 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand2920_o0,
			o0 => Nand2940_o0
		);
		Or2960 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not80_o0,
			i1 => Not120_o0,
			o0 => Or2960_o0
		);
		Nand2980 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Or2960_o0,
			o0 => Nand2980_o0
		);
		Or21000 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => i6,
			o0 => Or21000_o0
		);
		Nand21020 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Or21000_o0,
			o0 => Nand21020_o0
		);
		Nand21040 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not80_o0,
			i1 => Nand21020_o0,
			o0 => Nand21040_o0
		);
		Or21060 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => i7,
			o0 => Or21060_o0
		);
		And21080 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => Or21060_o0,
			o0 => And21080_o0
		);
		Not1100 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And21080_o0,
			o0 => Not1100_o0
		);
		Or21120 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => And21080_o0,
			o0 => Or21120_o0
		);
		And21140 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21040_o0,
			i1 => Or21120_o0,
			o0 => And21140_o0
		);
		Nand21160 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2980_o0,
			i1 => And21140_o0,
			o0 => Nand21160_o0
		);
		Nand21180 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => Nand21160_o0,
			o0 => Nand21180_o0
		);
		Nand21200 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2940_o0,
			i1 => Nand21180_o0,
			o0 => Nand21200_o0
		);
		Nand21220 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Nand21200_o0,
			o0 => Nand21220_o0
		);
		And21240 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2820_o0,
			i1 => Nand21220_o0,
			o0 => And21240_o0
		);
		Nand21260 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2380_o0,
			i1 => And21240_o0,
			o0 => Nand21260_o0
		);
		Or21280 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Not600_o0,
			o0 => Or21280_o0
		);
		Nand21300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Or21280_o0,
			o0 => Nand21300_o0
		);
		Nand21320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand21300_o0,
			o0 => Nand21320_o0
		);
		Or21340 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Not1100_o0,
			o0 => Or21340_o0
		);
		Nand21360 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21320_o0,
			i1 => Or21340_o0,
			o0 => Nand21360_o0
		);
		Nand21380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not80_o0,
			i1 => Nand21360_o0,
			o0 => Nand21380_o0
		);
		Or21400 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i7,
			o0 => Or21400_o0
		);
		Nand21420 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Or21400_o0,
			o0 => Nand21420_o0
		);
		Nand21440 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Nand21420_o0,
			o0 => Nand21440_o0
		);
		Or21460 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => And2500_o0,
			o0 => Or21460_o0
		);
		Or21480 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i7,
			o0 => Or21480_o0
		);
		And21500 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or21460_o0,
			i1 => Or21480_o0,
			o0 => And21500_o0
		);
		Nand21520 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21440_o0,
			i1 => And21500_o0,
			o0 => Nand21520_o0
		);
		Nand21540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand21520_o0,
			o0 => Nand21540_o0
		);
		Nand21560 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21380_o0,
			i1 => Nand21540_o0,
			o0 => Nand21560_o0
		);
		Nand21580 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not120_o0,
			i1 => Nand21560_o0,
			o0 => Nand21580_o0
		);
		Nand21600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Or2880_o0,
			o0 => Nand21600_o0
		);
		Nand21620 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Or21000_o0,
			o0 => Nand21620_o0
		);
		Nand21640 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21600_o0,
			i1 => Nand21620_o0,
			o0 => Nand21640_o0
		);
		Nand21660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand21640_o0,
			o0 => Nand21660_o0
		);
		Nand21680 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => Nand21620_o0,
			o0 => Nand21680_o0
		);
		And21700 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Not600_o0,
			o0 => And21700_o0
		);
		Nand21720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => And21700_o0,
			o0 => Nand21720_o0
		);
		Nand21740 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21680_o0,
			i1 => Nand21720_o0,
			o0 => Nand21740_o0
		);
		Nand21760 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not80_o0,
			i1 => Nand21740_o0,
			o0 => Nand21760_o0
		);
		Nand21780 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21660_o0,
			i1 => Nand21760_o0,
			o0 => Nand21780_o0
		);
		Nand21800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nand21780_o0,
			o0 => Nand21800_o0
		);
		And21820 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Not140_o0,
			o0 => And21820_o0
		);
		And21840 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => And21820_o0,
			o0 => And21840_o0
		);
		And21860 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => And2580_o0,
			o0 => And21860_o0
		);
		Nand21880 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And21840_o0,
			i1 => And21860_o0,
			o0 => Nand21880_o0
		);
		And21900 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21800_o0,
			i1 => Nand21880_o0,
			o0 => And21900_o0
		);
		Nand21920 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand21580_o0,
			i1 => And21900_o0,
			o0 => Nand21920_o0
		);
		Or21940 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => Not140_o0,
			o0 => Or21940_o0
		);
		And21960 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => i7,
			o0 => And21960_o0
		);
		Nand21980 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => And21960_o0,
			o0 => Nand21980_o0
		);
		Nand22000 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or21940_o0,
			i1 => Nand21980_o0,
			o0 => Nand22000_o0
		);
		And22020 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2680_o0,
			i1 => Nand22000_o0,
			o0 => And22020_o0
		);
		Nand22040 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => And22020_o0,
			o0 => Nand22040_o0
		);
		Or22060 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not120_o0,
			i1 => Not140_o0,
			o0 => Or22060_o0
		);
		And22080 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => i7,
			o0 => And22080_o0
		);
		Not2100 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And22080_o0,
			o0 => Not2100_o0
		);
		Or22120 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Not2100_o0,
			o0 => Or22120_o0
		);
		Nand22140 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or22060_o0,
			i1 => Or22120_o0,
			o0 => Nand22140_o0
		);
		Nand22160 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nand22140_o0,
			o0 => Nand22160_o0
		);
		And22180 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Not140_o0,
			o0 => And22180_o0
		);
		Nand22200 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => And22180_o0,
			o0 => Nand22200_o0
		);
		Nand22220 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22160_o0,
			i1 => Nand22200_o0,
			o0 => Nand22220_o0
		);
		Nand22240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => Nand22220_o0,
			o0 => Nand22240_o0
		);
		And22260 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Not420_o0,
			o0 => And22260_o0
		);
		Nand22280 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => And22260_o0,
			o0 => Nand22280_o0
		);
		And22300 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Not1100_o0,
			o0 => And22300_o0
		);
		Nand22320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => And22300_o0,
			o0 => Nand22320_o0
		);
		Nand22340 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22280_o0,
			i1 => Nand22320_o0,
			o0 => Nand22340_o0
		);
		Nand22360 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not120_o0,
			i1 => Nand22340_o0,
			o0 => Nand22360_o0
		);
		Or22380 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => And2580_o0,
			o0 => Or22380_o0
		);
		Or22400 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => Or22380_o0,
			o0 => Or22400_o0
		);
		And22420 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Not180_o0,
			o0 => And22420_o0
		);
		Nand22440 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => And22420_o0,
			o0 => Nand22440_o0
		);
		Nand22460 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or22400_o0,
			i1 => Nand22440_o0,
			o0 => Nand22460_o0
		);
		Nand22480 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Nand22460_o0,
			o0 => Nand22480_o0
		);
		And22500 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22360_o0,
			i1 => Nand22480_o0,
			o0 => And22500_o0
		);
		And22520 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22240_o0,
			i1 => And22500_o0,
			o0 => And22520_o0
		);
		Nand22540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22040_o0,
			i1 => And22520_o0,
			o0 => Nand22540_o0
		);
		Or22560 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Not180_o0,
			o0 => Or22560_o0
		);
		Nand22580 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not2100_o0,
			i1 => Or22560_o0,
			o0 => Nand22580_o0
		);
		Nand22600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand22580_o0,
			o0 => Nand22600_o0
		);
		And22620 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => Or21480_o0,
			o0 => And22620_o0
		);
		Or22640 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => And22620_o0,
			o0 => Or22640_o0
		);
		And22660 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or21280_o0,
			i1 => Or22640_o0,
			o0 => And22660_o0
		);
		Nand22680 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22600_o0,
			i1 => And22660_o0,
			o0 => Nand22680_o0
		);
		Nand22700 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nand22680_o0,
			o0 => Nand22700_o0
		);
		Nand22720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or21060_o0,
			i1 => Or22380_o0,
			o0 => Nand22720_o0
		);
		Nand22740 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => Nand22720_o0,
			o0 => Nand22740_o0
		);
		Nand22760 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => And22620_o0,
			o0 => Nand22760_o0
		);
		Nand22780 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22740_o0,
			i1 => Nand22760_o0,
			o0 => Nand22780_o0
		);
		Nand22800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not120_o0,
			i1 => Nand22780_o0,
			o0 => Nand22800_o0
		);
		Nand22820 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22700_o0,
			i1 => Nand22800_o0,
			o0 => Nand22820_o0
		);
		Or22840 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not160_o0,
			i1 => Not2100_o0,
			o0 => Or22840_o0
		);
		Or22860 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => i7,
			o0 => Or22860_o0
		);
		Nand22880 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or22840_o0,
			i1 => Or22860_o0,
			o0 => Nand22880_o0
		);
		Nand22900 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Nand22880_o0,
			o0 => Nand22900_o0
		);
		Or22920 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => And2400_o0,
			o0 => Or22920_o0
		);
		Nand22940 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not600_o0,
			i1 => Or22920_o0,
			o0 => Nand22940_o0
		);
		Nand22960 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand22940_o0,
			o0 => Nand22960_o0
		);
		Nand22980 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22900_o0,
			i1 => Nand22960_o0,
			o0 => Nand22980_o0
		);
		Xor23000 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => And22080_o0,
			o0 => Xor23000_o0
		);
		Xor23020 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => o7,
			o0 => Xor23020_o0
		);
		Or23360 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand22980_o0,
			i1 => Nor23380_o0,
			o0 => Or23360_o0
		);
		Nor23380 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not600_o0,
			i1 => Not120_o0,
			o0 => Nor23380_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand21260_o0;
	o1 <= Nand21920_o0;
	o2 <= Nand22540_o0;
	o3 <= Nand22820_o0;
	o4 <= Or23360_o0;
	o5 <= Xor23000_o0;
	o6 <= Xor23020_o0;
	o7 <= Not200_o0;
end netenos;
