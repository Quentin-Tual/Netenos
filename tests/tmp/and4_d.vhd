--generated automatically
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity and4_d is
		generic(delay : time := 1 ps);
		port(
				i0 : in  std_logic;
				i1 : in  std_logic;
				i2 : in  std_logic;
				i3 : in  std_logic;
				o0 : out std_logic
		);
end and4_d;
 
architecture rtl of and4_d is
begin
		o0 <= i0 and i1 and i2 and i3 after delay;
end rtl;
