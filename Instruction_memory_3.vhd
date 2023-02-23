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
x"c0",--x"07",x"40",x"00",  
x"00",--x"01",x"00",x"00",
x"f1",--x"22",x"f1",x"00",
x"80",--x"00",x"80",x"00",
x"00",--x"00",x"00",x"00",
x"11",--x"20",x"11",x"00",
x"41",--x"27",x"41",x"00",
x"00",--x"0c",x"00",x"00",
x"07",--x"98",x"07",x"00",
x"10",--x"0c",x"10",x"00",
x"00",--x"08",x"00",x"00",
x"01",--x"24",x"01",x"01",
x"10",--x"08",x"10",x"00",
x"07",--x"98",x"07",x"01",
x"10",--x"0c",x"10",x"00",
x"10",--x"08",x"10",x"00",
x"01",--x"24",x"01",x"01",
x"10",--x"0d",x"10",x"00",
x"ac",--x"88",x"ac",x"05",
x"f7",--x"8c",x"f7",x"ff",
x"91",--x"22",x"91",x"01",
x"c1",--x"01",x"c1",x"00",
x"91",--x"22",x"91",x"01",
x"9f",--x"f0",x"9f",x"fb",
x"81",--x"2c",x"81",x"00",
x"41",--x"01",x"41",x"ff",
x"41",--x"2d",x"41",x"00",
x"fd",--x"0d",x"fd",x"ff",
x"91",--x"22",x"91",x"01",
x"c1",--x"01",x"c1",x"00",
x"a1",--x"22",x"a1",x"01",
x"9f",--x"f0",x"9f",x"f9",
x"81",--x"2c",x"81",x"00",
x"41",--x"01",x"41",x"ff",
x"41",--x"2d",x"41",x"00",
x"ac",--x"8c",x"ac",x"01",
x"91",--x"24",x"91",x"01",
x"01",--x"20",x"01",x"00",
x"00",--x"80",x"00",x"00",
x"07",x"40",x"00",
x"01",x"00",x"00",
x"22",x"f1",x"00",
x"00",x"80",x"00",
x"00",x"00",x"00",
x"20",x"11",x"00",
x"27",x"41",x"00",
x"0c",x"00",x"00",
x"98",x"07",x"00",
x"0c",x"10",x"00",
x"08",x"00",x"00",
x"24",x"01",x"01",
x"08",x"10",x"00",
x"98",x"07",x"01",
x"0c",x"10",x"00",
x"08",x"10",x"00",
x"24",x"01",x"01",
x"0d",x"10",x"00",
x"88",x"ac",x"05",
x"8c",x"f7",x"ff",
x"22",x"91",x"01",
x"01",x"c1",x"00",
x"22",x"91",x"01",
x"f0",x"9f",x"fb",
x"2c",x"81",x"00",
x"01",x"41",x"ff",
x"2d",x"41",x"00",
x"0d",x"fd",x"ff",
x"22",x"91",x"01",
x"01",x"c1");
   
   
  process(clk) begin
  if rising_edge(clk) then 
 -- Data to be read out 
  RAM_DATA_OUT <= RAM(to_integer(unsigned(RAM_ADDR)));
  end if;
  end process;
end Behavioral;