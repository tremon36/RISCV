library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Shift_8 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end Shift_8;

architecture Behavioral of Shift_8 is

begin

output <= input when enable = '0' else input(23 downto 0) & x"00";


end Behavioral;

