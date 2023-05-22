library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

-- A 128x8 single-port RAM in VHDL
entity Instruction_memory_2 is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end instruction_memory_2;

architecture Behavioral of instruction_memory_2 is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 127 ) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

begin


--Algoritmo de la burbuja

RAM <= (
  x"81",x"02",x"20",x"00",
  x"00",x"00",x"00",x"00",
  x"f0",x"00",x"00",x"00",
  x"04",x"00",x"00",x"00",
  x"f0",x"05",x"22",x"82",
  x"46",x"05",x"06",x"46",
  x"05",x"06",x"02",x"20",
  x"5d",x"0d",x"22",x"00",
  x"2b",x"04",x"04",x"1d",
  x"8d",x"8d",x"56",x"0e",
  x"98",x"56",x"00",x"16",
  x"07",x"77",x"67",x"00",
  x"04",x"0d",x"0b",x"f0",
  x"56",x"07",x"77",x"67",
  x"00",x"00",x"04",x"0d",
  x"0b",x"f0",x"04",x"0d",
  x"f0",x"03",x"02",x"84",
  x"82",x"f0",x"c1",x"01",
  x"24",x"26",x"28",x"2a",
  x"24",x"24",x"05",x"05",
  x"06",x"16",x"08",x"f6",
  x"95",x"15",x"86",x"e5",
  x"06",x"c6",x"85",x"65",
  x"56",x"f0",x"20",x"22",
  x"25",x"25",x"26",x"26",
  x"80",x"00",x"00",x"00",
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