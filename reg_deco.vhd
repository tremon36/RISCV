library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity reg_deco is Port (
    dir : in std_logic_vector(4 downto 0);
    z : out std_logic_vector (31 downto 0);
    enable : in std_logic 
);
end reg_deco;

architecture Behavioral of reg_deco is
begin 

    z <= "00000000000000000000000000000001" when dir = "00000" and enable = '1' else
    "00000000000000000000000000000010" when dir = "00001" and enable = '1' else
    "00000000000000000000000000000100" when dir = "00010" and enable = '1' else
    "00000000000000000000000000001000" when dir = "00011" and enable = '1' else
    "00000000000000000000000000010000" when dir = "00100" and enable = '1' else
    "00000000000000000000000000100000" when dir = "00101" and enable = '1' else
    "00000000000000000000000001000000" when dir = "00110" and enable = '1' else
    "00000000000000000000000010000000" when dir = "00111" and enable = '1' else
    "00000000000000000000000100000000" when dir = "01000" and enable = '1' else
    "00000000000000000000001000000000" when dir = "01001" and enable = '1' else
    "00000000000000000000010000000000" when dir = "01010" and enable = '1' else
    "00000000000000000000100000000000" when dir = "01011" and enable = '1' else
    "00000000000000000001000000000000" when dir = "01100" and enable = '1' else
    "00000000000000000010000000000000" when dir = "01101" and enable = '1' else
    "00000000000000000100000000000000" when dir = "01110" and enable = '1' else
    "00000000000000001000000000000000" when dir = "01111" and enable = '1' else
    "00000000000000010000000000000000" when dir = "10000" and enable = '1' else
    "00000000000000100000000000000000" when dir = "10001" and enable = '1' else
    "00000000000001000000000000000000" when dir = "10010" and enable = '1' else
    "00000000000010000000000000000000" when dir = "10011" and enable = '1' else
    "00000000000100000000000000000000" when dir = "10100" and enable = '1' else
    "00000000001000000000000000000000" when dir = "10101" and enable = '1' else
    "00000000010000000000000000000000" when dir = "10110" and enable = '1' else
    "00000000100000000000000000000000" when dir = "10111" and enable = '1' else
    "00000001000000000000000000000000" when dir = "11000" and enable = '1' else
    "00000010000000000000000000000000" when dir = "11001" and enable = '1' else
    "00000100000000000000000000000000" when dir = "11010" and enable = '1' else
    "00001000000000000000000000000000" when dir = "11011" and enable = '1' else
    "00010000000000000000000000000000" when dir = "11100" and enable = '1' else
    "00100000000000000000000000000000" when dir = "11101" and enable = '1' else
    "01000000000000000000000000000000" when dir = "11110" and enable = '1' else
    "10000000000000000000000000000000" when dir = "11111" and enable = '1' else
    "00000000000000000000000000000001" ;
    
    
end Behavioral;
