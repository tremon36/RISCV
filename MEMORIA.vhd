library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;


entity Dual_port_RAM is
port(
 RAM_ADDR: in std_logic_vector(14 downto 0); -- Address to write/read RAM
 RAM_ADDR2: in std_logic_vector(14 downto 0); -- Address to write/read RAM, port 2
 RAM_DATA_IN: in std_logic_vector(7 downto 0); -- Data to write into RAM
 RAM_DATA_IN2: in std_logic_vector(7 downto 0); -- Data to write into RAM, port 2
 RAM_WR: in std_logic; -- Write enable
 RAM_WR2: in std_logic; -- Write enable, port 2  
 RAM_CLOCK: in std_logic; -- clock input for RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0); -- Data output of RAM
 RAM_DATA_OUT2: out std_logic_vector(7 downto 0) -- Data output of RAM, port 2
);
end Dual_port_RAM;

architecture Behavioral of Dual_port_RAM is
-- define the new type for the 128x8 RAM 
type RAM_ARRAY is array (0 to 32767) of std_logic_vector (7 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY;

begin

    --process(clk)
--
    --begin
    --
    --if clk'event and clk = '1' then
    --
    --if ena = '1' then
    --
    --if wea = '1' then
    --
    --RAM(conv_integer(addra)) := dia;
    --
    --end if;
    --
    --end if;
    --
    --end if;
    --
    --end process;
    --
    --process(clk)
    --
    --begin
    --
    --if clk'event and clk = '1' then
    --
    --if enb = '1' then
    --
    --dob <= RAM(conv_integer(addrb));
    --
    --end if;
    --
    --end if;
    --
    --end process; 

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

process(RAM_CLOCK)
begin
 if(rising_edge(RAM_CLOCK)) then

 if(RAM_WR2='1') then -- when write enable = 1, 
 RAM(to_integer(unsigned(RAM_ADDR2))) <= RAM_DATA_IN2(7 downto 0);
 else 
 RAM_DATA_OUT2 <= RAM(to_integer(unsigned(RAM_ADDR2)));
 end if;
 end if;

end process;

end Behavioral;