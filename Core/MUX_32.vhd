library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity MUX_32 is
    port(
    selection: in std_logic_vector(4 downto 0);
    valores: in std_logic_vector(31 downto 0);
    salida: out std_logic
    );
end MUX_32;

architecture Behavioral of MUX_32 is

begin

salida <= valores(0) when selection = "00000" else
          valores(1) when selection = "00001" else 
          valores(2) when selection = "00010" else
          valores(3) when selection = "00011" else
          valores(4) when selection = "00100" else
          valores(5) when selection = "00101" else
          valores(6) when selection = "00110" else
          valores(7) when selection = "00111" else
          valores(8) when selection = "01000" else
          valores(9) when selection = "01001" else
          valores(10) when selection = "01010" else
          valores(11) when selection = "01011" else
          valores(12) when selection = "01100" else
          valores(13) when selection = "01101" else
          valores(14) when selection = "01110" else
          valores(15) when selection = "01111" else
          valores(16) when selection = "10000" else
          valores(17) when selection = "10001" else
          valores(18) when selection = "10010" else
          valores(19) when selection = "10011" else
          valores(20) when selection = "10100" else
          valores(21) when selection = "10101" else
          valores(22) when selection = "10110" else
          valores(23) when selection = "10111" else
          valores(24) when selection = "11000" else
          valores(25) when selection = "11001" else
          valores(26) when selection = "11010" else
          valores(27) when selection = "11011" else
          valores(28) when selection = "11100" else
          valores(29) when selection = "11101" else
          valores(30) when selection = "11110" else
          valores(31) when selection = "11111" else
          '0';

end Behavioral;
