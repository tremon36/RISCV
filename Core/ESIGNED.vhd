

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_signed.ALL;

entity ESIGNED is
  Port (num1,num2:in std_logic_vector(31 downto 0);
        g,e,l: out std_logic );
end ESIGNED;

architecture Behavioral of ESIGNED is

begin
g <= '1' when num1 > num2 else '0';
e <= '1' when num1 = num2 else '0';
l <= '1' when num1 < num2 else '0';

end Behavioral;


