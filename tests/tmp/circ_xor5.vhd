library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library gtech_lib;

entity circ_xor5 is
port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		o0 : out  std_logic
);
end circ_xor5;

architecture netenos of circ_xor5 is
	signal Not60_o0 : std_logic;
	signal Xor280_o0 : std_logic;
	signal Not100_o0 : std_logic;
	signal Xor2120_o0 : std_logic;
	signal Nor2140_o0 : std_logic;
	signal Xor2160_o0 : std_logic;
	signal And2180_o0 : std_logic;
	signal Or2200_o0 : std_logic;
	signal And2220_o0 : std_logic;
	signal Xor2240_o0 : std_logic;
	signal And2260_o0 : std_logic;
	signal Nor2280_o0 : std_logic;
	signal Or2300_o0 : std_logic;
	signal And2320_o0 : std_logic;
	signal Or2340_o0 : std_logic;
begin 
  
  ----------------------------------
  -- Components interconnect
  ----------------------------------
  Not60 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => i3,
			o0 => Not60_o0
		);
		Xor280 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => i4,
			i1 => Not60_o0,
			o0 => Xor280_o0
		);
		Not100 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => i0,
			o0 => Not100_o0
		);
		Xor2120 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => i2,
			i1 => i1,
			o0 => Xor2120_o0
		);
		Nor2140 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Xor2120_o0,
			i1 => Not100_o0,
			o0 => Nor2140_o0
		);
		Xor2160 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => i2,
			i1 => i1,
			o0 => Xor2160_o0
		);
		And2180 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Xor2160_o0,
			i1 => Not100_o0,
			o0 => And2180_o0
		);
		Or2200 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => And2180_o0,
			i1 => Nor2140_o0,
			o0 => Or2200_o0
		);
		And2220 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Or2200_o0,
			i1 => Xor280_o0,
			o0 => And2220_o0
		);
		Xor2240 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => i4,
			i1 => i3,
			o0 => Xor2240_o0
		);
		And2260 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Xor2160_o0,
			i1 => i0,
			o0 => And2260_o0
		);
		Nor2280 : entity gtech_lib.nor2_d
		generic map(4000 fs)
		port map(
			i0 => Xor2120_o0,
			i1 => i0,
			o0 => Nor2280_o0
		);
		Or2300 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => Nor2280_o0,
			i1 => And2260_o0,
			o0 => Or2300_o0
		);
		And2320 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Or2300_o0,
			i1 => Xor2240_o0,
			o0 => And2320_o0
		);
		Or2340 : entity gtech_lib.or2_d
		generic map(3000 fs)
		port map(
			i0 => And2320_o0,
			i1 => And2220_o0,
			o0 => Or2340_o0
		);

  ----------------------------------
  -- Wiring primary ouputs 
  ----------------------------------
  o0 <= Or2340_o0;

end architecture;