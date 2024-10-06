library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity circ_C17_10_tb is
end entity circ_C17_10_tb;

architecture netenos of circ_C17_10_tb is

    constant unit_delay : time := 1 ps; -- default already is 1, thus this line is not mandatory
    -- With a 1-unit model, the maximum path length is equivalent to the minimal period for nominal behavior 
    -- Which means minimum period is 4 for a unit_delay value of 1 (default value) 
    constant nom_period : time := (unit_delay * 7.0);
    constant obs_period : time := (unit_delay * 0.7);
    constant phase : time := 0.0 ps;
    signal nom_clk : std_logic := '1';
    signal obs_clk : std_logic := '1';

    signal tb_in : std_logic_vector(4 downto 0);
    
    signal tb_out_init : std_logic_vector(1 downto 0);
    signal tb_out_alt : std_logic_vector(1 downto 0);
    signal tb_out_diff : std_logic_vector(1 downto 0);

    signal tb_o0 : std_logic; 
	signal tb_o0_s : std_logic;
	signal tb_o1 : std_logic; 
	signal tb_o1_s : std_logic;
	

    signal running : boolean := true;
    signal phase_shift : boolean := false;

begin

    ref_unit : entity work.circ_C17(netenos)
    port map (
       tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_out_init(0), 
       tb_out_init(1)
    );

    uut : entity work.circ_C17_altered(netenos)
    port map (
       tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_out_alt(0), 
       tb_out_alt(1)
    );

    phase_shift <= true after phase;
    nom_clk <= not(nom_clk) after (nom_period/2) when running else nom_clk;
    obs_clk <= not(obs_clk) after (obs_period/2) when running and phase_shift else obs_clk;

    tb_out_diff(0) <= tb_out_init(0) xor tb_out_alt(0);
	tb_out_diff(1) <= tb_out_init(1) xor tb_out_alt(1);
	

    tb_o0 <= tb_out_diff(0);
	tb_o1 <= tb_out_diff(1);
	

    process(obs_clk)
    begin
        if rising_edge(obs_clk) then
            tb_o0_s <= tb_out_diff(0);
			tb_o1_s <= tb_out_diff(1);
			
        else
            tb_o0_s <= tb_o0_s;
			tb_o1_s <= tb_o1_s;
			
        end if;
    end process;

    stim : process
        file stim_file : text open read_mode is "stim.txt";
        variable text_line : line;
        variable stim_val : std_logic_vector(4 downto 0);
        variable text_val : natural;
    begin
        -- report "Starting simulation...";
        
        while not endfile(stim_file) loop   
            
            readline(stim_file, text_line);
        
            -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
                next;
            end if;

            read(text_line, text_val);
           
            stim_val :=  std_logic_vector(to_unsigned(text_val, 5));
            --read(text_line, stim_val);

            for k in 0 to 4 loop
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