-------------------------------------------------------------------
-- 
--      /!\ Stops whenever an anomaly exists at the outputs (asynchronously /!\
-- 
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity rand_Infinity_tb is
end entity rand_Infinity_tb;

architecture netenos of rand_Infinity_tb is

    constant unit_delay : time := 1 ps; -- default already is 1, thus this line is not mandatory
    -- With a 1-unit model, the maximum path length is equivalent to the minimal period for nominal behavior 
    -- Which means minimum period is 4 for a unit_delay value of 1 (default value) 
    constant nom_period : time := (unit_delay * 43);
    constant obs_period : time := (unit_delay * 43);
    constant phase : time := 0 ps;
    signal nom_clk : std_logic := '1';
    signal obs_clk : std_logic := '1';

    signal tb_in : std_logic_vector(7 downto 0);
    signal previous_input : std_logic_vector(7 downto 0) := (others => 'X');
    
    signal tb_out_init : std_logic_vector(4 downto 0);
    signal tb_out_alt : std_logic_vector(4 downto 0);
    signal tb_out_diff : std_logic_vector(4 downto 0);

    signal tb_o0 : std_logic; 
	signal tb_o1 : std_logic; 
	signal tb_o2 : std_logic; 
	signal tb_o3 : std_logic; 
	signal tb_o4 : std_logic; 
	

    

    signal stop_sig_detect, stop_sig_end : boolean := false;
    signal running : boolean := true;
    signal phase_shift : boolean := false;

    function char_to_std_logic(c: character) return std_logic is
        variable sl: std_logic;
        begin
          case c is
              when '0' => sl := '0';
              when '1' => sl := '1';
              when 'Z' => sl := 'Z';
              when 'U' => sl := 'U';
              when 'X' => sl := 'X';
              when 'W' => sl := 'W';
              when 'L' => sl := 'L';
              when 'H' => sl := 'H';
              when '-' => sl := '-';
              when others => sl := 'X'; -- Valeur inconnue par défaut
          end case;
          return sl;
    end function;

begin

    ref_unit : entity work.rand(netenos)
    port map (
       tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_in(5), 
       tb_in(6), 
       tb_in(7), 
       tb_out_init(0), 
       tb_out_init(1), 
       tb_out_init(2), 
       tb_out_init(3), 
       tb_out_init(4)
    );

    uut : entity work.rand_altered(netenos)
    port map (
       tb_in(0), 
       tb_in(1), 
       tb_in(2), 
       tb_in(3), 
       tb_in(4), 
       tb_in(5), 
       tb_in(6), 
       tb_in(7), 
       tb_out_alt(0), 
       tb_out_alt(1), 
       tb_out_alt(2), 
       tb_out_alt(3), 
       tb_out_alt(4)
    );

    phase_shift <= true after phase;
    nom_clk <= not(nom_clk) after (nom_period/2) when running else nom_clk;
    obs_clk <= not(obs_clk) after (obs_period/2) when running and phase_shift else obs_clk;

    -- ! xor sur le vecteur complet, une seule ligne nécessaire
    tb_out_diff(0) <= tb_out_init(0) xor tb_out_alt(0);
	tb_out_diff(1) <= tb_out_init(1) xor tb_out_alt(1);
	tb_out_diff(2) <= tb_out_init(2) xor tb_out_alt(2);
	tb_out_diff(3) <= tb_out_init(3) xor tb_out_alt(3);
	tb_out_diff(4) <= tb_out_init(4) xor tb_out_alt(4);
	

    tb_o0 <= tb_out_diff(0);
	tb_o1 <= tb_out_diff(1);
	tb_o2 <= tb_out_diff(2);
	tb_o3 <= tb_out_diff(3);
	tb_o4 <= tb_out_diff(4);
	

    process
    begin
        wait until stop_sig_detect = true or stop_sig_end = true;
        wait until nom_clk'event;
        running <= false;
        wait;
    end process; 

    
            
    stop_sig_detect <=  false when tb_out_diff = "00000" else 
                false when is_X(tb_out_diff) else
                true;
        
            
        

    

    stim : process
        file text_file : text open read_mode is "stim.txt";
        variable text_line : line;

        variable stim_val : std_logic_vector(7 downto 0);
    begin
        -- report "Starting simulation...";
        
        while not endfile(text_file) and running loop
            
            readline(text_file, text_line);
           
            -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
              next;
            end if;
            
            read(text_line, stim_val);
            --stim_val := std_logic_vector(to_unsigned(text_val, 8));
            for k in 0 to 7 loop
                tb_in(k) <= stim_val(k);
            end loop;

            wait until rising_edge(nom_clk);
        
        end loop;

        wait for nom_period; -- ! Attendre une dizaine de cycles
        stop_sig_end <= true;
        -- running <= false;
        -- report "Stopping simulation";
        wait;
        -- std.env.finish;
    end process;


    detect : process(tb_out_diff)
        file detections       : text open write_mode is "detections_Infinity.txt";
        variable row          : line;
    begin
        
            if tb_out_diff /= (tb_out_diff'range => '0') and not(is_X(tb_out_diff)) then -- no diff detected if all bits of tb_out_diff vector are '0' -- ! ligne compliquée possible de faire mieux : and tb_out_diff = '0'
            -- ! Eviter is_X, utiliser un reset pour intialiser et ne pas faire le test tant que reset = 1
                -- write(row, cycle_nb);
                -- write(row, string'(","));
                write(row, to_integer(unsigned(tb_in)));
                writeline(detections, row);
            end if;
        
        
    end process;

end architecture netenos;