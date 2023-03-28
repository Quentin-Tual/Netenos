entity test2 is
	port (
		clk : in bit;
		en : in bit;
		rst : in bit;
		o1 : out bit;
		o2 : out bit;
		o3 : out bit;
		o4 : out bit
	);
end test2;

architecture enoslist of test2 is

	signal s0 : bit;
	signal s1 : bit;
	signal s2 : bit;
	signal s3 : bit;

begin

	MUX : entity work.test(enoslist)
	port map (
		clk => clk,
		en => en,
		rst => rst,
		s => s0,
		o => s1
	);
	o3 <= clk;
	o1 <= s3;

end architecture;

