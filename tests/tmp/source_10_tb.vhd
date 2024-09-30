library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity source_10_tb is
end entity source_10_tb;

architecture netenos of source_10_tb is

    constant unit_delay : time := 1 ps; -- default already is 1, thus this line is not mandatory
    -- With a 1-unit model, the maximum path length is equivalent to the minimal period for nominal behavior 
    -- Which means minimum period is 4 for a unit_delay value of 1 (default value) 
    constant nom_period : time := (unit_delay * 59.0);
    constant obs_period : time := (unit_delay * 5.9);
    constant phase : time := 0.0 ps;
    signal nom_clk : std_logic := '1';
    signal obs_clk : std_logic := '1';

    signal tb_in : std_logic_vector(40 downto 0);
    
    signal tb_out_init : std_logic_vector(72 downto 0);
    signal tb_out_alt : std_logic_vector(72 downto 0);
    signal tb_out_diff : std_logic_vector(72 downto 0);

    signal tb_o0 : std_logic; 
	signal tb_o0_s : std_logic;
	signal tb_o1 : std_logic; 
	signal tb_o1_s : std_logic;
	signal tb_o2 : std_logic; 
	signal tb_o2_s : std_logic;
	signal tb_o3 : std_logic; 
	signal tb_o3_s : std_logic;
	signal tb_o4 : std_logic; 
	signal tb_o4_s : std_logic;
	signal tb_o5 : std_logic; 
	signal tb_o5_s : std_logic;
	signal tb_o6 : std_logic; 
	signal tb_o6_s : std_logic;
	signal tb_o7 : std_logic; 
	signal tb_o7_s : std_logic;
	signal tb_o8 : std_logic; 
	signal tb_o8_s : std_logic;
	signal tb_o9 : std_logic; 
	signal tb_o9_s : std_logic;
	signal tb_o10 : std_logic; 
	signal tb_o10_s : std_logic;
	signal tb_o11 : std_logic; 
	signal tb_o11_s : std_logic;
	signal tb_o12 : std_logic; 
	signal tb_o12_s : std_logic;
	signal tb_o13 : std_logic; 
	signal tb_o13_s : std_logic;
	signal tb_o14 : std_logic; 
	signal tb_o14_s : std_logic;
	signal tb_o15 : std_logic; 
	signal tb_o15_s : std_logic;
	signal tb_o16 : std_logic; 
	signal tb_o16_s : std_logic;
	signal tb_o17 : std_logic; 
	signal tb_o17_s : std_logic;
	signal tb_o18 : std_logic; 
	signal tb_o18_s : std_logic;
	signal tb_o19 : std_logic; 
	signal tb_o19_s : std_logic;
	signal tb_o20 : std_logic; 
	signal tb_o20_s : std_logic;
	signal tb_o21 : std_logic; 
	signal tb_o21_s : std_logic;
	signal tb_o22 : std_logic; 
	signal tb_o22_s : std_logic;
	signal tb_o23 : std_logic; 
	signal tb_o23_s : std_logic;
	signal tb_o24 : std_logic; 
	signal tb_o24_s : std_logic;
	signal tb_o25 : std_logic; 
	signal tb_o25_s : std_logic;
	signal tb_o26 : std_logic; 
	signal tb_o26_s : std_logic;
	signal tb_o27 : std_logic; 
	signal tb_o27_s : std_logic;
	signal tb_o28 : std_logic; 
	signal tb_o28_s : std_logic;
	signal tb_o29 : std_logic; 
	signal tb_o29_s : std_logic;
	signal tb_o30 : std_logic; 
	signal tb_o30_s : std_logic;
	signal tb_o31 : std_logic; 
	signal tb_o31_s : std_logic;
	signal tb_o32 : std_logic; 
	signal tb_o32_s : std_logic;
	signal tb_o33 : std_logic; 
	signal tb_o33_s : std_logic;
	signal tb_o34 : std_logic; 
	signal tb_o34_s : std_logic;
	signal tb_o35 : std_logic; 
	signal tb_o35_s : std_logic;
	signal tb_o36 : std_logic; 
	signal tb_o36_s : std_logic;
	signal tb_o37 : std_logic; 
	signal tb_o37_s : std_logic;
	signal tb_o38 : std_logic; 
	signal tb_o38_s : std_logic;
	signal tb_o39 : std_logic; 
	signal tb_o39_s : std_logic;
	signal tb_o40 : std_logic; 
	signal tb_o40_s : std_logic;
	signal tb_o41 : std_logic; 
	signal tb_o41_s : std_logic;
	signal tb_o42 : std_logic; 
	signal tb_o42_s : std_logic;
	signal tb_o43 : std_logic; 
	signal tb_o43_s : std_logic;
	signal tb_o44 : std_logic; 
	signal tb_o44_s : std_logic;
	signal tb_o45 : std_logic; 
	signal tb_o45_s : std_logic;
	signal tb_o46 : std_logic; 
	signal tb_o46_s : std_logic;
	signal tb_o47 : std_logic; 
	signal tb_o47_s : std_logic;
	signal tb_o48 : std_logic; 
	signal tb_o48_s : std_logic;
	signal tb_o49 : std_logic; 
	signal tb_o49_s : std_logic;
	signal tb_o50 : std_logic; 
	signal tb_o50_s : std_logic;
	signal tb_o51 : std_logic; 
	signal tb_o51_s : std_logic;
	signal tb_o52 : std_logic; 
	signal tb_o52_s : std_logic;
	signal tb_o53 : std_logic; 
	signal tb_o53_s : std_logic;
	signal tb_o54 : std_logic; 
	signal tb_o54_s : std_logic;
	signal tb_o55 : std_logic; 
	signal tb_o55_s : std_logic;
	signal tb_o56 : std_logic; 
	signal tb_o56_s : std_logic;
	signal tb_o57 : std_logic; 
	signal tb_o57_s : std_logic;
	signal tb_o58 : std_logic; 
	signal tb_o58_s : std_logic;
	signal tb_o59 : std_logic; 
	signal tb_o59_s : std_logic;
	signal tb_o60 : std_logic; 
	signal tb_o60_s : std_logic;
	signal tb_o61 : std_logic; 
	signal tb_o61_s : std_logic;
	signal tb_o62 : std_logic; 
	signal tb_o62_s : std_logic;
	signal tb_o63 : std_logic; 
	signal tb_o63_s : std_logic;
	signal tb_o64 : std_logic; 
	signal tb_o64_s : std_logic;
	signal tb_o65 : std_logic; 
	signal tb_o65_s : std_logic;
	signal tb_o66 : std_logic; 
	signal tb_o66_s : std_logic;
	signal tb_o67 : std_logic; 
	signal tb_o67_s : std_logic;
	signal tb_o68 : std_logic; 
	signal tb_o68_s : std_logic;
	signal tb_o69 : std_logic; 
	signal tb_o69_s : std_logic;
	signal tb_o70 : std_logic; 
	signal tb_o70_s : std_logic;
	signal tb_o71 : std_logic; 
	signal tb_o71_s : std_logic;
	signal tb_o72 : std_logic; 
	signal tb_o72_s : std_logic;
	

    signal running : boolean := true;
    signal phase_shift : boolean := false;

