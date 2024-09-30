library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity rand_60 is
	port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		i5 : in  std_logic;
		o0 : out std_logic;
		o1 : out std_logic;
		o2 : out std_logic;
		o3 : out std_logic
	);
end rand_60;
 
architecture netenos of rand_60 is
	signal Or21880_o0 : std_logic;
	signal Or21900_o0 : std_logic;
	signal Or21920_o0 : std_logic;
	signal Not1940_o0 : std_logic;
	signal Nor21960_o0 : std_logic;
	signal Or21980_o0 : std_logic;
	signal Not2000_o0 : std_logic;
	signal Nor22020_o0 : std_logic;
	signal Xor22040_o0 : std_logic;
	signal Nor22060_o0 : std_logic;
	signal Nand22080_o0 : std_logic;
	signal And22100_o0 : std_logic;
	signal And22120_o0 : std_logic;
	signal Nor22140_o0 : std_logic;
	signal Not2160_o0 : std_logic;
	signal And22180_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Or21880 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i0,
			i1 => i5,
			o0 => Or21880_o0
		);
		Or21900 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i1,
			i1 => i3,
			o0 => Or21900_o0
		);
		Or21920 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i2,
			i1 => i4,
			o0 => Or21920_o0
		);
		Not1940 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			o0 => Not1940_o0
		);
		Nor21960 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Or21880_o0,
			i1 => Not1940_o0,
			o0 => Nor21960_o0
		);
		Or21980 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Or21920_o0,
			i1 => Or21900_o0,
			o0 => Or21980_o0
		);
		Not2000 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			o0 => Not2000_o0
		);
		Nor22020 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => i2,
			i1 => i1,
			o0 => Nor22020_o0
		);
		Xor22040 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Or21980_o0,
			i1 => Nor21960_o0,
			o0 => Xor22040_o0
		);
		Nor22060 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor22020_o0,
			i1 => Not2000_o0,
			o0 => Nor22060_o0
		);
		Nand22080 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => i5,
			i1 => i4,
			o0 => Nand22080_o0
		);
		And22100 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => i2,
			i1 => Or21880_o0,
			o0 => And22100_o0
		);
		And22120 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Xor22040_o0,
			i1 => Nand22080_o0,
			o0 => And22120_o0
		);
		Nor22140 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => And22100_o0,
			i1 => Nor22060_o0,
			o0 => Nor22140_o0
		);
		Not2160 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or21920_o0,
			o0 => Not2160_o0
		);
		And22180 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Not1940_o0,
			i1 => Or21980_o0,
			o0 => And22180_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= And22120_o0;
	o1 <= Not2160_o0;
	o2 <= Nor22140_o0;
	o3 <= And22180_o0;
end netenos;
