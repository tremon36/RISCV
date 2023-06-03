library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

-- A 128x8 single-port RAM in VHDL
entity low_capacity_RAM is
port(
 RAM_ADDR: in std_logic_vector(12 downto 0); -- Address to write/read RAM
 RAM_DATA_IN: in std_logic_vector(7 downto 0); -- Data to write into RAM
 RAM_WR: in std_logic; -- Write enable 
 RAM_CLOCK: in std_logic; -- clock input for RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end low_capacity_RAM;

architecture Behavioral of low_capacity_RAM is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 8191) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

begin

process(RAM_CLOCK)
begin
 if(rising_edge(RAM_CLOCK)) then
 if(RAM_WR='1') then -- when write enable = 1, 
 RAM(to_integer(unsigned(RAM_ADDR))) <= RAM_DATA_IN(7 downto 0);
 else 
 RAM_DATA_OUT <= RAM(to_integer(unsigned(RAM_ADDR)));
 end if;
 end if;
end process;
 -- Data to be read out 

end Behavioral;