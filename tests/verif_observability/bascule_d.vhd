library ieee;
use ieee.std_logic_1164.all;

entity bascule_d is
    port (
        clk : in std_logic;
        D : in std_logic;
        Q : out std_logic
    );
end bascule_d;

architecture bhv of bascule_d is
    signal latched_value : std_logic;
begin

    process(clk)
    begin        
        if rising_edge(clk) then
            Q <= D;
        else
            Q <= Q;
        end if;
    end process;    

end architecture;