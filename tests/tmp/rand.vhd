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
		o1 : out std_logic
	);
end rand;
 
architecture netenos of rand is
	signal Nor260_o0 : std_logic;
	signal Nor280_o0 : std_logic;
	signal Xor2100_o0 : std_logic;
	signal Or2120_o0 : std_logic;
	signal Not140_o0 : std_logic;
	signal And2160_o0 : std_logic;
	signal Nand2180_o0 : std_logic;
	signal Or2200_o0 : std_logic;
	signal Or2220_o0 : std_logic;
	signal Xor2240_o0 : std_logic;
	signal And2260_o0 : std_logic;
	signal And2280_o0 : std_logic;
	signal Nand2300_o0 : std_logic;
	signal Nand2320_o0 : std_logic;
	signal Or2340_o0 : std_logic;
	signal And2360_o0 : std_logic;
	signal And2380_o0 : std_logic;
	signal Or2400_o0 : std_logic;
	signal Nand2420_o0 : std_logic;
	signal Or2440_o0 : std_logic;
	signal And2460_o0 : std_logic;
	signal Xor2480_o0 : std_logic;
	signal Xor2500_o0 : std_logic;
	signal And2520_o0 : std_logic;
	signal And2540_o0 : std_logic;
	signal Not560_o0 : std_logic;
	signal Nor2580_o0 : std_logic;
	signal Not600_o0 : std_logic;
	signal Not620_o0 : std_logic;
	signal Not640_o0 : std_logic;
	signal Nand2660_o0 : std_logic;
	signal Or2680_o0 : std_logic;
	signal Nor2700_o0 : std_logic;
	signal Xor2720_o0 : std_logic;
	signal And2740_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Nor260 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Nor260_o0
		);
		Nor280 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => i5,
			o0 => Nor280_o0
		);
		Xor2100 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i7,
			i1 => i1,
			o0 => Xor2100_o0
		);
		Or2120 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i0,
			o0 => Or2120_o0
		);
		Not140 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			o0 => Not140_o0
		);
		And2160 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2120_o0,
			i1 => Nor260_o0,
			o0 => And2160_o0
		);
		Nand2180 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Nor280_o0,
			o0 => Nand2180_o0
		);
		Or2200 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2100_o0,
			i1 => i3,
			o0 => Or2200_o0
		);
		Or2220 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => Nor260_o0,
			o0 => Or2220_o0
		);
		Xor2240 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i5,
			o0 => Xor2240_o0
		);
		And2260 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2220_o0,
			i1 => Nand2180_o0,
			o0 => And2260_o0
		);
		And2280 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2200_o0,
			i1 => And2160_o0,
			o0 => And2280_o0
		);
		Nand2300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2240_o0,
			i1 => Or2120_o0,
			o0 => Nand2300_o0
		);
		Nand2320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => i4,
			o0 => Nand2320_o0
		);
		Or2340 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2300_o0,
			i1 => And2260_o0,
			o0 => Or2340_o0
		);
		And2360 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2320_o0,
			i1 => And2280_o0,
			o0 => And2360_o0
		);
		And2380 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2100_o0,
			i1 => Nand2300_o0,
			o0 => And2380_o0
		);
		Or2400 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => And2260_o0,
			i1 => i7,
			o0 => Or2400_o0
		);
		Nand2420 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2380_o0,
			i1 => Or2400_o0,
			o0 => Nand2420_o0
		);
		Or2440 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => And2360_o0,
			i1 => Or2340_o0,
			o0 => Or2440_o0
		);
		And2460 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2380_o0,
			i1 => i0,
			o0 => And2460_o0
		);
		Xor2480 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And2360_o0,
			i1 => i6,
			o0 => Xor2480_o0
		);
		Xor2500 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2440_o0,
			i1 => And2460_o0,
			o0 => Xor2500_o0
		);
		And2520 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2480_o0,
			i1 => Nand2420_o0,
			o0 => And2520_o0
		);
		And2540 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2280_o0,
			i1 => Or2400_o0,
			o0 => And2540_o0
		);
		Not560 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2520_o0,
			o0 => Not560_o0
		);
		Nor2580 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => And2540_o0,
			i1 => Xor2500_o0,
			o0 => Nor2580_o0
		);
		Not600 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Xor2480_o0,
			o0 => Not600_o0
		);
		Not620 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not560_o0,
			o0 => Not620_o0
		);
		Not640 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor2580_o0,
			o0 => Not640_o0
		);
		Nand2660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not600_o0,
			i1 => Or2340_o0,
			o0 => Nand2660_o0
		);
		Or2680 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2660_o0,
			i1 => Not640_o0,
			o0 => Or2680_o0
		);
		Nor2700 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not620_o0,
			i1 => Nand2320_o0,
			o0 => Nor2700_o0
		);
		Xor2720 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2680_o0,
			i1 => Nor2700_o0,
			o0 => Xor2720_o0
		);
		And2740 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2280_o0,
			i1 => And2520_o0,
			o0 => And2740_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= And2740_o0;
	o1 <= Xor2720_o0;
end netenos;
