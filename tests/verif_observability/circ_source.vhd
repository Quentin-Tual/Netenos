library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;

use work.tunnel_pkg.all;
 
entity circ_source is
	port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		o0 : out std_logic
	);
end circ_source;
 
architecture netenos of circ_source is
	signal Not60_o0 : std_logic;
	signal Xor280_o0 : std_logic;
	signal Xor2100_o0 : std_logic;
	signal Or2120_o0 : std_logic;
	signal Xor2140_o0 : std_logic;
	signal Nand2160_o0 : std_logic;
	signal And2180_o0 : std_logic;
	signal Or2200_o0 : std_logic;
	signal Xor2220_o0 : std_logic;
	signal Nand2240_o0 : std_logic;
	signal Or2260_o0 : std_logic;
	signal Nand2280_o0 : std_logic;
	signal Nand2300_o0 : std_logic;
	signal Nand2320_o0 : std_logic;
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
		Xor280 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Xor280_o0
		);
		Xor2100 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => i1,
			i1 => i2,
			o0 => Xor2100_o0
		);
		Or2120 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Not60_o0,
			i1 => Xor2100_o0,
			o0 => Or2120_o0
		);
		Xor2140 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => i1,
			i1 => i2,
			o0 => Xor2140_o0
		);
		Nand2160 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Not60_o0,
			i1 => Xor2140_o0,
			o0 => Nand2160_o0
		);
		And2180 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Or2120_o0,
			i1 => Nand2160_o0,
			o0 => And2180_o0
		);
		Or2200 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Xor280_o0,
			i1 => And2180_o0,
			o0 => Or2200_o0
		);
		Xor2220 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Xor2220_o0
		);
		Nand2240 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => i0,
			i1 => Xor2140_o0,
			o0 => Nand2240_o0
		);
		Or2260 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i0,
			i1 => Xor2100_o0,
			o0 => Or2260_o0
		);
		Nand2280 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Nand2240_o0,
			i1 => Or2260_o0,
			o0 => Nand2280_o0
		);
		Nand2300 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Xor2220_o0,
			i1 => Nand2280_o0,
			o0 => Nand2300_o0
		);
		Nand2320 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Or2200_o0,
			i1 => Nand2300_o0,
			o0 => Nand2320_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nand2320_o0;
	
	----------------------------------
	-- Wiring probe signals 
	----------------------------------
	-- on output path signals
	probe_i3 <= i3;
	probe_Xor280_o0 <= Xor280_o0;
	probe_Xor2220_o0 <= Xor2220_o0;
	probe_Or2200_o0 <= Or2200_o0;
	probe_Nand2300_o0 <= Nand2300_o0;
	probe_Nand2320_o0 <= Nand2320_o0;
	-- side-inputs
	probe_And2180_o0 <= And2180_o0;
	probe_Nand2280_o0 <= Nand2280_o0;

end netenos;
