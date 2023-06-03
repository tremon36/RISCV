library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

-- A 128x8 single-port RAM in VHDL
entity IRAM is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end IRAM;

architecture Behavioral of IRAM is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 127 ) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

begin


--Algoritmo de la burbuja

RAM <= (
x"93",x"07",x"d0",x"04",
x"13",x"08",x"40",x"00",
x"ef",x"00",x"00",x"01",
x"23",x"24",x"20",x"01",
x"83",x"28",x"80",x"00",
x"6f",x"00",x"00",x"00",
x"93",x"78",x"18",x"00",
x"63",x"04",x"10",x"01",
x"33",x"09",x"f9",x"00",
x"93",x"97",x"17",x"00",
x"13",x"58",x"18",x"00",
x"e3",x"16",x"08",x"fe",
x"67",x"80",x"00",x"00",
x"67",x"80",x"00",x"00",
x"e3",x"16",x"08",x"fe",
x"67",x"80",x"00",x"00",
   x"13",x"06",x"04",x"00",-- 0x40: 
   x"13",x"84",x"03",x"00",-- 0x44: 
   x"93",x"03",x"06",x"00",-- 0x48: 
   x"63",x"48",x"94",x"00",-- 0x4C: 
   x"13",x"86",x"04",x"00",-- 0x50: 
   x"93",x"04",x"04",x"00",-- 0x54: 
   x"13",x"04",x"06",x"00",-- 0x58: 
   x"13",x"05",x"15",x"00",-- 0x5C: 
   x"e3",x"4e",x"b5",x"fa",
   x"23",x"10",x"50",x"00",
   x"23",x"11",x"60",x"00",
   x"23",x"12",x"70",x"00",
   x"23",x"13",x"80",x"00",
   x"23",x"14",x"90",x"00",
   x"13",x"06",x"16",x"00",   --00160613
   x"6f",x"f0",x"df",x"ff");  --ffdff06f
   
   
  process(clk) begin
  if rising_edge(clk) then 
 -- Data to be read out 
  RAM_DATA_OUT <= RAM(to_integer(unsigned(RAM_ADDR)));
  end if;
  end process;
end Behavioral;