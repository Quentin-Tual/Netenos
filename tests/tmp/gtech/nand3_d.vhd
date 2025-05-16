-- generated automatically

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nand3_d is
  generic(delay : time := 1000 fs);
  port (
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		o0 : out  std_logic
  );
end nand3_d;

architecture bhv of nand3_d is
begin
  o0 <= not(i0 and i1 and i2) after delay;
end architecture;