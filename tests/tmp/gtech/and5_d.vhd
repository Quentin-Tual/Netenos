-- generated automatically

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity and5_d is
  generic(delay : time := 1000 fs);
  port (
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		o0 : out  std_logic
  );
end and5_d;

architecture bhv of and5_d is
begin
  o0 <= i0 and i1 and i2 and i3 and i4 after delay;
end architecture;