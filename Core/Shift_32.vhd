library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Shift_16 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end Shift_16;

architecture Behavioral of Shift_16 is

begin

output <= input when enable = '0' else input(15 downto 0) & x"0000";


end Behavioral;
