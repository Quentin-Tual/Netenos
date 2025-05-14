--generated automatically
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity nor5_d is
		generic(delay : time := 1 ps);
		port(
				i0 : in  std_logic;
				i1 : in  std_logic;
				i2 : in  std_logic;
				i3 : in  std_logic;
				i4 : in  std_logic;
				o0 : out std_logic
		);
end nor5_d;
 
architecture rtl of nor5_d is
begin
		o0 <= not i0 or i1 or i2 or i3 or i4 after delay;
end rtl;
