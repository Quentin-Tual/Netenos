library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity rand_140_1_tb is
end entity rand_140_1_tb;

architecture netenos of rand_140_1_tb is

    constant unit_delay : time := 1 ps;
    constant nom_period : time := (unit_delay * 39);

    signal tb_in : std_logic_vector(7 downto 0);
    
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

    uut : entity work.rand_140(netenos)
    port map (
               tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_in(5), 
       tb_in(6), 
       tb_in(7), 
       tb_out(0), 
       tb_out(1), 
       tb_out(2), 
       tb_out(3)
    );

    stim : process
       
    begin

        
        wait for 35 * unit_delay;
        tb_in(6) <= '0';
     

        wait for nom_period;
        running <= false;
        -- report "Stopping simulation";
        wait;
    end process;

end architecture netenos;