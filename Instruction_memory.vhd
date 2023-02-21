library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

-- A 128x8 single-port RAM in VHDL
entity Instruction_memory is
port(
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(31 downto 0) ;-- Data output of RAM
 byte_amount: in std_logic_vector(1 downto 0)
);
end Instruction_memory;

architecture Behavioral of Instruction_memory is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 127 ) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

signal addr_mas_uno,addr_mas_dos,addr_mas_tres: std_logic_vector(6 downto 0);

begin

addr_mas_uno <= RAM_ADDR + "0000001";
addr_mas_dos <= RAM_ADDR + "0000010";
addr_mas_tres <= RAM_ADDR + "0000011";

--Algoritmo de la burbuja

RAM <= (
x"93",x"07",x"10",x"04",
x"93",x"97",x"87",x"00",
x"93",x"87",x"77",x"01",
x"93",x"97",x"87",x"00",
x"93",x"87",x"d7",x"04",
x"93",x"97",x"87",x"00",
x"93",x"87",x"f7",x"00",
x"23",x"22",x"f0",x"00",
x"83",x"47",x"40",x"00",
x"83",x"47",x"50",x"00",
x"83",x"47",x"60",x"00",
x"83",x"47",x"70",x"00",
x"83",x"57",x"40",x"00",
x"83",x"57",x"60",x"00",
x"83",x"27",x"40",x"00",
x"6f",x"00",x"00",x"00",
x"13",x"06",x"04",x"00",
x"13",x"84",x"03",x"00",
x"93",x"03",x"06",x"00",
x"63",x"48",x"94",x"00",
x"13",x"86",x"04",x"00",
x"93",x"04",x"04",x"00",
x"13",x"04",x"06",x"00",
x"13",x"05",x"15",x"00",
x"e3",x"4e",x"b5",x"fa",
x"23",x"10",x"50",x"00",
x"23",x"11",x"60",x"00",
x"23",x"12",x"70",x"00",
x"23",x"13",x"80",x"00",
x"23",x"14",x"90",x"00",
   x"13",x"06",x"16",x"00",   --00160613
   x"6f",x"f0",x"df",x"ff");  --ffdff06f
   
   
 -- Data to be read out 
 RAM_DATA_OUT <= x"000000" & RAM(to_integer(unsigned(RAM_ADDR))) when byte_amount = "00" else
                 x"0000" & RAM(to_integer(unsigned(addr_mas_uno))) & RAM(to_integer(unsigned(RAM_ADDR))) when byte_amount = "01" else 
                 RAM(to_integer(unsigned(addr_mas_tres))) & RAM(to_integer(unsigned(addr_mas_dos))) & RAM(to_integer(unsigned(addr_mas_uno))) & RAM(to_integer(unsigned(RAM_ADDR)));
end Behavioral;