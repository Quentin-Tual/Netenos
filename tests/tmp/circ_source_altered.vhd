library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity circ_source_altered is
	port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		o0 : out std_logic
	);
end circ_source_altered;
 
architecture netenos of circ_source_altered is
	signal Not140_o0 : std_logic;
	signal Xor2160_o0 : std_logic;
	signal Xor2180_o0 : std_logic;
	signal Or2200_o0 : std_logic;
	signal Xor2220_o0 : std_logic;
	signal Nand2240_o0 : std_logic;
	signal And2260_o0 : std_logic;
	signal Or2280_o0 : std_logic;
	signal Xor2300_o0 : std_logic;
	signal Nand2320_o0 : std_logic;
	signal Or2340_o0 : std_logic;
	signal Nand2360_o0 : std_logic;
	signal Nand2380_o0 : std_logic;
	signal Nand2400_o0 : std_logic;
	signal Or2660_o0 : std_logic;
	signal Nor2680_o0 : std_logic;
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
		Xor2160 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Xor2160_o0
		);
		Xor2180 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i2,
			o0 => Xor2180_o0
		);
		Or2200 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Xor2180_o0,
			o0 => Or2200_o0
		);
		Xor2220 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i2,
			o0 => Xor2220_o0
		);
		Nand2240 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not140_o0,
			i1 => Xor2220_o0,
			o0 => Nand2240_o0
		);
		And2260 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Or2200_o0,
			i1 => Nand2240_o0,
			o0 => And2260_o0
		);
		Or2280 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2160_o0,
			i1 => And2260_o0,
			o0 => Or2280_o0
		);
		Xor2300 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Or2660_o0,
			i1 => i4,
			o0 => Xor2300_o0
		);
		Nand2320 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Xor2220_o0,
			o0 => Nand2320_o0
		);
		Or2340 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Xor2180_o0,
			o0 => Or2340_o0
		);
		Nand2360 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2320_o0,
			i1 => Or2340_o0,
			o0 => Nand2360_o0
		);
		Nand2380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor2300_o0,
			i1 => Nand2360_o0,
			o0 => Nand2380_o0
		);
		Nand2400 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or2280_o0,
			i1 => Nand2380_o0,
			o0 => Nand2400_o0
		);
		Or2660 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nor2680_o0,
			o0 => Or2660_o0
		);
		Nor2680 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => i1,
			o0 => Nor2680_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand2400_o0;
end netenos;
