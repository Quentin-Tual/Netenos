library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity circ_source_1_tb is
end entity circ_source_1_tb;

architecture netenos of circ_source_1_tb is

    constant unit_delay : time := 1 ps;
    constant nom_period : time := (unit_delay * 10.5);

    signal tb_in : std_logic_vector(4 downto 0);
    
    signal tb_out : std_logic_vector(0 downto 0);
   

    signal tb_o0 : std_logic; 
	signal tb_o0_s : std_logic;
	

    signal running : boolean := true;
    -- signal phase_shift : boolean := false;

begin

    uut : entity work.circ_source(netenos)
    port map (
               tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_out(0)
    );

    stim : process
       
    begin

        
        wait for 0.0 * unit_delay;
        tb_in(1) <= '0';
    
        wait for 0.0 * unit_delay;
        tb_in(2) <= '1';
    
        wait for 0.5 * unit_delay;
        tb_in(1) <= '0';
    
        wait for 0.0 * unit_delay;
        tb_in(2) <= '1';
    
        wait for 0.5 * unit_delay;
        tb_in(1) <= '0';
    
        wait for 0.0 * unit_delay;
        tb_in(2) <= '1';
    
        wait for 0.5 * unit_delay;
        tb_in(1) <= '0';
    
        wait for 0.0 * unit_delay;
        tb_in(2) <= '0';
    
        wait for 1.0 * unit_delay;
        tb_in(0) <= '1';
    
        wait for 0.0 * unit_delay;
        tb_in(0) <= '1';
    
        wait for 0.5 * unit_delay;
        tb_in(0) <= '1';
    
        wait for 0.0 * unit_delay;
        tb_in(0) <= '1';
    
        wait for 1.0 * unit_delay;
        tb_in(3) <= '0';
    
        wait for 0.0 * unit_delay;
        tb_in(4) <= '0';
    
        wait for 0.5 * unit_delay;
        tb_in(3) <= '0';
    
        wait for 0.0 * unit_delay;
        tb_in(4) <= '0';
     

        wait for nom_period;
        running <= false;
        -- report "Stopping simulation";
        wait;
    end process;

end architecture netenos;