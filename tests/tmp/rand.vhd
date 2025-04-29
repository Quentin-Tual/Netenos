library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity rand is
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
		o4 : out std_logic
	);
end rand;
 
architecture netenos of rand is
	signal Xor2140_o0 : std_logic;
	signal Nand2160_o0 : std_logic;
	signal Nand2180_o0 : std_logic;
	signal Nor2200_o0 : std_logic;
	signal Or2220_o0 : std_logic;
	signal And2240_o0 : std_logic;
	signal Xor2260_o0 : std_logic;
	signal Nand2280_o0 : std_logic;
	signal Xor2300_o0 : std_logic;
	signal Or2320_o0 : std_logic;
	signal Nor2340_o0 : std_logic;
	signal Nor2360_o0 : std_logic;
	signal Nand2380_o0 : std_logic;
	signal And2400_o0 : std_logic;
	signal And2420_o0 : std_logic;
	signal Xor2440_o0 : std_logic;
	signal And2460_o0 : std_logic;
	signal Nand2480_o0 : std_logic;
	signal Or2500_o0 : std_logic;
	signal Xor2520_o0 : std_logic;
	signal Nand2540_o0 : std_logic;
	signal Nor2560_o0 : std_logic;
	signal Xor2580_o0 : std_logic;
	signal Or2600_o0 : std_logic;
	signal And2620_o0 : std_logic;
	signal Not640_o0 : std_logic;
	signal Nand2660_o0 : std_logic;
	signal Xor2680_o0 : std_logic;
	signal Xor2700_o0 : std_logic;
	signal Nand2720_o0 : std_logic;
	signal And2740_o0 : std_logic;
	signal Or2760_o0 : std_logic;
	signal Nand2780_o0 : std_logic;
	signal Nand2800_o0 : std_logic;
	signal Not820_o0 : std_logic;
	signal Xor2840_o0 : std_logic;
	signal Nor2860_o0 : std_logic;
	signal And2880_o0 : std_logic;
	signal Not900_o0 : std_logic;
	signal Not920_o0 : std_logic;
	signal Or2940_o0 : std_logic;
	signal Nand2960_o0 : std_logic;
	signal And2980_o0 : std_logic;
	signal Nand21000_o0 : std_logic;
	signal Not1020_o0 : std_logic;
	signal Nand21040_o0 : std_logic;
	signal Nor21060_o0 : std_logic;
	signal And21080_o0 : std_logic;
	signal Nand21100_o0 : std_logic;
	signal And21120_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Xor2140 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i7,
			o0 => Xor2140_o0
		);
		Nand2160 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i6,
			o0 => Nand2160_o0
		);
		Nand2180 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => i2,
			o0 => Nand2180_o0
		);
		Nor2200 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => i4,
			o0 => Nor2200_o0
		);
		Or2220 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i5,
			o0 => Or2220_o0
		);
		And2240 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2180_o0,
			i1 => Nand2160_o0,
			o0 => And2240_o0
		);
		Xor2260 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2140_o0,
			i1 => Or2220_o0,
			o0 => Xor2260_o0
		);
		Nand2280 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2200_o0,
			i1 => Nand2180_o0,
			o0 => Nand2280_o0
		);
		Xor2300 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2220_o0,
			i1 => i2,
			o0 => Xor2300_o0
		);
		Or2320 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2200_o0,
			i1 => Nand2160_o0,
			o0 => Or2320_o0
		);
		Nor2340 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2320_o0,
			i1 => Xor2300_o0,
			o0 => Nor2340_o0
		);
		Nor2360 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2260_o0,
			i1 => And2240_o0,
			o0 => Nor2360_o0
		);
		Nand2380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2280_o0,
			i1 => Nand2280_o0,
			o0 => Nand2380_o0
		);
		And2400 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i7,
			i1 => i4,
			o0 => And2400_o0
		);
		And2420 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2140_o0,
			i1 => Nand2180_o0,
			o0 => And2420_o0
		);
		Xor2440 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And2420_o0,
			i1 => Nand2380_o0,
			o0 => Xor2440_o0
		);
		And2460 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2340_o0,
			i1 => And2400_o0,
			o0 => And2460_o0
		);
		Nand2480 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2360_o0,
			i1 => And2420_o0,
			o0 => Nand2480_o0
		);
		Or2500 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2200_o0,
			i1 => Xor2260_o0,
			o0 => Or2500_o0
		);
		Xor2520 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2300_o0,
			i1 => Nand2380_o0,
			o0 => Xor2520_o0
		);
		Nand2540 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2480_o0,
			i1 => Xor2440_o0,
			o0 => Nand2540_o0
		);
		Nor2560 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2520_o0,
			i1 => Or2500_o0,
			o0 => Nor2560_o0
		);
		Xor2580 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And2460_o0,
			i1 => Nor2360_o0,
			o0 => Xor2580_o0
		);
		Or2600 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => And2400_o0,
			i1 => i0,
			o0 => Or2600_o0
		);
		And2620 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2440_o0,
			i1 => i6,
			o0 => And2620_o0
		);
		Not640 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand2540_o0,
			o0 => Not640_o0
		);
		Nand2660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2580_o0,
			i1 => Nor2560_o0,
			o0 => Nand2660_o0
		);
		Xor2680 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And2620_o0,
			i1 => Or2600_o0,
			o0 => Xor2680_o0
		);
		Xor2700 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2340_o0,
			i1 => Xor2520_o0,
			o0 => Xor2700_o0
		);
		Nand2720 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2620_o0,
			i1 => Or2500_o0,
			o0 => Nand2720_o0
		);
		And2740 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2720_o0,
			i1 => Xor2700_o0,
			o0 => And2740_o0
		);
		Or2760 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2660_o0,
			i1 => Xor2680_o0,
			o0 => Or2760_o0
		);
		Nand2780 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not640_o0,
			i1 => Nand2160_o0,
			o0 => Nand2780_o0
		);
		Nand2800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2380_o0,
			i1 => And2460_o0,
			o0 => Nand2800_o0
		);
		Not820 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			o0 => Not820_o0
		);
		Xor2840 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And2740_o0,
			i1 => Or2760_o0,
			o0 => Xor2840_o0
		);
		Nor2860 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2780_o0,
			i1 => Not820_o0,
			o0 => Nor2860_o0
		);
		And2880 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2800_o0,
			i1 => Not640_o0,
			o0 => And2880_o0
		);
		Not900 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor2360_o0,
			o0 => Not900_o0
		);
		Not920 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand2480_o0,
			o0 => Not920_o0
		);
		Or2940 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2840_o0,
			i1 => Not920_o0,
			o0 => Or2940_o0
		);
		Nand2960 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2860_o0,
			i1 => Not900_o0,
			o0 => Nand2960_o0
		);
		And2980 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2880_o0,
			i1 => Xor2440_o0,
			o0 => And2980_o0
		);
		Nand21000 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2840_o0,
			i1 => Not900_o0,
			o0 => Nand21000_o0
		);
		Not1020 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2420_o0,
			o0 => Not1020_o0
		);
		Nand21040 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not1020_o0,
			i1 => And2980_o0,
			o0 => Nand21040_o0
		);
		Nor21060 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2960_o0,
			i1 => Nand21000_o0,
			o0 => Nor21060_o0
		);
		And21080 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2940_o0,
			i1 => Nand2960_o0,
			o0 => And21080_o0
		);
		Nand21100 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2140_o0,
			i1 => Nand2480_o0,
			o0 => Nand21100_o0
		);
		And21120 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2780_o0,
			i1 => Or2600_o0,
			o0 => And21120_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nor21060_o0;
	o1 <= And21120_o0;
	o2 <= Nand21040_o0;
	o3 <= And21080_o0;
	o4 <= Nand21100_o0;
end netenos;
