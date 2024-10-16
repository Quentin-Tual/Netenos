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
		o0 : out std_logic;
		o1 : out std_logic;
		o2 : out std_logic;
		o3 : out std_logic
	);
end rand_140;
 
architecture netenos of rand_140 is
	signal Nor2160_o0 : std_logic;
	signal Or2180_o0 : std_logic;
	signal And2200_o0 : std_logic;
	signal Xor2220_o0 : std_logic;
	signal Or2240_o0 : std_logic;
	signal Nand2260_o0 : std_logic;
	signal Not280_o0 : std_logic;
	signal Nor2300_o0 : std_logic;
	signal And2320_o0 : std_logic;
	signal Nor2340_o0 : std_logic;
	signal Xor2360_o0 : std_logic;
	signal Not380_o0 : std_logic;
	signal And2400_o0 : std_logic;
	signal Not420_o0 : std_logic;
	signal Or2440_o0 : std_logic;
	signal Or2460_o0 : std_logic;
	signal Nor2480_o0 : std_logic;
	signal And2500_o0 : std_logic;
	signal Nor2520_o0 : std_logic;
	signal Or2540_o0 : std_logic;
	signal Xor2560_o0 : std_logic;
	signal Xor2580_o0 : std_logic;
	signal Or2600_o0 : std_logic;
	signal Or2620_o0 : std_logic;
	signal Nor2640_o0 : std_logic;
	signal Nand2660_o0 : std_logic;
	signal Nand2680_o0 : std_logic;
	signal Nor2700_o0 : std_logic;
	signal And2720_o0 : std_logic;
	signal Nand2740_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Nor2160 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => i0,
			i1 => i4,
			o0 => Nor2160_o0
		);
		Or2180 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i3,
			i1 => i2,
			o0 => Or2180_o0
		);
		And2200 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => i1,
			i1 => i5,
			o0 => And2200_o0
		);
		Xor2220 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Nor2160_o0,
			i1 => Or2180_o0,
			o0 => Xor2220_o0
		);
		Or2240 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And2200_o0,
			i1 => Or2180_o0,
			o0 => Or2240_o0
		);
		Nand2260 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => i0,
			i1 => And2200_o0,
			o0 => Nand2260_o0
		);
		Not280 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or2240_o0,
			o0 => Not280_o0
		);
		Nor2300 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nand2260_o0,
			i1 => Xor2220_o0,
			o0 => Nor2300_o0
		);
		And2320 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Nand2260_o0,
			i1 => i3,
			o0 => And2320_o0
		);
		Nor2340 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor2300_o0,
			i1 => And2320_o0,
			o0 => Nor2340_o0
		);
		Xor2360 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Not280_o0,
			i1 => Nor2300_o0,
			o0 => Xor2360_o0
		);
		Not380 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor2160_o0,
			o0 => Not380_o0
		);
		And2400 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Nor2340_o0,
			i1 => Xor2360_o0,
			o0 => And2400_o0
		);
		Not420 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not380_o0,
			o0 => Not420_o0
		);
		Or2440 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And2320_o0,
			i1 => i1,
			o0 => Or2440_o0
		);
		Or2460 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Not420_o0,
			i1 => And2400_o0,
			o0 => Or2460_o0
		);
		Nor2480 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Or2440_o0,
			i1 => Nor2160_o0,
			o0 => Nor2480_o0
		);
		And2500 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => i2,
			i1 => Xor2360_o0,
			o0 => And2500_o0
		);
		Nor2520 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor2480_o0,
			i1 => Or2460_o0,
			o0 => Nor2520_o0
		);
		Or2540 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And2500_o0,
			i1 => i5,
			o0 => Or2540_o0
		);
		Xor2560 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Not280_o0,
			i1 => Or2180_o0,
			o0 => Xor2560_o0
		);
		Xor2580 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Xor2560_o0,
			i1 => Or2540_o0,
			o0 => Xor2580_o0
		);
		Or2600 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Nor2520_o0,
			i1 => Nor2300_o0,
			o0 => Or2600_o0
		);
		Or2620 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And2400_o0,
			i1 => Not380_o0,
			o0 => Or2620_o0
		);
		Nor2640 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Or2600_o0,
			i1 => Or2620_o0,
			o0 => Nor2640_o0
		);
		Nand2660 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Xor2580_o0,
			i1 => Nor2340_o0,
			o0 => Nand2660_o0
		);
		Nand2680 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Not420_o0,
			i1 => Xor2580_o0,
			o0 => Nand2680_o0
		);
		Nor2700 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor2640_o0,
			i1 => Nand2680_o0,
			o0 => Nor2700_o0
		);
		And2720 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Nand2660_o0,
			i1 => Xor2560_o0,
			o0 => And2720_o0
		);
		Nand2740 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => i4,
			i1 => Or2440_o0,
			o0 => Nand2740_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand2740_o0;
	o1 <= And2720_o0;
	o2 <= Nor2700_o0;
	o3 <= Nand2660_o0;
end netenos;
