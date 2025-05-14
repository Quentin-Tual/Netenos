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
	signal Xor46860_o0 : std_logic;
	signal Nor56880_o0 : std_logic;
	signal Nand56900_o0 : std_logic;
	signal Or56920_o0 : std_logic;
	signal Xor36940_o0 : std_logic;
	signal Or36960_o0 : std_logic;
	signal Xor36980_o0 : std_logic;
	signal Or47000_o0 : std_logic;
	signal Or57020_o0 : std_logic;
	signal Nand47040_o0 : std_logic;
	signal Nor57060_o0 : std_logic;
	signal Xor57080_o0 : std_logic;
	signal Xor57100_o0 : std_logic;
	signal Nor37120_o0 : std_logic;
	signal Nand57140_o0 : std_logic;
	signal Nor37160_o0 : std_logic;
	signal Nand37180_o0 : std_logic;
	signal Nand57200_o0 : std_logic;
	signal And57220_o0 : std_logic;
	signal And47240_o0 : std_logic;
	signal Or47260_o0 : std_logic;
	signal Xor57280_o0 : std_logic;
	signal Xor37300_o0 : std_logic;
	signal Xor57320_o0 : std_logic;
	signal And47340_o0 : std_logic;
	signal Nor57360_o0 : std_logic;
	signal Or57380_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Xor46860 : entity gtech_lib.xor4_d
		generic map(7000 fs)
		port map(
			i0 => i2,
			i1 => i4,
			i2 => i5,
			i3 => i7,
			o0 => Xor46860_o0
		);
		Nor56880 : entity gtech_lib.nor5_d
		generic map(7000 fs)
		port map(
			i0 => i0,
			i1 => i6,
			i2 => i3,
			i3 => i1,
			i4 => i0,
			o0 => Nor56880_o0
		);
		Nand56900 : entity gtech_lib.nand5_d
		generic map(7000 fs)
		port map(
			i0 => i7,
			i1 => i5,
			i2 => i1,
			i3 => i2,
			i4 => i3,
			o0 => Nand56900_o0
		);
		Or56920 : entity gtech_lib.or5_d
		generic map(6000 fs)
		port map(
			i0 => i6,
			i1 => i4,
			i2 => i7,
			i3 => i2,
			i4 => i4,
			o0 => Or56920_o0
		);
		Xor36940 : entity gtech_lib.xor3_d
		generic map(6000 fs)
		port map(
			i0 => i6,
			i1 => i1,
			i2 => i0,
			o0 => Xor36940_o0
		);
		Or36960 : entity gtech_lib.or3_d
		generic map(4000 fs)
		port map(
			i0 => Nor56880_o0,
			i1 => Or56920_o0,
			i2 => Nand56900_o0,
			o0 => Or36960_o0
		);
		Xor36980 : entity gtech_lib.xor3_d
		generic map(6000 fs)
		port map(
			i0 => Xor36940_o0,
			i1 => Xor46860_o0,
			i2 => Nor56880_o0,
			o0 => Xor36980_o0
		);
		Or47000 : entity gtech_lib.or4_d
		generic map(5000 fs)
		port map(
			i0 => Nand56900_o0,
			i1 => Or56920_o0,
			i2 => i5,
			i3 => i3,
			o0 => Or47000_o0
		);
		Or57020 : entity gtech_lib.or5_d
		generic map(6000 fs)
		port map(
			i0 => Xor46860_o0,
			i1 => Xor36940_o0,
			i2 => Nand56900_o0,
			i3 => Xor46860_o0,
			i4 => i4,
			o0 => Or57020_o0
		);
		Nand47040 : entity gtech_lib.nand4_d
		generic map(6000 fs)
		port map(
			i0 => Or56920_o0,
			i1 => Nor56880_o0,
			i2 => i5,
			i3 => i6,
			o0 => Nand47040_o0
		);
		Nor57060 : entity gtech_lib.nor5_d
		generic map(7000 fs)
		port map(
			i0 => Or47000_o0,
			i1 => Or57020_o0,
			i2 => Nand47040_o0,
			i3 => Xor36980_o0,
			i4 => Or36960_o0,
			o0 => Nor57060_o0
		);
		Xor57080 : entity gtech_lib.xor5_d
		generic map(8000 fs)
		port map(
			i0 => Xor36940_o0,
			i1 => Nor56880_o0,
			i2 => i0,
			i3 => i1,
			i4 => Or36960_o0,
			o0 => Xor57080_o0
		);
		Xor57100 : entity gtech_lib.xor5_d
		generic map(8000 fs)
		port map(
			i0 => i7,
			i1 => Nand56900_o0,
			i2 => i2,
			i3 => Or47000_o0,
			i4 => i3,
			o0 => Xor57100_o0
		);
		Nor37120 : entity gtech_lib.nor3_d
		generic map(5000 fs)
		port map(
			i0 => i4,
			i1 => i7,
			i2 => i5,
			o0 => Nor37120_o0
		);
		Nand57140 : entity gtech_lib.nand5_d
		generic map(7000 fs)
		port map(
			i0 => Or56920_o0,
			i1 => Xor46860_o0,
			i2 => Nand47040_o0,
			i3 => Or57020_o0,
			i4 => Xor36980_o0,
			o0 => Nand57140_o0
		);
		Nor37160 : entity gtech_lib.nor3_d
		generic map(5000 fs)
		port map(
			i0 => Xor57100_o0,
			i1 => Xor57080_o0,
			i2 => Nand57140_o0,
			o0 => Nor37160_o0
		);
		Nand37180 : entity gtech_lib.nand3_d
		generic map(5000 fs)
		port map(
			i0 => Nor37120_o0,
			i1 => Nor57060_o0,
			i2 => Or36960_o0,
			o0 => Nand37180_o0
		);
		Nand57200 : entity gtech_lib.nand5_d
		generic map(7000 fs)
		port map(
			i0 => Xor36940_o0,
			i1 => Xor46860_o0,
			i2 => Nor57060_o0,
			i3 => Or47000_o0,
			i4 => Nand57140_o0,
			o0 => Nand57200_o0
		);
		And57220 : entity gtech_lib.and5_d
		generic map(6000 fs)
		port map(
			i0 => i3,
			i1 => Xor36940_o0,
			i2 => i1,
			i3 => Nand56900_o0,
			i4 => Nand47040_o0,
			o0 => And57220_o0
		);
		And47240 : entity gtech_lib.and4_d
		generic map(5000 fs)
		port map(
			i0 => Nand57200_o0,
			i1 => Nor37160_o0,
			i2 => And57220_o0,
			i3 => Nand37180_o0,
			o0 => And47240_o0
		);
		Or47260 : entity gtech_lib.or4_d
		generic map(5000 fs)
		port map(
			i0 => i6,
			i1 => Nor37120_o0,
			i2 => i2,
			i3 => Nand37180_o0,
			o0 => Or47260_o0
		);
		Xor57280 : entity gtech_lib.xor5_d
		generic map(8000 fs)
		port map(
			i0 => Xor36980_o0,
			i1 => Nand57200_o0,
			i2 => Or56920_o0,
			i3 => Nor56880_o0,
			i4 => And57220_o0,
			o0 => Xor57280_o0
		);
		Xor37300 : entity gtech_lib.xor3_d
		generic map(6000 fs)
		port map(
			i0 => Nor37160_o0,
			i1 => And57220_o0,
			i2 => Xor57100_o0,
			o0 => Xor37300_o0
		);
		Xor57320 : entity gtech_lib.xor5_d
		generic map(8000 fs)
		port map(
			i0 => Xor37300_o0,
			i1 => Xor57280_o0,
			i2 => And47240_o0,
			i3 => Or47260_o0,
			i4 => Or57020_o0,
			o0 => Xor57320_o0
		);
		And47340 : entity gtech_lib.and4_d
		generic map(5000 fs)
		port map(
			i0 => Xor57080_o0,
			i1 => Nand37180_o0,
			i2 => i0,
			i3 => Or36960_o0,
			o0 => And47340_o0
		);
		Nor57360 : entity gtech_lib.nor5_d
		generic map(7000 fs)
		port map(
			i0 => Or57020_o0,
			i1 => Nor37120_o0,
			i2 => Nor37160_o0,
			i3 => Xor57280_o0,
			i4 => Xor46860_o0,
			o0 => Nor57360_o0
		);
		Or57380 : entity gtech_lib.or5_d
		generic map(6000 fs)
		port map(
			i0 => Xor57100_o0,
			i1 => Nand57200_o0,
			i2 => i1,
			i3 => Or47000_o0,
			i4 => i2,
			o0 => Or57380_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nor57360_o0;
	o1 <= And47340_o0;
	o2 <= Xor57320_o0;
	o3 <= Or57380_o0;
end netenos;
