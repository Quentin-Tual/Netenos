library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity rand_140 is
	port(
		i0 : in  std_logic;
		i1 : in  std_logic;
		i2 : in  std_logic;
		i3 : in  std_logic;
		i4 : in  std_logic;
		i5 : in  std_logic;
		i6 : in  std_logic;
		i7 : in  std_logic;
		o0 : out std_logic;
		o1 : out std_logic;
		o2 : out std_logic;
		o3 : out std_logic
	);
end rand_140;
 
architecture netenos of rand_140 is
	signal Nand22100_o0 : std_logic;
	signal And22120_o0 : std_logic;
	signal Or22140_o0 : std_logic;
	signal And22160_o0 : std_logic;
	signal Xor22180_o0 : std_logic;
	signal Xor22200_o0 : std_logic;
	signal Nand22220_o0 : std_logic;
	signal Not2240_o0 : std_logic;
	signal Not2260_o0 : std_logic;
	signal Nand22280_o0 : std_logic;
	signal Nor22300_o0 : std_logic;
	signal Xor22320_o0 : std_logic;
	signal Not2340_o0 : std_logic;
	signal Nor22360_o0 : std_logic;
	signal Xor22380_o0 : std_logic;
	signal Or22400_o0 : std_logic;
	signal Nand22420_o0 : std_logic;
	signal Not2440_o0 : std_logic;
	signal Or22460_o0 : std_logic;
	signal Not2480_o0 : std_logic;
	signal Nand22500_o0 : std_logic;
	signal Or22520_o0 : std_logic;
	signal And22540_o0 : std_logic;
	signal Nand22560_o0 : std_logic;
	signal Or22580_o0 : std_logic;
	signal Xor22600_o0 : std_logic;
	signal Not2620_o0 : std_logic;
	signal Not2640_o0 : std_logic;
	signal Nor22660_o0 : std_logic;
	signal Nor22680_o0 : std_logic;
	signal Not2700_o0 : std_logic;
	signal Nand22720_o0 : std_logic;
	signal Or22740_o0 : std_logic;
	signal Nand22760_o0 : std_logic;
	signal Not2780_o0 : std_logic;
	signal Not2800_o0 : std_logic;
	signal Xor22820_o0 : std_logic;
	signal Not2840_o0 : std_logic;
	signal Not2860_o0 : std_logic;
	signal And22880_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Nand22100 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => i6,
			i1 => i4,
			o0 => Nand22100_o0
		);
		And22120 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => i7,
			i1 => i3,
			o0 => And22120_o0
		);
		Or22140 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i0,
			i1 => i5,
			o0 => Or22140_o0
		);
		And22160 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => i1,
			i1 => i2,
			o0 => And22160_o0
		);
		Xor22180 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Nand22100_o0,
			i1 => Or22140_o0,
			o0 => Xor22180_o0
		);
		Xor22200 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => And22160_o0,
			i1 => And22120_o0,
			o0 => Xor22200_o0
		);
		Nand22220 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Or22140_o0,
			i1 => i6,
			o0 => Nand22220_o0
		);
		Not2240 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand22100_o0,
			o0 => Not2240_o0
		);
		Not2260 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not2240_o0,
			o0 => Not2260_o0
		);
		Nand22280 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Xor22200_o0,
			i1 => Xor22180_o0,
			o0 => Nand22280_o0
		);
		Nor22300 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nand22220_o0,
			i1 => And22120_o0,
			o0 => Nor22300_o0
		);
		Xor22320 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => And22160_o0,
			i1 => And22120_o0,
			o0 => Xor22320_o0
		);
		Not2340 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not2260_o0,
			o0 => Not2340_o0
		);
		Nor22360 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor22300_o0,
			i1 => Nand22280_o0,
			o0 => Nor22360_o0
		);
		Xor22380 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Xor22320_o0,
			i1 => i1,
			o0 => Xor22380_o0
		);
		Or22400 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Xor22200_o0,
			i1 => i4,
			o0 => Or22400_o0
		);
		Nand22420 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Not2340_o0,
			i1 => Or22400_o0,
			o0 => Nand22420_o0
		);
		Not2440 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Xor22380_o0,
			o0 => Not2440_o0
		);
		Or22460 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Nor22360_o0,
			i1 => i7,
			o0 => Or22460_o0
		);
		Not2480 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not2240_o0,
			o0 => Not2480_o0
		);
		Nand22500 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Not2480_o0,
			i1 => Or22460_o0,
			o0 => Nand22500_o0
		);
		Or22520 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Not2440_o0,
			i1 => Nand22420_o0,
			o0 => Or22520_o0
		);
		And22540 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Nand22100_o0,
			i1 => i0,
			o0 => And22540_o0
		);
		Nand22560 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Or22140_o0,
			i1 => Not2260_o0,
			o0 => Nand22560_o0
		);
		Or22580 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Or22520_o0,
			i1 => Nand22500_o0,
			o0 => Or22580_o0
		);
		Xor22600 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => And22540_o0,
			i1 => Nand22560_o0,
			o0 => Xor22600_o0
		);
		Not2620 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Xor22320_o0,
			o0 => Not2620_o0
		);
		Not2640 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand22500_o0,
			o0 => Not2640_o0
		);
		Nor22660 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Not2640_o0,
			i1 => Xor22600_o0,
			o0 => Nor22660_o0
		);
		Nor22680 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Or22580_o0,
			i1 => Not2620_o0,
			o0 => Nor22680_o0
		);
		Not2700 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			o0 => Not2700_o0
		);
		Nand22720 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => And22160_o0,
			i1 => i2,
			o0 => Nand22720_o0
		);
		Or22740 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Not2700_o0,
			i1 => Nor22680_o0,
			o0 => Or22740_o0
		);
		Nand22760 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Nor22660_o0,
			i1 => Nand22720_o0,
			o0 => Nand22760_o0
		);
		Not2780 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand22420_o0,
			o0 => Not2780_o0
		);
		Not2800 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand22220_o0,
			o0 => Not2800_o0
		);
		Xor22820 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Not2800_o0,
			i1 => Or22740_o0,
			o0 => Xor22820_o0
		);
		Not2840 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand22760_o0,
			o0 => Not2840_o0
		);
		Not2860 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not2780_o0,
			o0 => Not2860_o0
		);
		And22880 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => And22120_o0,
			i1 => i3,
			o0 => And22880_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Not2840_o0;
	o1 <= Not2860_o0;
	o2 <= And22880_o0;
	o3 <= Xor22820_o0;
end netenos;
