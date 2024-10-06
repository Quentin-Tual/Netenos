--generated automatically
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity buffer_d is
		generic(delay : time := 1 ps);
		port(
				i0 : in  std_logic;
				o0 : out std_logic
		);
end buffer_d;
 
architecture rtl of buffer_d is
begin
		o0 <=  i0 after delay;
end rtl;
