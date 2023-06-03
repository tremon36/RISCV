library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Right_Shift_1 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end Right_Shift_1;

architecture Behavioral of Right_Shift_1 is

begin

output <= fill_bit & input(31 downto 1) when enable = '1' else input;


end Behavioral;


