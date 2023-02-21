library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;



entity Registros is
    port (
        r_dataBus1 : out std_logic_vector (31 downto 0);
        r_dataBus2 : out std_logic_vector (31 downto 0);
        r_dataBus_debug: out std_logic_vector(31 downto 0); -- DEBUG
        w_dataBus : in std_logic_vector (31 downto 0);

        writeAddress : in std_logic_vector (4 downto 0);
        writeEnable : in std_logic;

        readAddress1 : in std_logic_vector (4 downto 0);
        readEnable1 : in std_logic;

        readAddress2 : in std_logic_vector (4 downto 0);
        readEnable2 : in std_logic;
        
        destinationRegister : in std_logic_vector(4 downto 0); 
        destinationEnable : in std_logic;
        
        mainReset : in std_logic;
        mainClock : in std_logic;
        
        r_f1 : out std_logic ;
        r_f2 : out std_logic ;
        r_f3 : out std_logic;

        debug_read_reg_addr: in std_logic_vector(4 downto 0) -- DEBUG
    );
end Registros;

architecture Behavioral of Registros is

type reg_array is array (0 to 31) of std_logic_vector (31 downto 0);
type flag_array is array (0 to 31) of std_logic;
signal regfile: reg_array;
signal flagfile: flag_array;

begin

process(mainClock) begin 
if(rising_edge(mainClock)) then 
if(mainReset = '1') then 
regfile <= (              --reset all registers
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000",
 x"00000000");
flagfile <= ('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');

elsif(writeEnable = '1') then  -- write data and reset flag on write
regfile(to_integer(unsigned(writeAddress))) <= w_dataBus;
flagfile(to_integer(unsigned(writeAddress))) <= '0';
end if;
if(destinationEnable ='1') then 
flagfile(to_integer(unsigned(destinationRegister))) <= '1';
end if;

end if;
end process;

-- Read registers
r_dataBus1 <= regfile(to_integer(unsigned(readAddress1))) when readEnable1 = '1' and readAddress1 /= x"00000000" else x"00000000";
r_dataBus2 <= regfile(to_integer(unsigned(readAddress2))) when readEnable2 = '1' and readAddress2 /= x"00000000" else x"00000000";
r_dataBus_debug <= regfile(to_integer(unsigned(debug_read_reg_addr)));  --DEBUG
-- Read flags
r_f1 <= flagfile(to_integer(unsigned(readAddress1))) when readEnable1 = '1' and readAddress1 /= x"00000000" else '0';
r_f2 <= flagfile(to_integer(unsigned(readAddress2))) when readEnable2 = '1' and readAddress2 /= x"00000000" else '0';
r_f3 <= flagfile(to_integer(unsigned(destinationRegister))) when destinationRegister /= x"00000000" else '0';

   

end Behavioral;