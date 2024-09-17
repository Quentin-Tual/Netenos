library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity test is
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
end test;
 
architecture netenos of test is
	signal Or236260_o0 : std_logic;
	signal Or236280_o0 : std_logic;
	signal Or236300_o0 : std_logic;
	signal Xor236320_o0 : std_logic;
	signal Nor236340_o0 : std_logic;
	signal Xor236360_o0 : std_logic;
	signal And236380_o0 : std_logic;
	signal Nor236400_o0 : std_logic;
	signal Xor236420_o0 : std_logic;
	signal Nor236440_o0 : std_logic;
	signal Xor236460_o0 : std_logic;
	signal Nand236480_o0 : std_logic;
	signal Not36500_o0 : std_logic;
	signal And236520_o0 : std_logic;
	signal Nor236540_o0 : std_logic;
	signal Nor236560_o0 : std_logic;
	signal Nor236580_o0 : std_logic;
	signal Or236600_o0 : std_logic;
	signal Not36620_o0 : std_logic;
	signal Nor236640_o0 : std_logic;
	signal Or236660_o0 : std_logic;
	signal Xor236680_o0 : std_logic;
	signal And236700_o0 : std_logic;
	signal Nor236720_o0 : std_logic;
	signal Nor236740_o0 : std_logic;
	signal Or236760_o0 : std_logic;
	signal Nor236780_o0 : std_logic;
	signal Xor236800_o0 : std_logic;
	signal Or236820_o0 : std_logic;
	signal Nand236840_o0 : std_logic;
	signal And236860_o0 : std_logic;
	signal Nor236880_o0 : std_logic;
	signal Nor236900_o0 : std_logic;
	signal Nor236920_o0 : std_logic;
	signal Nand236940_o0 : std_logic;
	signal Or236960_o0 : std_logic;
	signal Not36980_o0 : std_logic;
	signal Nor237000_o0 : std_logic;
	signal Nor237020_o0 : std_logic;
	signal And237040_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	Or236260 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i2,
			i1 => i1,
			o0 => Or236260_o0
		);
		Or236280 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i4,
			i1 => i3,
			o0 => Or236280_o0
		);
		Or236300 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => i0,
			i1 => i5,
			o0 => Or236300_o0
		);
		Xor236320 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => i3,
			i1 => i4,
			o0 => Xor236320_o0
		);
		Nor236340 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Or236280_o0,
			i1 => Or236300_o0,
			o0 => Nor236340_o0
		);
		Xor236360 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Xor236320_o0,
			i1 => Or236260_o0,
			o0 => Xor236360_o0
		);
		And236380 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => i5,
			i1 => i2,
			o0 => And236380_o0
		);
		Nor236400 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Or236260_o0,
			i1 => i0,
			o0 => Nor236400_o0
		);
		Xor236420 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Xor236360_o0,
			i1 => Nor236400_o0,
			o0 => Xor236420_o0
		);
		Nor236440 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236340_o0,
			i1 => And236380_o0,
			o0 => Nor236440_o0
		);
		Xor236460 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => i1,
			i1 => i3,
			o0 => Xor236460_o0
		);
		Nand236480 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Or236280_o0,
			i1 => Nor236400_o0,
			o0 => Nand236480_o0
		);
		Not36500 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor236440_o0,
			o0 => Not36500_o0
		);
		And236520 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Xor236460_o0,
			i1 => Xor236420_o0,
			o0 => And236520_o0
		);
		Nor236540 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nand236480_o0,
			i1 => Nand236480_o0,
			o0 => Nor236540_o0
		);
		Nor236560 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236340_o0,
			i1 => Xor236320_o0,
			o0 => Nor236560_o0
		);
		Nor236580 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236540_o0,
			i1 => Not36500_o0,
			o0 => Nor236580_o0
		);
		Or236600 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Nor236560_o0,
			i1 => And236520_o0,
			o0 => Or236600_o0
		);
		Not36620 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor236540_o0,
			o0 => Not36620_o0
		);
		Nor236640 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Xor236460_o0,
			i1 => i1,
			o0 => Nor236640_o0
		);
		Or236660 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Nor236640_o0,
			i1 => Not36620_o0,
			o0 => Or236660_o0
		);
		Xor236680 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Nor236580_o0,
			i1 => Or236600_o0,
			o0 => Xor236680_o0
		);
		And236700 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Xor236420_o0,
			i1 => Not36620_o0,
			o0 => And236700_o0
		);
		Nor236720 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Or236600_o0,
			i1 => Or236300_o0,
			o0 => Nor236720_o0
		);
		Nor236740 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Xor236680_o0,
			i1 => Or236660_o0,
			o0 => Nor236740_o0
		);
		Or236760 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And236700_o0,
			i1 => Nor236720_o0,
			o0 => Or236760_o0
		);
		Nor236780 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236580_o0,
			i1 => Nor236440_o0,
			o0 => Nor236780_o0
		);
		Xor236800 : entity gtech_lib.xor2_d
		generic map(2500 fs)
		port map(
			i0 => Nor236560_o0,
			i1 => Nand236480_o0,
			o0 => Xor236800_o0
		);
		Or236820 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => Xor236800_o0,
			i1 => Nor236780_o0,
			o0 => Or236820_o0
		);
		Nand236840 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236740_o0,
			i1 => Or236760_o0,
			o0 => Nand236840_o0
		);
		And236860 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Xor236320_o0,
			i1 => Nor236640_o0,
			o0 => And236860_o0
		);
		Nor236880 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236580_o0,
			i1 => Nor236440_o0,
			o0 => Nor236880_o0
		);
		Nor236900 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => And236860_o0,
			i1 => Or236820_o0,
			o0 => Nor236900_o0
		);
		Nor236920 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236880_o0,
			i1 => Nand236840_o0,
			o0 => Nor236920_o0
		);
		Nand236940 : entity gtech_lib.nand2_d
		generic map(2000 fs)
		port map(
			i0 => Xor236420_o0,
			i1 => Or236600_o0,
			o0 => Nand236940_o0
		);
		Or236960 : entity gtech_lib.or2_d
		generic map(1500 fs)
		port map(
			i0 => And236380_o0,
			i1 => Nor236640_o0,
			o0 => Or236960_o0
		);
		Not36980 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or236960_o0,
			o0 => Not36980_o0
		);
		Nor237000 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nand236940_o0,
			i1 => Nor236900_o0,
			o0 => Nor237000_o0
		);
		Nor237020 : entity gtech_lib.nor2_d
		generic map(2000 fs)
		port map(
			i0 => Nor236920_o0,
			i1 => Or236820_o0,
			o0 => Nor237020_o0
		);
		And237040 : entity gtech_lib.and2_d
		generic map(1500 fs)
		port map(
			i0 => Or236260_o0,
			i1 => And236700_o0,
			o0 => And237040_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Nor237020_o0;
	o1 <= And237040_o0;
	o2 <= Not36980_o0;
	o3 <= Nor237000_o0;
end netenos;
