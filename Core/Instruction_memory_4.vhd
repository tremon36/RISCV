library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

-- A 128x8 single-port RAM in VHDL
entity Instruction_memory_4 is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end instruction_memory_4;

architecture Behavioral of instruction_memory_4 is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 127 ) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

begin


--Algoritmo de la burbuja

RAM <= (
  x"ff",x"02",x"00",x"00",
  x"00",x"00",x"00",x"00",
  x"ff",x"00",x"00",x"00",
  x"00",x"30",x"00",x"00",
x"fd",x"00",x"00",x"e4",
x"00",x"c4",x"00",x"00",
x"3c",x"00",x"00",x"32",
x"00",x"00",x"33",x"09",
x"32",x"00",x"00",x"00",
x"0e",x"01",x"07",x"04",
x"02",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"fc",
x"00",x"00",x"0f",x"00",
x"00",x"00",x"00",x"00",
x"00",x"fa",x"00",x"1d",
x"f9",x"00",x"00",x"f0",
x"00",x"ff",x"00",x"52",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",
x"00",x"01",x"02",x"00",
x"00",x"00",x"00",x"00",
x"00",x"00",x"40",x"00",
x"40",x"fd",x"00",x"00",
x"00",x"00",x"01",x"01",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00");
   
   
   
  process(clk) begin
  if rising_edge(clk) then 
 -- Data to be read out 
  RAM_DATA_OUT <= RAM(to_integer(unsigned(RAM_ADDR)));
  end if;
  end process;
end Behavioral;