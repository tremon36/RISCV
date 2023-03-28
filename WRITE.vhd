

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity WRITE is
 Port ( decode_instruction : in std_logic_vector (90 downto 0);
        reset : in std_logic;
        clk : in std_logic;
        stall_in : in std_logic;
        memory_data_response: in std_logic_vector(31 downto 0);
        csr_data_response: in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector (31 downto 0);
        dir_out : out std_logic_vector (4 downto 0);
        write_enable : out std_logic
  );
end WRITE;

architecture Behavioral of WRITE is

signal OPCODE: std_logic_vector(6 downto 0);
signal SUBOPCODE: std_logic_vector(2 downto 0);

begin

    OPCODE <= decode_instruction(6 downto 0);
    SUBOPCODE <= decode_instruction(9 downto 7);
    
    process (clk,OPCODE,SUBOPCODE,memory_data_response,decode_instruction)
    begin  
        --If its an instruction that needs to write in the register, then acces to the if below.               
        if (OPCODE /= "1100011" and OPCODE /= "0100011" and OPCODE /= "0000000")then
        dir_out <= decode_instruction (14 downto 10);
        write_enable <= '1';   
            if(OPCODE = "0000011") then -- lecturas de memoria
              case SUBOPCODE is 
                when "000" => data_out <= std_logic_vector(resize(signed(memory_data_response(7 downto 0)), 32));
                when "001" => data_out <= std_logic_vector(resize(signed(memory_data_response(15 downto 0)), 32));
                when "010" => data_out <= memory_data_response(31 downto 0);  
                when "100" => data_out <= x"000000" & memory_data_response(7 downto 0);  
                when "101" => data_out <= x"0000" & memory_data_response(15 downto 0);
                when others =>
                              data_out <= decode_instruction (90 downto 59);                   
              end case;
            elsif (OPCODE = "1110011") then  -- lecturas de CSR
                data_out <= csr_data_response;

            else -- otras instrucciones que escriben en registros 
                data_out <= decode_instruction (90 downto 59);           
            end if;

        else 
            write_enable <= '0';
            data_out <= x"00000000";
            dir_out <= "00000";
        end if;    
    end process;

end Behavioral;

