--generated automatically
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity nand2_d is
		generic(delay : time := 1 ps);
		port(
				i0 : in  std_logic;
				i1 : in  std_logic;
				o0 : out std_logic
		);
end nand2_d;
 
architecture rtl of nand2_d is
begin
		o0 <=  i0 nand i1 after delay;
end rtl;
