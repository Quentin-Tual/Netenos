library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;


entity <%="#{@netlist_data[:entity_name]}_#{@freq.to_s.split('.').join}_tb"%> is
end entity <%="#{@netlist_data[:entity_name]}_#{@freq.to_s.split('.').join}_tb"%>;

architecture netenos of <%="#{@netlist_data[:entity_name]}_#{@freq.to_s.split('.').join}_tb"%> is

    constant unit_delay : time := 1 ps; -- default already is 1, thus this line is not mandatory
    -- With a 1-unit model, the maximum path length is equivalent to the minimal period for nominal behavior 
    -- Which means minimum period is 4 for a unit_delay value of 1 (default value) 
    constant nom_period : time := (unit_delay * <%=@netlist_data[:crit_path_length]%>);
    constant obs_period : time := (unit_delay * <%=@netlist_data[:crit_path_length]%>) / <%=@freq%>;
    signal nom_clk : std_logic := '1';
    signal obs_clk : std_logic := '1';

    signal tb_in : std_logic_vector(<%=@netlist_data[:ports][:in].length - 1%> downto 0);
    signal tb_out : std_logic_vector(<%=@netlist_data[:ports][:out].length - 1%> downto 0);
    <%=@netlist_data[:ports][:out].collect do |port_name|
        "    signal tb_#{port_name} : std_logic; \n\tsignal tb_#{port_name}_s : std_logic;\n"
    end.join%>

    signal running : boolean := true;

begin

    uut : entity work.<%="#{@netlist_data[:entity_name]}"%>(netenos)
    port map (
<%=@portmap%>
    );

    nom_clk <= not(nom_clk) after (nom_period/2) when running else nom_clk;
    obs_clk <= not(obs_clk) after (obs_period/2) when running else obs_clk;

    process(obs_clk)
    begin
        if rising_edge(obs_clk) then
            <%=@netlist_data[:ports][:out].length.times.collect do |port_nb|
                "tb_o#{port_nb}_s <= tb_out(#{port_nb});\n\t\t\t"
            end.join%>
        else
            <%=@netlist_data[:ports][:out].length.times.collect do |port_nb|
                "tb_o#{port_nb}_s <= tb_o#{port_nb}_s;\n\t\t\t"
            end.join%>
        end if;
    end process;

    stim : process
        file text_file : text open read_mode is "<%=@stim_file_path%>";
        variable text_line : line;
        variable stim_val : std_logic_vector(<%=@netlist_data[:ports][:in].length - 1%> downto 0);
    begin
        -- report "Starting simulation...";
        
        while not endfile(text_file) loop
            
            readline(text_file, text_line);
           
            -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
              next;
            end if;

            -- report text_line.all;
            
            read(text_line, stim_val);
            -- report to_string(stim_val);
            
            for k in 0 to <%=@netlist_data[:ports][:in].length - 1%> loop
                tb_in(k) <= stim_val(k);
            end loop;
                -- -- report to_string(char);
            wait until rising_edge(nom_clk);
            -- read(text_line, char);
            -- tb_i1 <= char;

            -- report to_string(tb_i1);
            -- report text_line.all;
        
        end loop;

        -- wait for period;
        wait for nom_period;
        running <= false;
        -- report "Stopping simulation";
        wait;
    end process;

end architecture netenos;