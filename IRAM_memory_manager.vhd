library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity IRAM_memory_manager is
    port(
        RAM_ADDR: in std_logic_vector(31 downto 0);
        ram1_response,ram2_response,ram3_response,ram4_response: in std_logic_vector(7 downto 0);
        RAM_1_ADDR,RAM_2_ADDR,RAM_3_ADDR,RAM_4_ADDR, RAM_RESPONSE: out std_logic_vector(31 downto 0)
        );
end IRAM_memory_manager;

architecture Behavioral of IRAM_memory_manager is

begin
    RAM_1_ADDR <= "00" & RAM_ADDR(31 downto 2);
    RAM_2_ADDR <= "00" & RAM_ADDR(31 downto 2);
    RAM_3_ADDR <= "00" & RAM_ADDR(31 downto 2);
    RAM_4_ADDR <= "00" & RAM_ADDR(31 downto 2);

    RAM_RESPONSE <= ram4_response & ram3_response & ram2_response & ram1_response;


end Behavioral;
