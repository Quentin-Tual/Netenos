-- generated automatically

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xor4_d is
  generic(delay : time := 1000 fs);
  port (
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		o0 : out  std_logic
  );
end xor4_d;

architecture bhv of xor4_d is
begin
  o0 <= i0 xor i1 xor i2 xor i3 after delay;
end architecture;