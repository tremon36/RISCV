library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

-- A 128x8 single-port RAM in VHDL
entity Instruction_memory is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end instruction_memory;

architecture Behavioral of instruction_memory is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 127 ) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

begin


--Algoritmo de la burbuja

RAM <= (
  x"37",x"13",x"13",x"93",
  x"13",x"93",x"93",x"63",
  x"93",x"23",x"23",x"23",
  x"23",x"93",x"23",x"23",
  x"6f",x"33",x"b7",x"93",
  x"63",x"93",x"13",x"63",
  x"93",x"13",x"93",x"23",
  x"13",x"33",x"23",x"ef",
  x"83",x"13",x"93",x"b7",
  x"93",x"b3",x"63",x"63",
  x"63",x"93",x"23",x"93",
  x"03",x"13",x"33",x"a3",
  x"13",x"13",x"93",x"6f",
  x"93",x"03",x"13",x"33",
  x"23",x"a3",x"13",x"13",
  x"93",x"6f",x"13",x"13",
  x"6f",x"b7",x"93",x"e3",
  x"93",x"6f",x"37",x"13",
  x"23",x"23",x"23",x"23",
  x"03",x"83",x"13",x"93",
  x"13",x"13",x"63",x"b3",
  x"93",x"13",x"63",x"93",
  x"93",x"63",x"b3",x"13",
  x"13",x"6f",x"23",x"23",
  x"03",x"83",x"03",x"83",
  x"67",x"00",x"00",x"00",
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