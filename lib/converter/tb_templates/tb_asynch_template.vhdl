library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity <%="#{@netlist_data[:entity_name]}"%> is
end entity <%="#{@netlist_data[:entity_name]}"%>;

architecture netenos of <%="#{@netlist_data[:entity_name]}"%> is

    constant unit_delay : time := 1 ps;
    constant nom_period : time := (unit_delay * <%=@netlist_data[:crit_path_length]%>);

    signal tb_in : std_logic_vector(<%=@netlist_data[:ports][:in].length - 1%> downto 0);
    
    signal tb_out : std_logic_vector(<%=@netlist_data[:ports][:out].length - 1%> downto 0);
   

    <%=@netlist_data[:ports][:out].collect do |port_name|
        "signal tb_#{port_name} : std_logic; \n\tsignal tb_#{port_name}_s : std_logic;\n\t"
    end.join%>

    signal running : boolean := true;
    -- signal phase_shift : boolean := false;

begin

    uut : entity work.<%="#{@instance_name}"%>(netenos)
    port map (
        <%=@portmap%>
    );

    stim : process
       
    begin

        <%curr_e = @stimuli[0]%>
        <%="wait for #{curr_e.timestamp} * unit_delay;"%>
        <%="tb_in(#{curr_e.signal.name[1..]}) <= '#{curr_e.boolean_value}';"%>
    <%@stimuli.each_cons(2) do |prev_e, curr_e| %>
        <%="wait for #{ curr_e.timestamp - prev_e.timestamp} * unit_delay;"%>
        <%="tb_in(#{curr_e.signal.name[1..]}) <= '#{curr_e.boolean_value}';"%>
    <%end%> 

        wait for nom_period;
        running <= false;
        -- report "Stopping simulation";
        wait;
    end process;

end architecture netenos;