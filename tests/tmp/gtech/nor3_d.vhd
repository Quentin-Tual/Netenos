-- generated automatically

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nor3_d is
  generic(delay : time := 1000 fs);
  port (
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		o0 : out  std_logic
  );
end nor3_d;

architecture bhv of nor3_d is
begin
  o0 <= not(i0 or i1 or i2) after delay;
end architecture;