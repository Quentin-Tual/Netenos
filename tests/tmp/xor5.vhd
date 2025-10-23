library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library gtech_lib;

entity xor5 is
port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		o0 : out  std_logic
);
end xor5;

architecture netenos of xor5 is
	signal _0_ : std_logic;
	signal _1_ : std_logic;
	signal _2_ : std_logic;
	signal i0 : std_logic;
	signal i1 : std_logic;
	signal i2 : std_logic;
	signal i3 : std_logic;
	signal i4 : std_logic;
	signal o0 : std_logic;
	signal _3__o0 : std_logic;
	signal _4__o0 : std_logic;
	signal _5__o0 : std_logic;
	signal _6__o0 : std_logic;
begin 
  
  ----------------------------------
  -- Components interconnect
  ----------------------------------
  _3_ : entity gtech_lib.sky130_fd_sc_hd__xor2_2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => i2,
			o0 => _0_
		);
		_4_ : entity gtech_lib.sky130_fd_sc_hd__xor2_2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => i3,
			o0 => _1_
		);
		_5_ : entity gtech_lib.sky130_fd_sc_hd__xnor2_2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => _1_,
			o0 => _2_
		);
		_6_ : entity gtech_lib.sky130_fd_sc_hd__xnor2_2_d
		generic map(1000 fs)
		port map(
			i0 => _0_,
			i1 => _2_,
			o0 => o0
		);

  ----------------------------------
  -- Wiring primary ouputs 
  ----------------------------------
  o0 <= o0;

end architecture;