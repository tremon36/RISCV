

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity WRITE is
 Port ( decode_instruction : in std_logic_vector (90 downto 0);
        reset : in std_logic;
        clk : in std_logic;
        stall_in : in std_logic;
        data_out : out std_logic_vector (31 downto 0);
        dir_out : out std_logic_vector (4 downto 0);
        write_enable : out std_logic
  );
end WRITE;

architecture Behavioral of WRITE is


begin
    
    process (clk)
    begin  
        --If its an instruction that needs to write in the register, then acces to the if bellow.               
        if (decode_instruction(6 downto 0) /= "1100011" and decode_instruction(6 downto 0) /= "0100011" and decode_instruction(6 downto 0) /= "0000000")then
            data_out <= decode_instruction (90 downto 59);
            dir_out <= decode_instruction (14 downto 10);
            write_enable <= '1';
            
        else 
            write_enable <= '0';
            data_out <= x"00000000";
            dir_out <= "00000";
        end if;    
    end process;

end Behavioral;

