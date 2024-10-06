library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity rand_0_altered is
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
		o3 : out std_logic;
		o4 : out std_logic
	);
end rand_0_altered;
 
architecture netenos of rand_0_altered is
	signal And213580_o0 : std_logic;
	signal Nand213600_o0 : std_logic;
	signal Not13620_o0 : std_logic;
	signal Not13640_o0 : std_logic;
	signal Nor213660_o0 : std_logic;
	signal Nor213680_o0 : std_logic;
	signal Not13700_o0 : std_logic;
	signal Nor213720_o0 : std_logic;
	signal Not13740_o0 : std_logic;
	signal Xor213760_o0 : std_logic;
	signal Not13780_o0 : std_logic;
	signal Nor213800_o0 : std_logic;
	signal Or213820_o0 : std_logic;
	signal And213840_o0 : std_logic;
	signal Xor213860_o0 : std_logic;
	signal Xor213880_o0 : std_logic;
	signal Or213900_o0 : std_logic;
	signal Nor213920_o0 : std_logic;
	signal Xor213940_o0 : std_logic;
	signal And213960_o0 : std_logic;
	signal Nand213980_o0 : std_logic;
	signal Xor214000_o0 : std_logic;
	signal Xor214020_o0 : std_logic;
	signal Nand214040_o0 : std_logic;
	signal Nand214060_o0 : std_logic;
	signal Xor214080_o0 : std_logic;
	signal Or214100_o0 : std_logic;
	signal Nand214120_o0 : std_logic;
	signal Nand214140_o0 : std_logic;
	signal Nor214160_o0 : std_logic;
	signal Nor214180_o0 : std_logic;
	signal And214200_o0 : std_logic;
	signal Nand214220_o0 : std_logic;
	signal Or214240_o0 : std_logic;
	signal Nand214260_o0 : std_logic;
	signal And214280_o0 : std_logic;
	signal Not14300_o0 : std_logic;
	signal Or214320_o0 : std_logic;
	signal Nor214340_o0 : std_logic;
	signal Nor214360_o0 : std_logic;
	signal Nand214380_o0 : std_logic;
	signal Nand214400_o0 : std_logic;
	signal Nor214420_o0 : std_logic;
	signal Nor214440_o0 : std_logic;
	signal Not14460_o0 : std_logic;
	signal And214480_o0 : std_logic;
	signal Nand214500_o0 : std_logic;
	signal And214520_o0 : std_logic;
	signal Nor214540_o0 : std_logic;
	signal Or214560_o0 : std_logic;
	signal Nand214580_o0 : std_logic;
	signal Nand214600_o0 : std_logic;
	signal Or214620_o0 : std_logic;
	signal Xor214640_o0 : std_logic;
	signal Not14660_o0 : std_logic;
	signal Nand214680_o0 : std_logic;
	signal Xor214700_o0 : std_logic;
	signal Not14720_o0 : std_logic;
	signal Not14740_o0 : std_logic;
	signal Not14760_o0 : std_logic;
	signal Nor214780_o0 : std_logic;
	signal Not14800_o0 : std_logic;
	signal Or214820_o0 : std_logic;
	signal Not14840_o0 : std_logic;
	signal Not14860_o0 : std_logic;
	signal Nand214880_o0 : std_logic;
	signal Not14900_o0 : std_logic;
	signal Not14920_o0 : std_logic;
	signal Nand214940_o0 : std_logic;
	signal Or214960_o0 : std_logic;
	signal Not14980_o0 : std_logic;
	signal Nand215000_o0 : std_logic;
	signal Nand215020_o0 : std_logic;
	signal Nor215040_o0 : std_logic;
	signal Xor215060_o0 : std_logic;
	signal Or21760_o0 : std_logic;
	signal Nor21780_o0 : std_logic;
