library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use ieee.numeric_std.all;

entity MEMORY is
    port(
        stall,reset,clk: in std_logic;
        memory_dir,memory_to_write: out std_logic_vector(31 downto 0);
        memory_data: in std_logic_vector(31 downto 0);
        rw,stall_prev: out std_logic;
        decoded_instruction: in std_logic_vector(90 downto 0);
        instruction_z: out std_logic_vector(90 downto 0);
        bytes:out std_logic_vector(1 downto 0));
end MEMORY;

architecture Behavioral of MEMORY is

component Registro_Intermedio_Decodificado is
    port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(90 downto 0);
        z: out std_logic_vector(90 downto 0)
        );
        
end component Registro_Intermedio_Decodificado;

 signal OPCODE: std_logic_vector(6 downto 0);
 signal SUBOPCODE:std_logic_vector(2 downto 0);
 signal internal_result: std_logic_vector(90 downto 0);
 
begin

stall_prev <= '0';
OPCODE <= decoded_instruction(6 downto 0);
SUBOPCODE <= decoded_instruction(9 downto 7);

registro_salida: Registro_Intermedio_Decodificado port map(reset,stall,clk,internal_result,instruction_z);

process(clk,reset) 
    begin 
    memory_dir<=decoded_instruction(90 downto 59);

    case OPCODE is 
    when"0000011" =>
        bytes <= "00";
        rw <= '0';
        memory_to_write <=x"00000000"; 
        case SUBOPCODE is 
            when "000" => internal_result <= std_logic_vector(resize(signed(memory_data(7 downto 0)), 32))&decoded_instruction(58 downto 0);
            when "001" => internal_result <= std_logic_vector(resize(signed(memory_data(15 downto 0)), 32))&decoded_instruction(58 downto 0);
            when "010" => internal_result <= memory_data(31 downto 0) & decoded_instruction(58 downto 0);  
            when "100" => internal_result <= x"000000" & memory_data(7 downto 0)&decoded_instruction(58 downto 0);  
            when "101" => internal_result <= x"0000" & memory_data(15 downto 0)&decoded_instruction(58 downto 0);
            when others =>
                         internal_result <= decoded_instruction;                     
        end case;
     when "0100011" =>
        internal_result<= decoded_instruction; 
        case SUBOPCODE is 
            when "000" =>
            rw <= '1';
            memory_to_write<= x"000000"&decoded_instruction(34 downto 27);
            bytes<="00";
            when "001" =>
            rw <= '1';
            memory_to_write<=x"0000"&decoded_instruction(42 downto 27);
            bytes<="01";
            when "010" =>
            rw <= '1';
            memory_to_write<= decoded_instruction(58 downto 27);
            bytes<="10";
            when others =>
            rw <= '0';
            memory_to_write <=x"00000000";
            bytes <= "00";
            end case;
      when others =>
            internal_result <= decoded_instruction;
            memory_to_write <=x"00000000";
            bytes <= "00";
            rw <= '0';  
      end case;     

 end process;

end Behavioral;
