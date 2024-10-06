library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;
use std.env.all;

use work.tunnel_pkg.all;

entity circ_source_1_tb is
end entity circ_source_1_tb;

architecture netenos of circ_source_1_tb is

    constant unit_delay : time := 1 ps; -- default already is 1, thus this line is not mandatory
    -- With a 1-unit model, the maximum path length is equivalent to the minimal period for nominal behavior 
    -- Which means minimum period is 4 for a unit_delay value of 1 (default value) 
    constant nom_period : time := (unit_delay * 10.5);
    constant obs_period : time := (unit_delay * 10.5);
    constant phase : time := 0.0 ps;
    signal nom_clk : std_logic := '1';
    signal obs_clk : std_logic := '1';
    
    signal tb_in : std_logic_vector(4 downto 0);
    signal tb_out : std_logic_vector(0 downto 0);
    signal tb_o0 : std_logic; 
	signal tb_o0_s : std_logic;
    
    signal running : boolean := true;
    signal phase_shift : boolean := false;
    
    -- Observability verification
    constant verif_period : time := (unit_delay / 2);
    signal verif_clk : std_logic := '1';
    signal diff_0 : std_logic_vector (3 downto 0); -- path 0
    signal diff_1 : std_logic_vector (3 downto 0); -- path 1

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

    -- VERIF i3 OBSERVABILITY ------------
    probe_sigs <= (probe_i3,probe_Xor280_o0,probe_Xor2220_o0,probe_Or2200_o0,probe_Nand2300_o0,probe_Nand2320_o0,probe_And2180_o0,probe_Nand2280_o0);
    -- event_on_sigs <= (event_on_i3, event_on_Xor280_o0, event_on_Xor2220_o0, event_on_Or2200_o0, event_on_Nand2300_o0,event_on_Nand2320_o0,event_on_And2180_o0,event_on_Nand2280_o0);

    eds : for i in 0 to 7 generate 
        edi : entity work.event_detect port map (verif_clk, probe_sigs(i), event_on_sigs(i)); 
    end generate eds;

    ca00 : entity work.compare_after generic map (5) port map(verif_clk, event_on_sigs(7), event_on_sigs(6), diff_0(0));
    ca10 : entity work.compare_after generic map (5) port map(verif_clk, event_on_sigs(7), event_on_sigs(5), diff_1(0));

    ca01 : entity work.compare_after generic map (3) port map(verif_clk, diff_0(0), event_on_sigs(5), diff_0(1));
    diff_0(2) <= diff_0(1) and (not probe_And2180_o0);
    ca11 : entity work.compare_after generic map (4) port map(verif_clk, diff_1(0), event_on_sigs(3), diff_1(1));
    diff_1(2) <= diff_1(1) and (not probe_Nand2280_o0);

    ca02 : entity work.compare_after generic map (4) port map(verif_clk, diff_0(2), event_on_sigs(2), diff_0(3));
    ca12 : entity work.compare_after generic map (4) port map(verif_clk, diff_1(2), event_on_sigs(2), diff_1(3));

    verif_observability : process
    begin
        wait until diff_0(3) or diff_1(3);
        wait until rising_edge(nom_clk);
        report "> i3 observable !!";
        finish;
    end process;
    ---------------------------------------
    
    phase_shift <= true after phase;
    nom_clk <= not(nom_clk) after (nom_period/2) when running else nom_clk;
    obs_clk <= not(obs_clk) after (obs_period/2) when running and phase_shift else obs_clk;
    verif_clk <= not(verif_clk) after (verif_period/2) when running and phase_shift else obs_clk;

    tb_o0 <= tb_out(0);
	

    process(obs_clk)
    begin
        if rising_edge(obs_clk) then
            tb_o0_s <= tb_out(0);
			
        else
            tb_o0_s <= tb_o0_s;
			
        end if;
    end process;

    stim : process
        file text_file : text open read_mode is "stim.txt";
        variable text_line : line;
        variable stim_val : std_logic_vector(4 downto 0);
        variable text_val : natural;
    begin
        -- report "Starting simulation...";
        
        while not endfile(text_file) loop
            
            readline(text_file, text_line);
           
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