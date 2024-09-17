library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity test_1_tb is
end entity test_1_tb;

architecture netenos of test_1_tb is

    constant unit_delay : time := 1 ps;
    constant nom_period : time := (unit_delay * 21.0);

    signal tb_in : std_logic_vector(5 downto 0);
    
    signal tb_out : std_logic_vector(3 downto 0);
   

    signal tb_o0 : std_logic; 
	signal tb_o0_s : std_logic;
	signal tb_o1 : std_logic; 
	signal tb_o1_s : std_logic;
	signal tb_o2 : std_logic; 
	signal tb_o2_s : std_logic;
	signal tb_o3 : std_logic; 
	signal tb_o3_s : std_logic;
	

    signal running : boolean := true;
    -- signal phase_shift : boolean := false;

begin

    uut : entity work.test(netenos)
    port map (
               tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_in(5), 
       tb_out(0), 
       tb_out(1), 
       tb_out(2), 
       tb_out(3)
    );

    stim : process
       
    begin

        
        wait for 14.0 * unit_delay;
        tb_in(1) <= '1';
    
        wait for 0.0 * unit_delay;
        tb_in(3) <= '1';
    
        wait for 2.5 * unit_delay;
        tb_in(1) <= '1';
    
        wait for 0.5 * unit_delay;
        tb_in(5) <= '0';
    
        wait for 0.0 * unit_delay;
        tb_in(2) <= '0';
     

        wait for nom_period;
        running <= false;
        -- report "Stopping simulation";
        wait;
    end process;

end architecture netenos;