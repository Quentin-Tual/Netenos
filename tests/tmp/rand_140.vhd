library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity rand_140 is
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
end rand_140;
 
architecture netenos of rand_140 is
	signal Or2160_o0 : std_logic;
	signal Xor2180_o0 : std_logic;
	signal Nor2200_o0 : std_logic;
	signal Nor2220_o0 : std_logic;
	signal Or2240_o0 : std_logic;
	signal Not260_o0 : std_logic;
	signal And2280_o0 : std_logic;
	signal Nand2300_o0 : std_logic;
	signal Or2320_o0 : std_logic;
	signal Nor2340_o0 : std_logic;
	signal Nor2360_o0 : std_logic;
	signal Nor2380_o0 : std_logic;
	signal And2400_o0 : std_logic;
	signal Nor2420_o0 : std_logic;
	signal Nor2440_o0 : std_logic;
	signal Nand2460_o0 : std_logic;
	signal Not480_o0 : std_logic;
	signal Or2500_o0 : std_logic;
	signal Xor2520_o0 : std_logic;
	signal And2540_o0 : std_logic;
	signal And2560_o0 : std_logic;
	signal Xor2580_o0 : std_logic;
	signal And2600_o0 : std_logic;
	signal Xor2620_o0 : std_logic;
	signal And2640_o0 : std_logic;
	signal Not660_o0 : std_logic;
	signal Nand2680_o0 : std_logic;
	signal Not700_o0 : std_logic;
	signal And2720_o0 : std_logic;
	signal Xor2740_o0 : std_logic;
	signal Nand2760_o0 : std_logic;
	signal Nor2780_o0 : std_logic;
	signal Xor2800_o0 : std_logic;
	signal Nand2820_o0 : std_logic;
	signal Nor2840_o0 : std_logic;
	signal Nand2860_o0 : std_logic;
	signal Nand2880_o0 : std_logic;
	signal Or2900_o0 : std_logic;
	signal Or2920_o0 : std_logic;
	signal Nand2940_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Or2160 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => i7,
			i1 => i5,
			o0 => Or2160_o0
		);
		Xor2180 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => i4,
			i1 => i0,
			o0 => Xor2180_o0
		);
		Nor2200 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => i1,
			i1 => i6,
			o0 => Nor2200_o0
		);
		Nor2220 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => i2,
			i1 => i3,
			o0 => Nor2220_o0
		);
		Or2240 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Nor2220_o0,
			i1 => Or2160_o0,
			o0 => Or2240_o0
		);
		Not260 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Xor2180_o0,
			o0 => Not260_o0
		);
		And2280 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nor2200_o0,
			i1 => i7,
			o0 => And2280_o0
		);
		Nand2300 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Xor2180_o0,
			i1 => Nor2200_o0,
			o0 => Nand2300_o0
		);
		Or2320 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Nand2300_o0,
			i1 => Not260_o0,
			o0 => Or2320_o0
		);
		Nor2340 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Or2240_o0,
			i1 => And2280_o0,
			o0 => Nor2340_o0
		);
		Nor2360 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => i2,
			i1 => Nor2220_o0,
			o0 => Nor2360_o0
		);
		Nor2380 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Or2160_o0,
			i1 => Nor2200_o0,
			o0 => Nor2380_o0
		);
		And2400 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nor2380_o0,
			i1 => Or2320_o0,
			o0 => And2400_o0
		);
		Nor2420 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Nor2360_o0,
			i1 => Nor2340_o0,
			o0 => Nor2420_o0
		);
		Nor2440 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => i5,
			i1 => i4,
			o0 => Nor2440_o0
		);
		Nand2460 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => i1,
			i1 => Nor2340_o0,
			o0 => Nand2460_o0
		);
		Not480 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Nor2440_o0,
			o0 => Not480_o0
		);
		Or2500 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Nand2460_o0,
			i1 => And2400_o0,
			o0 => Or2500_o0
		);
		Xor2520 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Nor2420_o0,
			i1 => And2280_o0,
			o0 => Xor2520_o0
		);
		And2540 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => i3,
			i1 => Nor2420_o0,
			o0 => And2540_o0
		);
		And2560 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Not480_o0,
			i1 => Xor2520_o0,
			o0 => And2560_o0
		);
		Xor2580 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Or2500_o0,
			i1 => And2540_o0,
			o0 => Xor2580_o0
		);
		And2600 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Xor2520_o0,
			i1 => Xor2180_o0,
			o0 => And2600_o0
		);
		Xor2620 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Not260_o0,
			i1 => Nor2220_o0,
			o0 => Xor2620_o0
		);
		And2640 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => And2600_o0,
			i1 => Xor2580_o0,
			o0 => And2640_o0
		);
		Not660 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => And2560_o0,
			o0 => Not660_o0
		);
		Nand2680 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Xor2620_o0,
			i1 => Not480_o0,
			o0 => Nand2680_o0
		);
		Not700 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Or2160_o0,
			o0 => Not700_o0
		);
		And2720 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nand2680_o0,
			i1 => Not700_o0,
			o0 => And2720_o0
		);
		Xor2740 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Not660_o0,
			i1 => And2640_o0,
			o0 => Xor2740_o0
		);
		Nand2760 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nor2200_o0,
			i1 => Xor2180_o0,
			o0 => Nand2760_o0
		);
		Nor2780 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => And2640_o0,
			i1 => Or2500_o0,
			o0 => Nor2780_o0
		);
		Xor2800 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Nand2760_o0,
			i1 => Xor2740_o0,
			o0 => Xor2800_o0
		);
		Nand2820 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nor2780_o0,
			i1 => And2720_o0,
			o0 => Nand2820_o0
		);
		Nor2840 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => i0,
			i1 => i6,
			o0 => Nor2840_o0
		);
		Nand2860 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nand2680_o0,
			i1 => Nor2220_o0,
			o0 => Nand2860_o0
		);
		Nand2880 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nand2860_o0,
			i1 => Nand2820_o0,
			o0 => Nand2880_o0
		);
		Or2900 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Xor2800_o0,
			i1 => Nor2840_o0,
			o0 => Or2900_o0
		);
		Or2920 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Not660_o0,
			i1 => Nand2300_o0,
			o0 => Or2920_o0
		);
		Nand2940 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nand2820_o0,
			i1 => i6,
			o0 => Nand2940_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand2940_o0;
	o1 <= Or2900_o0;
	o2 <= Or2920_o0;
	o3 <= Nand2880_o0;
end netenos;
