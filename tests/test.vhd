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
		o0 : out std_logic;
		o1 : out std_logic;
		o2 : out std_logic;
		o3 : out std_logic
	);
end test;
 
architecture netenos of test is
	signal Not60_o0 : std_logic;
	signal Not80_o0 : std_logic;
	signal Not100_o0 : std_logic;
	signal Not120_o0 : std_logic;
	signal Nand2140_o0 : std_logic;
	signal Or2160_o0 : std_logic;
	signal Not180_o0 : std_logic;
	signal Nand2200_o0 : std_logic;
	signal Or2220_o0 : std_logic;
	signal Nand2240_o0 : std_logic;
	signal Xor2260_o0 : std_logic;
	signal Not280_o0 : std_logic;
	signal Nand2300_o0 : std_logic;
	signal And2320_o0 : std_logic;
	signal Xor2340_o0 : std_logic;
	signal Xor2360_o0 : std_logic;
	signal And2380_o0 : std_logic;
	signal Not400_o0 : std_logic;
	signal And2420_o0 : std_logic;
	signal Not440_o0 : std_logic;
	signal And2460_o0 : std_logic;
	signal Nand2480_o0 : std_logic;
	signal Not500_o0 : std_logic;
	signal And2520_o0 : std_logic;
	signal And2540_o0 : std_logic;
	signal And2560_o0 : std_logic;
	signal Nand2580_o0 : std_logic;
	signal Nand2600_o0 : std_logic;
	signal Not620_o0 : std_logic;
	signal Nor2640_o0 : std_logic;
	signal Nand2660_o0 : std_logic;
	signal Or2680_o0 : std_logic;
	signal Not700_o0 : std_logic;
	signal Xor2720_o0 : std_logic;
	signal Not740_o0 : std_logic;
	signal Nor2760_o0 : std_logic;
	signal Not780_o0 : std_logic;
	signal Nand2800_o0 : std_logic;
	signal Or2820_o0 : std_logic;
	signal Xor2840_o0 : std_logic;
	signal Or21780_o0 : std_logic;
	signal Nor21800_o0 : std_logic;
	signal Nor21820_o0 : std_logic;
	signal And21840_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Not60 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			o0 => Not60_o0
		);
		Not80 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i5,
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
			i0 => i0,
			o0 => Not120_o0
		);
		Nand2140 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i3,
			o0 => Nand2140_o0
		);
		Or2160 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not80_o0,
			i1 => Not60_o0,
			o0 => Or2160_o0
		);
		Not180 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not120_o0,
			o0 => Not180_o0
		);
		Nand2200 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			i1 => i0,
			o0 => Nand2200_o0
		);
		Or2220 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2140_o0,
			i1 => Nand2200_o0,
			o0 => Or2220_o0
		);
		Nand2240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not180_o0,
			i1 => Or2160_o0,
			o0 => Nand2240_o0
		);
		Xor2260 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2160_o0,
			i1 => Not120_o0,
			o0 => Xor2260_o0
		);
		Not280 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand2200_o0,
			o0 => Not280_o0
		);
		Nand2300 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not280_o0,
			i1 => Or2220_o0,
			o0 => Nand2300_o0
		);
		And2320 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2240_o0,
			i1 => Xor2260_o0,
			o0 => And2320_o0
		);
		Xor2340 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2240_o0,
			i1 => Not180_o0,
			o0 => Xor2340_o0
		);
		Xor2360 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2140_o0,
			i1 => Not280_o0,
			o0 => Xor2360_o0
		);
		And2380 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2360_o0,
			i1 => Nand2300_o0,
			o0 => And2380_o0
		);
		Not400 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2320_o0,
			o0 => Not400_o0
		);
		And2420 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2340_o0,
			i1 => Not180_o0,
			o0 => And2420_o0
		);
		Not440 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not100_o0,
			o0 => Not440_o0
		);
		And2460 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Not400_o0,
			i1 => Not440_o0,
			o0 => And2460_o0
		);
		Nand2480 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => And2380_o0,
			i1 => And2420_o0,
			o0 => Nand2480_o0
		);
		Not500 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand2140_o0,
			o0 => Not500_o0
		);
		And2520 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2260_o0,
			i1 => Or2220_o0,
			o0 => And2520_o0
		);
		And2540 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2480_o0,
			i1 => Not500_o0,
			o0 => And2540_o0
		);
		And2560 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => And2520_o0,
			i1 => And2460_o0,
			o0 => And2560_o0
		);
		Nand2580 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2200_o0,
			i1 => Not80_o0,
			o0 => Nand2580_o0
		);
		Nand2600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2340_o0,
			i1 => Xor2260_o0,
			o0 => Nand2600_o0
		);
		Not620 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => And2540_o0,
			o0 => Not620_o0
		);
		Nor2640 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2580_o0,
			i1 => And2560_o0,
			o0 => Nor2640_o0
		);
		Nand2660 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2600_o0,
			i1 => Xor2360_o0,
			o0 => Nand2660_o0
		);
		Or2680 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2580_o0,
			i1 => And2460_o0,
			o0 => Or2680_o0
		);
		Not700 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or2680_o0,
			o0 => Not700_o0
		);
		Xor2720 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not620_o0,
			i1 => Or21780_o0,
			o0 => Xor2720_o0
		);
		Not740 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor2640_o0,
			o0 => Not740_o0
		);
		Nor2760 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => And2420_o0,
			i1 => And2540_o0,
			o0 => Nor2760_o0
		);
		Not780 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Xor2720_o0,
			o0 => Not780_o0
		);
		Nand2800 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor2760_o0,
			i1 => Not740_o0,
			o0 => Nand2800_o0
		);
		Or2820 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not700_o0,
			i1 => Not60_o0,
			o0 => Or2820_o0
		);
		Xor2840 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not500_o0,
			i1 => Nand2300_o0,
			o0 => Xor2840_o0
		);
		Or21780 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2660_o0,
			i1 => And21840_o0,
			o0 => Or21780_o0
		);
		Nor21800 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2160_o0,
			i1 => i3,
			o0 => Nor21800_o0
		);
		Nor21820 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2220_o0,
			i1 => Not60_o0,
			o0 => Nor21820_o0
		);
		And21840 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nor21800_o0,
			i1 => Nor21820_o0,
			o0 => And21840_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand2800_o0;
	o1 <= Or2820_o0;
	o2 <= Not780_o0;
	o3 <= Xor2840_o0;
end netenos;
