library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Right_Shift_16 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end Right_Shift_16;

architecture Behavioral of Right_Shift_16 is

begin

output <= (31 downto 16 => fill_bit) & input(31 downto 16) when enable = '1' else input;


end Behavioral;
