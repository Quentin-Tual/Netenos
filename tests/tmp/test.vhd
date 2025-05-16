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
		i6 : in  std_logic;
		i7 : in  std_logic;
		o0 : out  std_logic;
		o1 : out  std_logic;
		o2 : out  std_logic;
		o3 : out  std_logic
);
end test;

architecture bhv of test is
	signal Nor5540_o0 : std_logic;
	signal Nand5560_o0 : std_logic;
	signal Nor5580_o0 : std_logic;
	signal Nand3600_o0 : std_logic;
	signal Nor5620_o0 : std_logic;
	signal Or5640_o0 : std_logic;
	signal Or5660_o0 : std_logic;
	signal Nand2680_o0 : std_logic;
	signal Nand4700_o0 : std_logic;
	signal Xor4720_o0 : std_logic;
	signal Or5740_o0 : std_logic;
	signal Xor2760_o0 : std_logic;
	signal Nand5780_o0 : std_logic;
	signal Xor3800_o0 : std_logic;
	signal Or5820_o0 : std_logic;
	signal Nand3840_o0 : std_logic;
	signal And2860_o0 : std_logic;
	signal Nand3880_o0 : std_logic;
	signal Xor3900_o0 : std_logic;
	signal Nand4920_o0 : std_logic;
	signal Not940_o0 : std_logic;
	signal Nor3960_o0 : std_logic;
	signal Xor5980_o0 : std_logic;
	signal Xor21000_o0 : std_logic;
	signal Xor51020_o0 : std_logic;
	signal Nand51040_o0 : std_logic;
	signal Nor31060_o0 : std_logic;
	signal Buffer1080_o0 : std_logic;
	signal Xor31100_o0 : std_logic;
