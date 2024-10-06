library ieee;
use ieee.std_logic_1164.all;

entity event_detect is
    port (
        clk : in std_logic;
        input_val : in std_logic;
        detected : out std_logic
    );
end event_detect;

architecture bhv of event_detect is
    signal latched_value : std_logic;
begin

    process(clk)
    begin        
        if rising_edge(clk) then
            latched_value <= input_val;
        else
            latched_value <= latched_value;
        end if;
    end process;    
    
    detected <= latched_value xor input_val;

end architecture;