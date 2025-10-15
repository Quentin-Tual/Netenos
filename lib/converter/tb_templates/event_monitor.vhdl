library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.event_monitor_pkg.all;

entity event_monitor is
generic(nat_nom_period : natural);
port(
		instant_counter : in  natural;
		observed_sig : in  std_logic;
    transi_distrib : out n_array_t(nat_nom_period-1 downto 0)
);
end event_monitor;

architecture netenos of event_monitor is
begin 

  process(observed_sig)
    variable current_value : natural;
    variable normalized_instant : natural;
  begin
    normalized_instant := instant_counter mod nat_nom_period;
    transi_distrib(normalized_instant) <= transi_distrib(normalized_instant) + 1;
  end process;
  
end architecture;