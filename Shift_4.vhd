library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Shift_4 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end Shift_4;

architecture Behavioral of Shift_4 is

begin

output <= input when enable = '0' else input(27 downto 0) & x"0";


end Behavioral;