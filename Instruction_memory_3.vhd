library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

-- A 128x8 single-port RAM in VHDL
entity Instruction_memory_3 is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end instruction_memory_3;

architecture Behavioral of instruction_memory_3 is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 127 ) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

begin


--Algoritmo de la burbuja

RAM <= (
  x"00",x"00",x"12",x"20",
  x"00",x"73",x"13",x"00",
  x"5f",x"00",x"00",x"00",
  x"14",x"20",x"00",x"00",
  x"df",x"b5",x"01",x"12",
  x"55",x"10",x"36",x"a0",
  x"10",x"36",x"30",x"53",
  x"15",x"ad",x"a3",x"c0",
  x"43",x"00",x"a0",x"00",
  x"fd",x"ad",x"bd",x"94",
  x"0b",x"46",x"dd",x"46",
  x"1d",x"f7",x"d7",x"ed",
  x"14",x"1d",x"10",x"df",
  x"86",x"0d",x"07",x"d7",
  x"ed",x"cd",x"14",x"2d",
  x"00",x"5f",x"00",x"1d",
  x"9f",x"08",x"00",x"72",
  x"12",x"9f",x"01",x"01",
  x"a1",x"b1",x"c1",x"d1",
  x"01",x"41",x"00",x"00",
  x"10",x"06",x"06",x"c4",
  x"15",x"15",x"06",x"15",
  x"00",x"85",x"85",x"15",
  x"16",x"5f",x"a1",x"b1",
  x"81",x"c1",x"01",x"41",
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