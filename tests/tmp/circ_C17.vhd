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
	signal Nand260_o0 : std_logic;
	signal Nand280_o0 : std_logic;
	signal Nand2100_o0 : std_logic;
	signal Nand2120_o0 : std_logic;
	signal Nand2140_o0 : std_logic;
	signal Nand2160_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Nand260 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => i2,
			o0 => Nand260_o0
		);
		Nand280 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i2,
			i1 => i3,
			o0 => Nand280_o0
		);
		Nand2100 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Nand280_o0,
			o0 => Nand2100_o0
		);
		Nand2120 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand260_o0,
			i1 => Nand2100_o0,
			o0 => Nand2120_o0
		);
		Nand2140 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => Nand280_o0,
			o0 => Nand2140_o0
		);
		Nand2160 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand2100_o0,
			i1 => Nand2140_o0,
			o0 => Nand2160_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand2120_o0;
	o1 <= Nand2160_o0;
end netenos;
