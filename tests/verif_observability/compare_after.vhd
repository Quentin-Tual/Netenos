library ieee;
use ieee.std_logic_1164.all;

entity compare_after is
    generic(
        delay : in natural
    );
    port (
        clk : in std_logic;
        delayed_input : in std_logic;
        direct_input : in std_logic;
        diff : out std_logic
    );
end compare_after;

architecture bhv of compare_after is

    component bascule_d is
        port(
            clk : in std_logic;
            D : in std_logic;
            Q : out std_logic
        );
    end component;

    signal values : std_logic_vector(delay downto 0);
begin
    
    values(0) <= delayed_input;
    
    shift_register : for i in 0 to delay-1 generate
        reg : bascule_d port map (clk, values(i), values(i+1));
    end generate shift_register;
    
    diff <= values(delay) and direct_input;

end architecture;