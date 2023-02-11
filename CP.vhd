
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity CP is
    port(
        count,reset,enable_parallel_load,clock:in std_logic;
        current_num:out std_logic_vector(31 downto 0);
        load: in std_logic_vector(31 downto 0)
        );
      
end CP;

architecture Behavioral of CP is
signal num1: std_logic_vector(31 downto 0);

begin
current_num <= num1;
    process (clock)
    begin
        if (clock = '1' and clock'event)then 
            if(reset = '1') then num1 <= X"00000000";
            else if(enable_parallel_load = '1') then num1 <= load;
            else if(count = '1' ) then num1 <= num1 + "100";
                 end if;
                 end if;
            end if;
        end if;
    end process;

end Behavioral;
