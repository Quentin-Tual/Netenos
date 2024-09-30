library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity circ_C17 is
	port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		o0 : out std_logic;
		o1 : out std_logic
	);
end circ_C17;
 
architecture netenos of circ_C17 is
	signal Nand2140_o0 : std_logic;
	signal And2160_o0 : std_logic;
	signal And2180_o0 : std_logic;
	signal Or2200_o0 : std_logic;
	signal And2220_o0 : std_logic;
	signal Or2240_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Nand2140 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => i3,
			i1 => i2,
			o0 => Nand2140_o0
		);
		And2160 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Nand2140_o0,
			i1 => i1,
			o0 => And2160_o0
		);
		And2180 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => i2,
			i1 => i0,
			o0 => And2180_o0
		);
		Or2200 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And2160_o0,
			i1 => And2180_o0,
			o0 => Or2200_o0
		);
		And2220 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Nand2140_o0,
			i1 => i4,
			o0 => And2220_o0
		);
		Or2240 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And2220_o0,
			i1 => And2160_o0,
			o0 => Or2240_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Or2200_o0;
	o1 <= Or2240_o0;
end netenos;