begin 
  
  ----------------------------------
  -- Components interconnect
  ----------------------------------
  Nor5540 : entity gtech_lib.nor5_d
		generic map(7000 fs)
		port map(
			i0 => i1,
			i1 => i0,
			i2 => i3,
			i3 => i4,
			i4 => i2,
			o0 => Nor5540_o0
		);
		Nand5560 : entity gtech_lib.nand5_d
		generic map(7000 fs)
		port map(
			i0 => i5,
			i1 => i7,
			i2 => i6,
			i3 => i0,
			i4 => i1,
			o0 => Nand5560_o0
		);
		Nor5580 : entity gtech_lib.nor5_d
		generic map(7000 fs)
		port map(
			i0 => i7,
			i1 => i3,
			i2 => i6,
			i3 => i2,
			i4 => i5,
			o0 => Nor5580_o0
		);
		Nand3600 : entity gtech_lib.nand3_d
		generic map(5000 fs)
		port map(
			i0 => i4,
			i1 => i3,
			i2 => i0,
			o0 => Nand3600_o0
		);
		Nor5620 : entity gtech_lib.nor5_d
		generic map(7000 fs)
		port map(
			i0 => i2,
			i1 => i6,
			i2 => i4,
			i3 => i7,
			i4 => i5,
			o0 => Nor5620_o0
		);
		Or5640 : entity gtech_lib.or5_d
		generic map(6000 fs)
		port map(
			i0 => i1,
			i1 => i0,
			i2 => i3,
			i3 => i4,
			i4 => i1,
			o0 => Or5640_o0
		);
		Or5660 : entity gtech_lib.or5_d
		generic map(6000 fs)
		port map(
			i0 => Nor5540_o0,
			i1 => Or5640_o0,
			i2 => Nor5580_o0,
			i3 => Nand5560_o0,
			i4 => Nor5620_o0,
			o0 => Or5660_o0
		);
		Nand2680 : entity gtech_lib.nand2_d
		generic map(4000 fs)
		port map(
			i0 => Nand3600_o0,
			i1 => Nor5580_o0,
			o0 => Nand2680_o0
		);
		Nand4700 : entity gtech_lib.nand4_d
		generic map(6000 fs)
		port map(
			i0 => i6,
			i1 => Nor5620_o0,
			i2 => Nand3600_o0,
			i3 => i7,
			o0 => Nand4700_o0
		);
		Xor4720 : entity gtech_lib.xor4_d
		generic map(7000 fs)
		port map(
			i0 => i2,
			i1 => i5,
			i2 => Nor5540_o0,
			i3 => Nand5560_o0,
			o0 => Xor4720_o0
		);
		Or5740 : entity gtech_lib.or5_d
		generic map(6000 fs)
		port map(
			i0 => i0,
			i1 => i4,
			i2 => i2,
			i3 => Or5640_o0,
			i4 => Nand3600_o0,
			o0 => Or5740_o0
		);
		Xor2760 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Nand4700_o0,
			i1 => Or5740_o0,
			o0 => Xor2760_o0
		);
		Nand5780 : entity gtech_lib.nand5_d
		generic map(7000 fs)
		port map(
			i0 => Or5660_o0,
			i1 => Xor4720_o0,
			i2 => Nand2680_o0,
			i3 => Xor4720_o0,
			i4 => Nand5560_o0,
			o0 => Nand5780_o0
		);
		Xor3800 : entity gtech_lib.xor3_d
		generic map(6000 fs)
		port map(
			i0 => Nand2680_o0,
			i1 => i6,
			i2 => Or5660_o0,
			o0 => Xor3800_o0
		);
		Or5820 : entity gtech_lib.or5_d
		generic map(6000 fs)
		port map(
			i0 => i3,
			i1 => Or5740_o0,
			i2 => i7,
			i3 => Or5640_o0,
			i4 => i1,
			o0 => Or5820_o0
		);
		Nand3840 : entity gtech_lib.nand3_d
		generic map(5000 fs)
		port map(
			i0 => i5,
			i1 => Nor5620_o0,
			i2 => i6,
			o0 => Nand3840_o0
		);
		And2860 : entity gtech_lib.and2_d
		generic map(3000 fs)
		port map(
			i0 => Nand5780_o0,
			i1 => Xor3800_o0,
			o0 => And2860_o0
		);
		Nand3880 : entity gtech_lib.nand3_d
		generic map(5000 fs)
		port map(
			i0 => Xor2760_o0,
			i1 => Or5820_o0,
			i2 => Nand3840_o0,
			o0 => Nand3880_o0
		);
		Xor3900 : entity gtech_lib.xor3_d
		generic map(6000 fs)
		port map(
			i0 => Nand4700_o0,
			i1 => Xor2760_o0,
			i2 => i5,
			o0 => Xor3900_o0
		);
		Nand4920 : entity gtech_lib.nand4_d
		generic map(6000 fs)
		port map(
			i0 => Nor5540_o0,
			i1 => Or5660_o0,
			i2 => Or5740_o0,
			i3 => Nand4700_o0,
			o0 => Nand4920_o0
		);
		Not940 : entity gtech_lib.not_d
		generic map(2000 fs)
		port map(
			i0 => Xor4720_o0,
			o0 => Not940_o0
		);
		Nor3960 : entity gtech_lib.nor3_d
		generic map(5000 fs)
		port map(
			i0 => Nand4920_o0,
			i1 => Xor3900_o0,
			i2 => Not940_o0,
			o0 => Nor3960_o0
		);
		Xor5980 : entity gtech_lib.xor5_d
		generic map(8000 fs)
		port map(
			i0 => Nand3880_o0,
			i1 => And2860_o0,
			i2 => i7,
			i3 => i3,
			i4 => Nand2680_o0,
			o0 => Xor5980_o0
		);
		Xor21000 : entity gtech_lib.xor2_d
		generic map(5000 fs)
		port map(
			i0 => Xor3900_o0,
			i1 => Nor5580_o0,
			o0 => Xor21000_o0
		);
		Xor51020 : entity gtech_lib.xor5_d
		generic map(8000 fs)
		port map(
			i0 => Or5640_o0,
			i1 => Nor5620_o0,
			i2 => Or5660_o0,
			i3 => Nand3880_o0,
			i4 => Nor5580_o0,
			o0 => Xor51020_o0
		);
		Nand51040 : entity gtech_lib.nand5_d
		generic map(7000 fs)
		port map(
			i0 => Xor5980_o0,
			i1 => Xor21000_o0,
			i2 => Nor3960_o0,
			i3 => Xor51020_o0,
			i4 => Nand4920_o0,
			o0 => Nand51040_o0
		);
		Nor31060 : entity gtech_lib.nor3_d
		generic map(5000 fs)
		port map(
			i0 => Nand5780_o0,
			i1 => And2860_o0,
			i2 => Xor5980_o0,
			o0 => Nor31060_o0
		);
		Buffer1080 : entity gtech_lib.buffer_d
		generic map(1000 fs)
		port map(
			i0 => Nand3600_o0,
			o0 => Buffer1080_o0
		);
		Xor31100 : entity gtech_lib.xor3_d
		generic map(6000 fs)
		port map(
			i0 => Nand4700_o0,
			i1 => Not940_o0,
			i2 => Nor5540_o0,
			o0 => Xor31100_o0
		);

  ----------------------------------
  -- Wiring primary ouputs 
  ----------------------------------
  o0 <= Nand51040_o0;
	o1 <= Xor31100_o0;
	o2 <= Buffer1080_o0;
	o3 <= Nor31060_o0;

end architecture;