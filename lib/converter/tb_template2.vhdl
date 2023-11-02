library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

<%=@netlist_data[:ports][:in].collect do |port_name|
        "    signal tb_#{port_name} : std_logic; \n"
    end.join%>
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
            <%=@netlist_data[:ports][:out].collect do |port_name|
                "tb_#{port_name}_s <= tb_#{port_name};\n"
            end.join%>
        else 
            <%=@netlist_data[:ports][:out].collect do |port_name|
                "tb_#{port_name}_s <= tb_#{port_name}_s;\n"
            end.join%>
        end if;
    end process;

    stim : process
    begin
        report "Starting simulation...";
        wait for nom_period;
        -- running <= true;

<%=@stimuli%> 

        -- wait for period;
        wait for nom_period;
        running <= false;
        report "Stopping simulation";
        wait;
    end process;

end architecture netenos;