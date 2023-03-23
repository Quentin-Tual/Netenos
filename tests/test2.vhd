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

architecture rtl of test2 is

    signal s0 : bit;
    signal s1 : bit_vector(15 downto 0);

begin

    o1 <= clk;
    s0 <= en;

end architecture;

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
    s3 <= s0 and s1;
    o1 <= s3;
    o4 <= s3 or s1;
    s2 <= o3;
    o2 <= o3 xor s3;

end architecture;

