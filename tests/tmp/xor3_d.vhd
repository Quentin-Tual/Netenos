--generated automatically
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity xor3_d is
		generic(delay : time := 1 ps);
		port(
				i0 : in  std_logic;
				i1 : in  std_logic;
				i2 : in  std_logic;
				o0 : out std_logic
		);
end xor3_d;
 
architecture rtl of xor3_d is
begin
		o0 <= i0 xor i1 xor i2 after delay;
end rtl;
