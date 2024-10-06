library ieee;
use ieee.std_logic_1164.all;

package tunnel_pkg is

    -- Said unobservable insertion point in verification
    signal probe_i3 : std_logic; 
    
    -- signals to verify 
    signal probe_Xor280_o0 : std_logic;
    signal probe_Xor2220_o0 : std_logic;
    signal probe_Or2200_o0 : std_logic;
    signal probe_Nand2300_o0 : std_logic;
    signal probe_Nand2320_o0 : std_logic;

    -- side-inputs to verify
    signal probe_And2180_o0 : std_logic;
    signal probe_Nand2280_o0 : std_logic;

end package tunnel_pkg;

package body tunnel_pkg is
end package body tunnel_pkg;