begin

    ref_unit : entity work.source(netenos)
    port map (
       tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_in(5), 
       tb_in(6), 
       tb_in(7), 
       tb_in(8), 
       tb_in(9), 
       tb_in(10), 
       tb_in(11), 
       tb_in(12), 
       tb_in(13), 
       tb_in(14), 
       tb_in(15), 
       tb_in(16), 
       tb_in(17), 
       tb_in(18), 
       tb_in(19), 
       tb_in(20), 
       tb_in(21), 
       tb_in(22), 
       tb_in(23), 
       tb_in(24), 
       tb_in(25), 
       tb_in(26), 
       tb_in(27), 
       tb_in(28), 
       tb_in(29), 
       tb_in(30), 
       tb_in(31), 
       tb_in(32), 
       tb_in(33), 
       tb_in(34), 
       tb_in(35), 
       tb_in(36), 
       tb_in(37), 
       tb_in(38), 
       tb_in(39), 
       tb_in(40), 
       tb_out_init(0), 
       tb_out_init(1), 
       tb_out_init(2), 
       tb_out_init(3), 
       tb_out_init(4), 
       tb_out_init(5), 
       tb_out_init(6), 
       tb_out_init(7), 
       tb_out_init(8), 
       tb_out_init(9), 
       tb_out_init(10), 
       tb_out_init(11), 
       tb_out_init(12), 
       tb_out_init(13), 
       tb_out_init(14), 
       tb_out_init(15), 
       tb_out_init(16), 
       tb_out_init(17), 
       tb_out_init(18), 
       tb_out_init(19), 
       tb_out_init(20), 
       tb_out_init(21), 
       tb_out_init(22), 
       tb_out_init(23), 
       tb_out_init(24), 
       tb_out_init(25), 
       tb_out_init(26), 
       tb_out_init(27), 
       tb_out_init(28), 
       tb_out_init(29), 
       tb_out_init(30), 
       tb_out_init(31), 
       tb_out_init(32), 
       tb_out_init(33), 
       tb_out_init(34), 
       tb_out_init(35), 
       tb_out_init(36), 
       tb_out_init(37), 
       tb_out_init(38), 
       tb_out_init(39), 
       tb_out_init(40), 
       tb_out_init(41), 
       tb_out_init(42), 
       tb_out_init(43), 
       tb_out_init(44), 
       tb_out_init(45), 
       tb_out_init(46), 
       tb_out_init(47), 
       tb_out_init(48), 
       tb_out_init(49), 
       tb_out_init(50), 
       tb_out_init(51), 
       tb_out_init(52), 
       tb_out_init(53), 
       tb_out_init(54), 
       tb_out_init(55), 
       tb_out_init(56), 
       tb_out_init(57), 
       tb_out_init(58), 
       tb_out_init(59), 
       tb_out_init(60), 
       tb_out_init(61), 
       tb_out_init(62), 
       tb_out_init(63), 
       tb_out_init(64), 
       tb_out_init(65), 
       tb_out_init(66), 
       tb_out_init(67), 
       tb_out_init(68), 
       tb_out_init(69), 
       tb_out_init(70), 
       tb_out_init(71), 
       tb_out_init(72)
    );

    uut : entity work.source_altered(netenos)
    port map (
       tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_in(5), 
       tb_in(6), 
       tb_in(7), 
       tb_in(8), 
       tb_in(9), 
       tb_in(10), 
       tb_in(11), 
       tb_in(12), 
       tb_in(13), 
       tb_in(14), 
       tb_in(15), 
       tb_in(16), 
       tb_in(17), 
       tb_in(18), 
       tb_in(19), 
       tb_in(20), 
       tb_in(21), 
       tb_in(22), 
       tb_in(23), 
       tb_in(24), 
       tb_in(25), 
       tb_in(26), 
       tb_in(27), 
       tb_in(28), 
       tb_in(29), 
       tb_in(30), 
       tb_in(31), 
       tb_in(32), 
       tb_in(33), 
       tb_in(34), 
       tb_in(35), 
       tb_in(36), 
       tb_in(37), 
       tb_in(38), 
       tb_in(39), 
       tb_in(40), 
       tb_out_alt(0), 
       tb_out_alt(1), 
       tb_out_alt(2), 
       tb_out_alt(3), 
       tb_out_alt(4), 
       tb_out_alt(5), 
       tb_out_alt(6), 
       tb_out_alt(7), 
       tb_out_alt(8), 
       tb_out_alt(9), 
       tb_out_alt(10), 
       tb_out_alt(11), 
       tb_out_alt(12), 
       tb_out_alt(13), 
       tb_out_alt(14), 
       tb_out_alt(15), 
       tb_out_alt(16), 
       tb_out_alt(17), 
       tb_out_alt(18), 
       tb_out_alt(19), 
       tb_out_alt(20), 
       tb_out_alt(21), 
       tb_out_alt(22), 
       tb_out_alt(23), 
       tb_out_alt(24), 
       tb_out_alt(25), 
       tb_out_alt(26), 
       tb_out_alt(27), 
       tb_out_alt(28), 
       tb_out_alt(29), 
       tb_out_alt(30), 
       tb_out_alt(31), 
       tb_out_alt(32), 
       tb_out_alt(33), 
       tb_out_alt(34), 
       tb_out_alt(35), 
       tb_out_alt(36), 
       tb_out_alt(37), 
       tb_out_alt(38), 
       tb_out_alt(39), 
       tb_out_alt(40), 
       tb_out_alt(41), 
       tb_out_alt(42), 
       tb_out_alt(43), 
       tb_out_alt(44), 
       tb_out_alt(45), 
       tb_out_alt(46), 
       tb_out_alt(47), 
       tb_out_alt(48), 
       tb_out_alt(49), 
       tb_out_alt(50), 
       tb_out_alt(51), 
       tb_out_alt(52), 
       tb_out_alt(53), 
       tb_out_alt(54), 
       tb_out_alt(55), 
       tb_out_alt(56), 
       tb_out_alt(57), 
       tb_out_alt(58), 
       tb_out_alt(59), 
       tb_out_alt(60), 
       tb_out_alt(61), 
       tb_out_alt(62), 
       tb_out_alt(63), 
       tb_out_alt(64), 
       tb_out_alt(65), 
       tb_out_alt(66), 
       tb_out_alt(67), 
       tb_out_alt(68), 
       tb_out_alt(69), 
       tb_out_alt(70), 
       tb_out_alt(71), 
       tb_out_alt(72)
    );

    phase_shift <= true after phase;
    nom_clk <= not(nom_clk) after (nom_period/2) when running else nom_clk;
    obs_clk <= not(obs_clk) after (obs_period/2) when running and phase_shift else obs_clk;

    tb_out_diff(0) <= tb_out_init(0) xor tb_out_alt(0);
	tb_out_diff(1) <= tb_out_init(1) xor tb_out_alt(1);
	tb_out_diff(2) <= tb_out_init(2) xor tb_out_alt(2);
	tb_out_diff(3) <= tb_out_init(3) xor tb_out_alt(3);
	tb_out_diff(4) <= tb_out_init(4) xor tb_out_alt(4);
	tb_out_diff(5) <= tb_out_init(5) xor tb_out_alt(5);
	tb_out_diff(6) <= tb_out_init(6) xor tb_out_alt(6);
	tb_out_diff(7) <= tb_out_init(7) xor tb_out_alt(7);
	tb_out_diff(8) <= tb_out_init(8) xor tb_out_alt(8);
	tb_out_diff(9) <= tb_out_init(9) xor tb_out_alt(9);
	tb_out_diff(10) <= tb_out_init(10) xor tb_out_alt(10);
	tb_out_diff(11) <= tb_out_init(11) xor tb_out_alt(11);
	tb_out_diff(12) <= tb_out_init(12) xor tb_out_alt(12);
	tb_out_diff(13) <= tb_out_init(13) xor tb_out_alt(13);
	tb_out_diff(14) <= tb_out_init(14) xor tb_out_alt(14);
	tb_out_diff(15) <= tb_out_init(15) xor tb_out_alt(15);
	tb_out_diff(16) <= tb_out_init(16) xor tb_out_alt(16);
	tb_out_diff(17) <= tb_out_init(17) xor tb_out_alt(17);
	tb_out_diff(18) <= tb_out_init(18) xor tb_out_alt(18);
	tb_out_diff(19) <= tb_out_init(19) xor tb_out_alt(19);
	tb_out_diff(20) <= tb_out_init(20) xor tb_out_alt(20);
	tb_out_diff(21) <= tb_out_init(21) xor tb_out_alt(21);
	tb_out_diff(22) <= tb_out_init(22) xor tb_out_alt(22);
	tb_out_diff(23) <= tb_out_init(23) xor tb_out_alt(23);
	tb_out_diff(24) <= tb_out_init(24) xor tb_out_alt(24);
	tb_out_diff(25) <= tb_out_init(25) xor tb_out_alt(25);
	tb_out_diff(26) <= tb_out_init(26) xor tb_out_alt(26);
	tb_out_diff(27) <= tb_out_init(27) xor tb_out_alt(27);
	tb_out_diff(28) <= tb_out_init(28) xor tb_out_alt(28);
	tb_out_diff(29) <= tb_out_init(29) xor tb_out_alt(29);
	tb_out_diff(30) <= tb_out_init(30) xor tb_out_alt(30);
	tb_out_diff(31) <= tb_out_init(31) xor tb_out_alt(31);
	tb_out_diff(32) <= tb_out_init(32) xor tb_out_alt(32);
	tb_out_diff(33) <= tb_out_init(33) xor tb_out_alt(33);
	tb_out_diff(34) <= tb_out_init(34) xor tb_out_alt(34);
	tb_out_diff(35) <= tb_out_init(35) xor tb_out_alt(35);
	tb_out_diff(36) <= tb_out_init(36) xor tb_out_alt(36);
	tb_out_diff(37) <= tb_out_init(37) xor tb_out_alt(37);
	tb_out_diff(38) <= tb_out_init(38) xor tb_out_alt(38);
	tb_out_diff(39) <= tb_out_init(39) xor tb_out_alt(39);
	tb_out_diff(40) <= tb_out_init(40) xor tb_out_alt(40);
	tb_out_diff(41) <= tb_out_init(41) xor tb_out_alt(41);
	tb_out_diff(42) <= tb_out_init(42) xor tb_out_alt(42);
	tb_out_diff(43) <= tb_out_init(43) xor tb_out_alt(43);
	tb_out_diff(44) <= tb_out_init(44) xor tb_out_alt(44);
	tb_out_diff(45) <= tb_out_init(45) xor tb_out_alt(45);
	tb_out_diff(46) <= tb_out_init(46) xor tb_out_alt(46);
	tb_out_diff(47) <= tb_out_init(47) xor tb_out_alt(47);
	tb_out_diff(48) <= tb_out_init(48) xor tb_out_alt(48);
	tb_out_diff(49) <= tb_out_init(49) xor tb_out_alt(49);
	tb_out_diff(50) <= tb_out_init(50) xor tb_out_alt(50);
	tb_out_diff(51) <= tb_out_init(51) xor tb_out_alt(51);
	tb_out_diff(52) <= tb_out_init(52) xor tb_out_alt(52);
	tb_out_diff(53) <= tb_out_init(53) xor tb_out_alt(53);
	tb_out_diff(54) <= tb_out_init(54) xor tb_out_alt(54);
	tb_out_diff(55) <= tb_out_init(55) xor tb_out_alt(55);
	tb_out_diff(56) <= tb_out_init(56) xor tb_out_alt(56);
	tb_out_diff(57) <= tb_out_init(57) xor tb_out_alt(57);
	tb_out_diff(58) <= tb_out_init(58) xor tb_out_alt(58);
	tb_out_diff(59) <= tb_out_init(59) xor tb_out_alt(59);
	tb_out_diff(60) <= tb_out_init(60) xor tb_out_alt(60);
	tb_out_diff(61) <= tb_out_init(61) xor tb_out_alt(61);
	tb_out_diff(62) <= tb_out_init(62) xor tb_out_alt(62);
	tb_out_diff(63) <= tb_out_init(63) xor tb_out_alt(63);
	tb_out_diff(64) <= tb_out_init(64) xor tb_out_alt(64);
	tb_out_diff(65) <= tb_out_init(65) xor tb_out_alt(65);
	tb_out_diff(66) <= tb_out_init(66) xor tb_out_alt(66);
	tb_out_diff(67) <= tb_out_init(67) xor tb_out_alt(67);
	tb_out_diff(68) <= tb_out_init(68) xor tb_out_alt(68);
	tb_out_diff(69) <= tb_out_init(69) xor tb_out_alt(69);
	tb_out_diff(70) <= tb_out_init(70) xor tb_out_alt(70);
	tb_out_diff(71) <= tb_out_init(71) xor tb_out_alt(71);
	tb_out_diff(72) <= tb_out_init(72) xor tb_out_alt(72);
	

    tb_o0 <= tb_out_diff(0);
	tb_o1 <= tb_out_diff(1);
	tb_o2 <= tb_out_diff(2);
	tb_o3 <= tb_out_diff(3);
	tb_o4 <= tb_out_diff(4);
	tb_o5 <= tb_out_diff(5);
	tb_o6 <= tb_out_diff(6);
	tb_o7 <= tb_out_diff(7);
	tb_o8 <= tb_out_diff(8);
	tb_o9 <= tb_out_diff(9);
	tb_o10 <= tb_out_diff(10);
	tb_o11 <= tb_out_diff(11);
	tb_o12 <= tb_out_diff(12);
	tb_o13 <= tb_out_diff(13);
	tb_o14 <= tb_out_diff(14);
	tb_o15 <= tb_out_diff(15);
	tb_o16 <= tb_out_diff(16);
	tb_o17 <= tb_out_diff(17);
	tb_o18 <= tb_out_diff(18);
	tb_o19 <= tb_out_diff(19);
	tb_o20 <= tb_out_diff(20);
	tb_o21 <= tb_out_diff(21);
	tb_o22 <= tb_out_diff(22);
	tb_o23 <= tb_out_diff(23);
	tb_o24 <= tb_out_diff(24);
	tb_o25 <= tb_out_diff(25);
	tb_o26 <= tb_out_diff(26);
	tb_o27 <= tb_out_diff(27);
	tb_o28 <= tb_out_diff(28);
	tb_o29 <= tb_out_diff(29);
	tb_o30 <= tb_out_diff(30);
	tb_o31 <= tb_out_diff(31);
	tb_o32 <= tb_out_diff(32);
	tb_o33 <= tb_out_diff(33);
	tb_o34 <= tb_out_diff(34);
	tb_o35 <= tb_out_diff(35);
	tb_o36 <= tb_out_diff(36);
	tb_o37 <= tb_out_diff(37);
	tb_o38 <= tb_out_diff(38);
	tb_o39 <= tb_out_diff(39);
	tb_o40 <= tb_out_diff(40);
	tb_o41 <= tb_out_diff(41);
	tb_o42 <= tb_out_diff(42);
	tb_o43 <= tb_out_diff(43);
	tb_o44 <= tb_out_diff(44);
	tb_o45 <= tb_out_diff(45);
	tb_o46 <= tb_out_diff(46);
	tb_o47 <= tb_out_diff(47);
	tb_o48 <= tb_out_diff(48);
	tb_o49 <= tb_out_diff(49);
	tb_o50 <= tb_out_diff(50);
	tb_o51 <= tb_out_diff(51);
	tb_o52 <= tb_out_diff(52);
	tb_o53 <= tb_out_diff(53);
	tb_o54 <= tb_out_diff(54);
	tb_o55 <= tb_out_diff(55);
	tb_o56 <= tb_out_diff(56);
	tb_o57 <= tb_out_diff(57);
	tb_o58 <= tb_out_diff(58);
	tb_o59 <= tb_out_diff(59);
	tb_o60 <= tb_out_diff(60);
	tb_o61 <= tb_out_diff(61);
	tb_o62 <= tb_out_diff(62);
	tb_o63 <= tb_out_diff(63);
	tb_o64 <= tb_out_diff(64);
	tb_o65 <= tb_out_diff(65);
	tb_o66 <= tb_out_diff(66);
	tb_o67 <= tb_out_diff(67);
	tb_o68 <= tb_out_diff(68);
	tb_o69 <= tb_out_diff(69);
	tb_o70 <= tb_out_diff(70);
	tb_o71 <= tb_out_diff(71);
	tb_o72 <= tb_out_diff(72);
	

    process(obs_clk)
    begin
        if rising_edge(obs_clk) then
            tb_o0_s <= tb_out_diff(0);
			tb_o1_s <= tb_out_diff(1);
			tb_o2_s <= tb_out_diff(2);
			tb_o3_s <= tb_out_diff(3);
			tb_o4_s <= tb_out_diff(4);
			tb_o5_s <= tb_out_diff(5);
			tb_o6_s <= tb_out_diff(6);
			tb_o7_s <= tb_out_diff(7);
			tb_o8_s <= tb_out_diff(8);
			tb_o9_s <= tb_out_diff(9);
			tb_o10_s <= tb_out_diff(10);
			tb_o11_s <= tb_out_diff(11);
			tb_o12_s <= tb_out_diff(12);
			tb_o13_s <= tb_out_diff(13);
			tb_o14_s <= tb_out_diff(14);
			tb_o15_s <= tb_out_diff(15);
			tb_o16_s <= tb_out_diff(16);
			tb_o17_s <= tb_out_diff(17);
			tb_o18_s <= tb_out_diff(18);
			tb_o19_s <= tb_out_diff(19);
			tb_o20_s <= tb_out_diff(20);
			tb_o21_s <= tb_out_diff(21);
			tb_o22_s <= tb_out_diff(22);
			tb_o23_s <= tb_out_diff(23);
			tb_o24_s <= tb_out_diff(24);
			tb_o25_s <= tb_out_diff(25);
			tb_o26_s <= tb_out_diff(26);
			tb_o27_s <= tb_out_diff(27);
			tb_o28_s <= tb_out_diff(28);
			tb_o29_s <= tb_out_diff(29);
			tb_o30_s <= tb_out_diff(30);
			tb_o31_s <= tb_out_diff(31);
			tb_o32_s <= tb_out_diff(32);
			tb_o33_s <= tb_out_diff(33);
			tb_o34_s <= tb_out_diff(34);
			tb_o35_s <= tb_out_diff(35);
			tb_o36_s <= tb_out_diff(36);
			tb_o37_s <= tb_out_diff(37);
			tb_o38_s <= tb_out_diff(38);
			tb_o39_s <= tb_out_diff(39);
			tb_o40_s <= tb_out_diff(40);
			tb_o41_s <= tb_out_diff(41);
			tb_o42_s <= tb_out_diff(42);
			tb_o43_s <= tb_out_diff(43);
			tb_o44_s <= tb_out_diff(44);
			tb_o45_s <= tb_out_diff(45);
			tb_o46_s <= tb_out_diff(46);
			tb_o47_s <= tb_out_diff(47);
			tb_o48_s <= tb_out_diff(48);
			tb_o49_s <= tb_out_diff(49);
			tb_o50_s <= tb_out_diff(50);
			tb_o51_s <= tb_out_diff(51);
			tb_o52_s <= tb_out_diff(52);
			tb_o53_s <= tb_out_diff(53);
			tb_o54_s <= tb_out_diff(54);
			tb_o55_s <= tb_out_diff(55);
			tb_o56_s <= tb_out_diff(56);
			tb_o57_s <= tb_out_diff(57);
			tb_o58_s <= tb_out_diff(58);
			tb_o59_s <= tb_out_diff(59);
			tb_o60_s <= tb_out_diff(60);
			tb_o61_s <= tb_out_diff(61);
			tb_o62_s <= tb_out_diff(62);
			tb_o63_s <= tb_out_diff(63);
			tb_o64_s <= tb_out_diff(64);
			tb_o65_s <= tb_out_diff(65);
			tb_o66_s <= tb_out_diff(66);
			tb_o67_s <= tb_out_diff(67);
			tb_o68_s <= tb_out_diff(68);
			tb_o69_s <= tb_out_diff(69);
			tb_o70_s <= tb_out_diff(70);
			tb_o71_s <= tb_out_diff(71);
			tb_o72_s <= tb_out_diff(72);
			
        else
            tb_o0_s <= tb_o0_s;
			tb_o1_s <= tb_o1_s;
			tb_o2_s <= tb_o2_s;
			tb_o3_s <= tb_o3_s;
			tb_o4_s <= tb_o4_s;
			tb_o5_s <= tb_o5_s;
			tb_o6_s <= tb_o6_s;
			tb_o7_s <= tb_o7_s;
			tb_o8_s <= tb_o8_s;
			tb_o9_s <= tb_o9_s;
			tb_o10_s <= tb_o10_s;
			tb_o11_s <= tb_o11_s;
			tb_o12_s <= tb_o12_s;
			tb_o13_s <= tb_o13_s;
			tb_o14_s <= tb_o14_s;
			tb_o15_s <= tb_o15_s;
			tb_o16_s <= tb_o16_s;
			tb_o17_s <= tb_o17_s;
			tb_o18_s <= tb_o18_s;
			tb_o19_s <= tb_o19_s;
			tb_o20_s <= tb_o20_s;
			tb_o21_s <= tb_o21_s;
			tb_o22_s <= tb_o22_s;
			tb_o23_s <= tb_o23_s;
			tb_o24_s <= tb_o24_s;
			tb_o25_s <= tb_o25_s;
			tb_o26_s <= tb_o26_s;
			tb_o27_s <= tb_o27_s;
			tb_o28_s <= tb_o28_s;
			tb_o29_s <= tb_o29_s;
			tb_o30_s <= tb_o30_s;
			tb_o31_s <= tb_o31_s;
			tb_o32_s <= tb_o32_s;
			tb_o33_s <= tb_o33_s;
			tb_o34_s <= tb_o34_s;
			tb_o35_s <= tb_o35_s;
			tb_o36_s <= tb_o36_s;
			tb_o37_s <= tb_o37_s;
			tb_o38_s <= tb_o38_s;
			tb_o39_s <= tb_o39_s;
			tb_o40_s <= tb_o40_s;
			tb_o41_s <= tb_o41_s;
			tb_o42_s <= tb_o42_s;
			tb_o43_s <= tb_o43_s;
			tb_o44_s <= tb_o44_s;
			tb_o45_s <= tb_o45_s;
			tb_o46_s <= tb_o46_s;
			tb_o47_s <= tb_o47_s;
			tb_o48_s <= tb_o48_s;
			tb_o49_s <= tb_o49_s;
			tb_o50_s <= tb_o50_s;
			tb_o51_s <= tb_o51_s;
			tb_o52_s <= tb_o52_s;
			tb_o53_s <= tb_o53_s;
			tb_o54_s <= tb_o54_s;
			tb_o55_s <= tb_o55_s;
			tb_o56_s <= tb_o56_s;
			tb_o57_s <= tb_o57_s;
			tb_o58_s <= tb_o58_s;
			tb_o59_s <= tb_o59_s;
			tb_o60_s <= tb_o60_s;
			tb_o61_s <= tb_o61_s;
			tb_o62_s <= tb_o62_s;
			tb_o63_s <= tb_o63_s;
			tb_o64_s <= tb_o64_s;
			tb_o65_s <= tb_o65_s;
			tb_o66_s <= tb_o66_s;
			tb_o67_s <= tb_o67_s;
			tb_o68_s <= tb_o68_s;
			tb_o69_s <= tb_o69_s;
			tb_o70_s <= tb_o70_s;
			tb_o71_s <= tb_o71_s;
			tb_o72_s <= tb_o72_s;
			
        end if;
    end process;

    stim : process
        file stim_file : text open read_mode is "stim.txt";
        variable text_line : line;
        variable stim_val : std_logic_vector(40 downto 0);
        variable text_val : bit_vector(40 downto 0);
    begin
        -- report "Starting simulation...";
        
        while not endfile(stim_file) loop   
            
            readline(stim_file, text_line);
        
            -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
                next;
            end if;

            read(text_line, text_val);
           
            stim_val :=  to_stdlogicvector(text_val);
            --read(text_line, stim_val);

            for k in 0 to 40 loop
                tb_in(k) <= stim_val(k);
            end loop;

            wait until rising_edge(nom_clk);
        
        end loop;

        wait for nom_period;
        running <= false;
        -- report "Stopping simulation";
        wait;
    end process;

end architecture netenos;