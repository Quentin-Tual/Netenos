library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library gtech_lib;
 
entity test is
  port(
    clk : in  std_logic;
    i0 : in  std_logic;
    i1 : in  std_logic;
    i2 : in  std_logic;
    i3 : in  std_logic;
    i4 : in  std_logic;
    i5 : in  std_logic;
    i6 : in  std_logic;
    i7 : in  std_logic;
    i8 : in  std_logic;
    i9 : in  std_logic;
    i10 : in  std_logic;
    i11 : in  std_logic;
    i12 : in  std_logic;
    i13 : in  std_logic;
    i14 : in  std_logic;
    i15 : in  std_logic;
    i16 : in  std_logic;
    i17 : in  std_logic;
    i18 : in  std_logic;
    i19 : in  std_logic;
    i20 : in  std_logic;
    i21 : in  std_logic;
    i22 : in  std_logic;
    i23 : in  std_logic;
    i24 : in  std_logic;
    o0 : out std_logic;
    o1 : out std_logic;
    o2 : out std_logic;
    o3 : out std_logic;
    o4 : out std_logic;
    o5 : out std_logic;
    o6 : out std_logic;
    o7 : out std_logic;
    o8 : out std_logic;
    o9 : out std_logic;
    o10 : out std_logic;
    o11 : out std_logic;
    o12 : out std_logic;
    o13 : out std_logic;
    o14 : out std_logic;
    o15 : out std_logic;
    o16 : out std_logic;
    o17 : out std_logic;
    o18 : out std_logic;
    o19 : out std_logic
  );
end test;
 
architecture netenos of test is
  signal Nor21020_o0 : std_logic;
  signal Nand21040_o0 : std_logic;
  signal Not1060_o0 : std_logic;
  signal Or21080_o0 : std_logic;
  signal Nor21100_o0 : std_logic;
  signal Nand21120_o0 : std_logic;
  signal Not1140_o0 : std_logic;
  signal Xor21160_o0 : std_logic;
  signal Nor21180_o0 : std_logic;
  signal Xor21200_o0 : std_logic;
  signal Xor21220_o0 : std_logic;
  signal Or21240_o0 : std_logic;
  signal Nand21260_o0 : std_logic;
  signal Xor21280_o0 : std_logic;
  signal Nand21300_o0 : std_logic;
  signal Nand21320_o0 : std_logic;
  signal Xor21340_o0 : std_logic;
  signal And21360_o0 : std_logic;
  signal Nand21380_o0 : std_logic;
  signal And21400_o0 : std_logic;
  signal Nand21420_o0 : std_logic;
  signal Not1440_o0 : std_logic;
  signal And21460_o0 : std_logic;
  signal Not1480_o0 : std_logic;
  signal And21500_o0 : std_logic;
  signal Nand21520_o0 : std_logic;
  signal Not1540_o0 : std_logic;
  signal Nand21560_o0 : std_logic;
  signal Nor21580_o0 : std_logic;
  signal Nand21600_o0 : std_logic;
  signal Xor21620_o0 : std_logic;
  signal Xor21640_o0 : std_logic;
  signal And21660_o0 : std_logic;
  signal Not1680_o0 : std_logic;
  signal Or21700_o0 : std_logic;
  signal Or21720_o0 : std_logic;
  signal Not1740_o0 : std_logic;
  signal Nand21760_o0 : std_logic;
  signal Xor21780_o0 : std_logic;
  signal Nand21800_o0 : std_logic;
  signal Nand21820_o0 : std_logic;
  signal Nand21840_o0 : std_logic;
  signal Nor21860_o0 : std_logic;
  signal Not1880_o0 : std_logic;
  signal Not1900_o0 : std_logic;
  signal And21920_o0 : std_logic;
  signal And21940_o0 : std_logic;
