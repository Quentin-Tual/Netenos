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

entity <%="#{@tb_entity_name}"%> is
end entity <%="#{@tb_entity_name}"%>;

architecture netenos of <%="#{@tb_entity_name}"%> is

    constant unit_delay : time := 1 ps; -- default already is 1, thus this line is not mandatory
    -- With a 1-unit model, the maximum path length is equivalent to the minimal period for nominal behavior 
    -- Which means minimum period is 4 for a unit_delay value of 1 (default value) 
    constant nom_period : time := (unit_delay * <%=@netlist_init_data[:crit_path_length]%>);
    constant obs_period : time := (unit_delay * <%= @freq == "Infinity" ? @netlist_init_data[:crit_path_length] : (@netlist_init_data[:crit_path_length] / @freq).round(3)%>);
    constant phase : time := <%=@phase%> ps;
    signal nom_clk : std_logic := '1';
    signal obs_clk : std_logic := '1';

    signal tb_in : std_logic_vector(<%=@netlist_init_data[:ports][:in].length - 1%> downto 0);
    
    signal tb_out_init : std_logic_vector(<%=@netlist_init_data[:ports][:out].length - 1%> downto 0);
    signal tb_out_alt : std_logic_vector(<%=@netlist_alt_data[:ports][:out].length - 1%> downto 0);
    signal tb_out_diff : std_logic_vector(<%=@netlist_init_data[:ports][:out].length - 1%> downto 0);

    <%=@netlist_init_data[:ports][:out].collect do |port_name|
        "signal tb_#{port_name} : std_logic; \n\t"
    end.join%>

    <%=unless @freq == "Infinity" 
        @netlist_init_data[:ports][:out].collect do |port_name|
            "signal tb_#{port_name}_s : std_logic;\n\t"
        end.join
    end%>

    signal stop_sig_detect, stop_sig_end : boolean := false;
    signal running : boolean := true;
    signal phase_shift : boolean := false;

begin

    ref_unit : entity work.<%="#{@netlist_init_data[:entity_name]}"%>(netenos)
    port map (
<%=@portmap_init%>
    );

    uut : entity work.<%="#{@netlist_alt_data[:entity_name]}"%>(netenos)
    port map (
<%=@portmap_alt%>
    );

    phase_shift <= true after phase;
    nom_clk <= not(nom_clk) after (nom_period/2) when running else nom_clk;
    obs_clk <= not(obs_clk) after (obs_period/2) when running and phase_shift else obs_clk;

    <%=@netlist_init_data[:ports][:out].collect.with_index do |port_name,i|
        "tb_out_diff(#{i}) <= tb_out_init(#{i}) xor tb_out_alt(#{i});\n\t"
    end.join%>

    <%=@netlist_init_data[:ports][:out].collect.with_index do |port_name,i|
        "tb_#{port_name} <= tb_out_diff(#{i});\n\t"
    end.join%>

    process
    begin
        wait until stop_sig_detect = true or stop_sig_end = true;
        wait until nom_clk'event;
        running <= false;
        wait;
    end process; 

    <%=unless @freq == "Infinity"
    "process(obs_clk)
    begin
        if rising_edge(obs_clk) then" end%>
            <%=@freq == "Infinity" ? "" : @netlist_init_data[:ports][:out].collect.with_index do |port_name,i|
                "tb_#{port_name}_s <= tb_out_diff(#{i});\n\t\t\t"
            end.join%>
    stop_sig_detect <=  false when tb_out_diff = "<%= "0" * @netlist_init_data[:ports][:out].length %>" else 
                false when is_X(tb_out_diff) else
                true;
        <%=@freq == "Infinity" ? "" : "else"%>
            <%=@freq == "Infinity" ? "" : @netlist_init_data[:ports][:out].collect.with_index do |port_name,i|
            "\n\t\t\t tb_#{port_name}_s <= tb_#{port_name}_s;\n\t\t\t"
        end.join%>
        <%=@freq == "Infinity" ? "" : "end if;
    end process;"%>

    stim : process
        file text_file : text open read_mode is "<%=@stim_file_path%>";
        variable text_line : line;
        variable stim_val : std_logic_vector(<%=@netlist_init_data[:ports][:in].length - 1%> downto 0);
        variable test_bit_vec : bit_vector(<%=@netlist_init_data[:ports][:in].length - 1%> downto 0);
    begin
        -- report "Starting simulation...";
        
        while not endfile(text_file) and running loop
            
            readline(text_file, text_line);
           
            -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
              next;
            end if;
            
            read(text_line, test_bit_vec);
            stim_val := to_stdlogicvector(test_bit_vec);
            --read(text_line, stim_val);

            for k in 0 to <%=@netlist_init_data[:ports][:in].length - 1%> loop
                tb_in(k) <= stim_val(k);
            end loop;

            wait until rising_edge(nom_clk);
        
        end loop;

        wait for nom_period;
        stop_sig_end <= true;
        -- running <= false;
        -- report "Stopping simulation";
        wait;
        -- std.env.finish;
    end process;

end architecture netenos;