begin
	----------------------------------
	-- Components interconnect 
	----------------------------------
	And213580 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i2,
			o0 => And213580_o0
		);
		Nand213600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i7,
			i1 => i5,
			o0 => Nand213600_o0
		);
		Not13620 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			o0 => Not13620_o0
		);
		Not13640 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			o0 => Not13640_o0
		);
		Nor213660 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => i0,
			o0 => Nor213660_o0
		);
		Nor213680 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not13640_o0,
			i1 => Nor213660_o0,
			o0 => Nor213680_o0
		);
		Not13700 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand213600_o0,
			o0 => Not13700_o0
		);
		Nor213720 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not13620_o0,
			i1 => And213580_o0,
			o0 => Nor213720_o0
		);
		Not13740 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor213660_o0,
			o0 => Not13740_o0
		);
		Xor213760 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Not13620_o0,
			i1 => i2,
			o0 => Xor213760_o0
		);
		Not13780 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not13700_o0,
			o0 => Not13780_o0
		);
		Nor213800 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not13740_o0,
			i1 => Xor213760_o0,
			o0 => Nor213800_o0
		);
		Or213820 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nor213720_o0,
			i1 => Nor213680_o0,
			o0 => Or213820_o0
		);
		And213840 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			i1 => Xor213760_o0,
			o0 => And213840_o0
		);
		Xor213860 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand213600_o0,
			i1 => i7,
			o0 => Xor213860_o0
		);
		Xor213880 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Or213820_o0,
			i1 => And213840_o0,
			o0 => Xor213880_o0
		);
		Or213900 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Nor213800_o0,
			i1 => Not13780_o0,
			o0 => Or213900_o0
		);
		Nor213920 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor213860_o0,
			i1 => i0,
			o0 => Nor213920_o0
		);
		Xor213940 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And213580_o0,
			i1 => Not13640_o0,
			o0 => Xor213940_o0
		);
		And213960 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Xor213860_o0,
			i1 => Not13740_o0,
			o0 => And213960_o0
		);
		Nand213980 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or213900_o0,
			i1 => Nor213920_o0,
			o0 => Nand213980_o0
		);
		Xor214000 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => And213960_o0,
			i1 => Xor213880_o0,
			o0 => Xor214000_o0
		);
		Xor214020 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor213940_o0,
			i1 => Not13780_o0,
			o0 => Xor214020_o0
		);
		Nand214040 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor213660_o0,
			i1 => Not13620_o0,
			o0 => Nand214040_o0
		);
		Nand214060 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor213920_o0,
			i1 => Or213820_o0,
			o0 => Nand214060_o0
		);
		Xor214080 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand213980_o0,
			i1 => Nand214040_o0,
			o0 => Xor214080_o0
		);
		Or214100 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor214000_o0,
			i1 => Nand214060_o0,
			o0 => Or214100_o0
		);
		Nand214120 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor214020_o0,
			i1 => i3,
			o0 => Nand214120_o0
		);
		Nand214140 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => i6,
			i1 => Not13700_o0,
			o0 => Nand214140_o0
		);
		Nor214160 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => And213960_o0,
			i1 => Xor214020_o0,
			o0 => Nor214160_o0
		);
		Nor214180 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand214140_o0,
			i1 => Nor214160_o0,
			o0 => Nor214180_o0
		);
		And214200 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand214120_o0,
			i1 => Or214100_o0,
			o0 => And214200_o0
		);
		Nand214220 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Xor214080_o0,
			i1 => Nor213680_o0,
			o0 => Nand214220_o0
		);
		Or214240 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i4,
			i1 => i5,
			o0 => Or214240_o0
		);
		Nand214260 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand213980_o0,
			i1 => Nor213720_o0,
			o0 => Nand214260_o0
		);
		And214280 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand214260_o0,
			i1 => Nor214180_o0,
			o0 => And214280_o0
		);
		Not14300 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or214240_o0,
			o0 => Not14300_o0
		);
		Or214320 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => And214200_o0,
			i1 => Nand214220_o0,
			o0 => Or214320_o0
		);
		Nor214340 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => And213840_o0,
			i1 => Xor214080_o0,
			o0 => Nor214340_o0
		);
		Nor214360 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nor214180_o0,
			i1 => Nor214160_o0,
			o0 => Nor214360_o0
		);
		Nand214380 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor214340_o0,
			i1 => And214280_o0,
			o0 => Nand214380_o0
		);
		Nand214400 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor214360_o0,
			i1 => Or214320_o0,
			o0 => Nand214400_o0
		);
		Nor214420 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not14300_o0,
			i1 => Nand214120_o0,
			o0 => Nor214420_o0
		);
		Nor214440 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Nor213680_o0,
			i1 => Or21760_o0,
			o0 => Nor214440_o0
		);
		Not14460 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor213800_o0,
			o0 => Not14460_o0
		);
		And214480 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nand214400_o0,
			i1 => Nand214380_o0,
			o0 => And214480_o0
		);
		Nand214500 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor214440_o0,
			i1 => Not14460_o0,
			o0 => Nand214500_o0
		);
		And214520 : entity gtech_lib.and2_d
		generic map(1000 fs)
		port map(
			i0 => Nor214420_o0,
			i1 => Nand214400_o0,
			o0 => And214520_o0
		);
		Nor214540 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not13780_o0,
			i1 => And213580_o0,
			o0 => Nor214540_o0
		);
		Or214560 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor213940_o0,
			i1 => Not14460_o0,
			o0 => Or214560_o0
		);
		Nand214580 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand214500_o0,
			i1 => Or214560_o0,
			o0 => Nand214580_o0
		);
		Nand214600 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nor214540_o0,
			i1 => And214520_o0,
			o0 => Nand214600_o0
		);
		Or214620 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => And214480_o0,
			i1 => And214480_o0,
			o0 => Or214620_o0
		);
		Xor214640 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => i3,
			i1 => Nor214420_o0,
			o0 => Xor214640_o0
		);
		Not14660 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand214040_o0,
			o0 => Not14660_o0
		);
		Nand214680 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Nand214580_o0,
			i1 => Not14660_o0,
			o0 => Nand214680_o0
		);
		Xor214700 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Nand214600_o0,
			i1 => Xor214640_o0,
			o0 => Xor214700_o0
		);
		Not14720 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or214620_o0,
			o0 => Not14720_o0
		);
		Not14740 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => i1,
			o0 => Not14740_o0
		);
		Not14760 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nand214060_o0,
			o0 => Not14760_o0
		);
		Nor214780 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Not14720_o0,
			i1 => Nand214680_o0,
			o0 => Nor214780_o0
		);
		Not14800 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not14760_o0,
			o0 => Not14800_o0
		);
		Or214820 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Xor214700_o0,
			i1 => Not14740_o0,
			o0 => Or214820_o0
		);
		Not14840 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor214540_o0,
			o0 => Not14840_o0
		);
		Not14860 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Xor214000_o0,
			o0 => Not14860_o0
		);
		Nand214880 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not14800_o0,
			i1 => Not14860_o0,
			o0 => Nand214880_o0
		);
		Not14900 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Not14840_o0,
			o0 => Not14900_o0
		);
		Not14920 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Nor214780_o0,
			o0 => Not14920_o0
		);
		Nand214940 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Or214820_o0,
			i1 => Not13640_o0,
			o0 => Nand214940_o0
		);
		Or214960 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => i0,
			i1 => Xor214640_o0,
			o0 => Or214960_o0
		);
		Not14980 : entity gtech_lib.not_d
		generic map(1000 fs)
		port map(
			i0 => Or214960_o0,
			o0 => Not14980_o0
		);
		Nand215000 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not14900_o0,
			i1 => Nand214940_o0,
			o0 => Nand215000_o0
		);
		Nand215020 : entity gtech_lib.nand2_d
		generic map(1000 fs)
		port map(
			i0 => Not14920_o0,
			i1 => Nand214880_o0,
			o0 => Nand215020_o0
		);
		Nor215040 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => Xor213880_o0,
			i1 => Nand213600_o0,
			o0 => Nor215040_o0
		);
		Xor215060 : entity gtech_lib.xor2_d
		generic map(1000 fs)
		port map(
			i0 => Or214960_o0,
			i1 => Xor213860_o0,
			o0 => Xor215060_o0
		);
		Or21760 : entity gtech_lib.or2_d
		generic map(1000 fs)
		port map(
			i0 => Or214100_o0,
			i1 => Nor21780_o0,
			o0 => Or21760_o0
		);
		Nor21780 : entity gtech_lib.nor2_d
		generic map(1000 fs)
		port map(
			i0 => i5,
			i1 => i4,
			o0 => Nor21780_o0
		);
	----------------------------------
	-- Wiring primary ouputs 
	----------------------------------
	o0 <= Xor215060_o0;
	o1 <= Nor215040_o0;
	o2 <= Nand215020_o0;
	o3 <= Not14980_o0;
	o4 <= Nand215000_o0;
end netenos;