begin
  ----------------------------------
  -- input to wire connexions 
  ----------------------------------
  ----------------------------------
  -- component interconnect 
  ----------------------------------
  Nor21020 : entity gtech_lib.nor2_d
    generic map(1000 ps)
    port map(
      i0 => i17,
      i1 => i7,
      o0 => Nor21020_o0
    );
    Nand21040 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => i3,
      i1 => i14,
      o0 => Nand21040_o0
    );
    Not1060 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => i11,
      o0 => Not1060_o0
    );
    Or21080 : entity gtech_lib.or2_d
    generic map(1000 ps)
    port map(
      i0 => i1,
      i1 => i2,
      o0 => Or21080_o0
    );
    Nor21100 : entity gtech_lib.nor2_d
    generic map(1000 ps)
    port map(
      i0 => i23,
      i1 => i22,
      o0 => Nor21100_o0
    );
    Nand21120 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => i12,
      i1 => i6,
      o0 => Nand21120_o0
    );
    Not1140 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => i10,
      o0 => Not1140_o0
    );
    Xor21160 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => i8,
      i1 => i0,
      o0 => Xor21160_o0
    );
    Nor21180 : entity gtech_lib.nor2_d
    generic map(1000 ps)
    port map(
      i0 => i4,
      i1 => i20,
      o0 => Nor21180_o0
    );
    Xor21200 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => i21,
      i1 => i18,
      o0 => Xor21200_o0
    );
    Xor21220 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => i16,
      i1 => i13,
      o0 => Xor21220_o0
    );
    Or21240 : entity gtech_lib.or2_d
    generic map(1000 ps)
    port map(
      i0 => i5,
      i1 => i19,
      o0 => Or21240_o0
    );
    Nand21260 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Xor21200_o0,
      i1 => i9,
      o0 => Nand21260_o0
    );
    Xor21280 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => i24,
      i1 => Or21080_o0,
      o0 => Xor21280_o0
    );
    Nand21300 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Xor21160_o0,
      i1 => i15,
      o0 => Nand21300_o0
    );
    Nand21320 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21040_o0,
      i1 => Or21240_o0,
      o0 => Nand21320_o0
    );
    Xor21340 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => Not1140_o0,
      i1 => Nor21180_o0,
      o0 => Xor21340_o0
    );
    And21360 : entity gtech_lib.and2_d
    generic map(1000 ps)
    port map(
      i0 => Nor21020_o0,
      i1 => Xor21220_o0,
      o0 => And21360_o0
    );
    Nand21380 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Nor21100_o0,
      i1 => Nand21120_o0,
      o0 => Nand21380_o0
    );
    And21400 : entity gtech_lib.and2_d
    generic map(1000 ps)
    port map(
      i0 => Not1060_o0,
      i1 => Or21080_o0,
      o0 => And21400_o0
    );
    Nand21420 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Xor21340_o0,
      i1 => And21400_o0,
      o0 => Nand21420_o0
    );
    Not1440 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => Nand21380_o0,
      o0 => Not1440_o0
    );
    And21460 : entity gtech_lib.and2_d
    generic map(1000 ps)
    port map(
      i0 => And21360_o0,
      i1 => Nand21320_o0,
      o0 => And21460_o0
    );
    Not1480 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => Xor21280_o0,
      o0 => Not1480_o0
    );
    And21500 : entity gtech_lib.and2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21300_o0,
      i1 => Nand21260_o0,
      o0 => And21500_o0
    );
    Nand21520 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Or21240_o0,
      i1 => Xor21280_o0,
      o0 => Nand21520_o0
    );
    Not1540 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => Not1480_o0,
      o0 => Not1540_o0
    );
    Nand21560 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21520_o0,
      i1 => Nand21420_o0,
      o0 => Nand21560_o0
    );
    Nor21580 : entity gtech_lib.nor2_d
    generic map(1000 ps)
    port map(
      i0 => And21500_o0,
      i1 => Not1440_o0,
      o0 => Nor21580_o0
    );
    Nand21600 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => And21460_o0,
      i1 => i7,
      o0 => Nand21600_o0
    );
    Xor21620 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => Nor21180_o0,
      i1 => Nand21520_o0,
      o0 => Xor21620_o0
    );
    Xor21640 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => Xor21620_o0,
      i1 => Nand21560_o0,
      o0 => Xor21640_o0
    );
    And21660 : entity gtech_lib.and2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21600_o0,
      i1 => Not1540_o0,
      o0 => And21660_o0
    );
    Not1680 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => Nor21580_o0,
      o0 => Not1680_o0
    );
    Or21700 : entity gtech_lib.or2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21300_o0,
      i1 => i21,
      o0 => Or21700_o0
    );
    Or21720 : entity gtech_lib.or2_d
    generic map(1000 ps)
    port map(
      i0 => Xor21640_o0,
      i1 => Or21700_o0,
      o0 => Or21720_o0
    );
    Not1740 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => And21660_o0,
      o0 => Not1740_o0
    );
    Nand21760 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Not1680_o0,
      i1 => And21500_o0,
      o0 => Nand21760_o0
    );
    Xor21780 : entity gtech_lib.xor2_d
    generic map(1000 ps)
    port map(
      i0 => Not1740_o0,
      i1 => Or21720_o0,
      o0 => Xor21780_o0
    );
    Nand21800 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21760_o0,
      i1 => Or21720_o0,
      o0 => Nand21800_o0
    );
    Nand21820 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Not1440_o0,
      i1 => Xor21160_o0,
      o0 => Nand21820_o0
    );
    Nand21840 : entity gtech_lib.nand2_d
    generic map(1000 ps)
    port map(
      i0 => Xor21780_o0,
      i1 => Nand21800_o0,
      o0 => Nand21840_o0
    );
    Nor21860 : entity gtech_lib.nor2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21820_o0,
      i1 => i2,
      o0 => Nor21860_o0
    );
    Not1880 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => Nor21860_o0,
      o0 => Not1880_o0
    );
    Not1900 : entity gtech_lib.not_d
    generic map(1000.0 ps)
    port map(
      i0 => Nand21840_o0,
      o0 => Not1900_o0
    );
    And21920 : entity gtech_lib.and2_d
    generic map(1000 ps)
    port map(
      i0 => Not1900_o0,
      i1 => Not1880_o0,
      o0 => And21920_o0
    );
    And21940 : entity gtech_lib.and2_d
    generic map(1000 ps)
    port map(
      i0 => Nand21040_o0,
      i1 => Not1900_o0,
      o0 => And21940_o0
    );
  ----------------------------------
  -- input to wire to output connexions 
  ----------------------------------
  o0 <= And21920_o0;
  o1 <= And21940_o0;
  o2 <= And21920_o0;
  o3 <= And21920_o0;
  o4 <= Nand21320_o0;
  o5 <= Or21700_o0;
  o6 <= Nand21560_o0;
  o7 <= Not1740_o0;
  o8 <= Not1480_o0;
  o9 <= Not1900_o0;
  o10 <= Xor21200_o0;
  o11 <= Nand21600_o0;
  o12 <= Or21720_o0;
  o13 <= Nor21860_o0;
  o14 <= Xor21780_o0;
  o15 <= Not1900_o0;
  o16 <= And21400_o0;
  o17 <= Or21720_o0;
  o18 <= Xor21200_o0;
  o19 <= Not1540_o0;
end netenos;
