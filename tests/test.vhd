entity test is 
    port ( 
        clk : in bit;
        en : in bit;
        rst : in bit;
        s : out bit;
        o : out bit
    );
end test;

architecture enoslist of test is

    signal s0 : bit;
    signal s1 : bit_vector(15 downto 0);
    signal s2 : bit;

begin

    s <= clk;
    o <= s;
    s0 <= clk and en;
    s2 <= s;

end architecture;

architecture behavioral of test is

begin

    

end architecture;

