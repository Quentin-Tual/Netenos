-- generated automatically

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity or3_d is
  generic(delay : time := 1000 fs);
  port (
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		o0 : out  std_logic
  );
end or3_d;

architecture bhv of or3_d is
begin
  o0 <= i0 or i1 or i2 after delay;
end architecture;