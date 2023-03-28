library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use ieee.numeric_std.all;

entity MEMORY is
    port(
        stall,reset,clk: in std_logic;
        memory_dir,memory_to_write: out std_logic_vector(31 downto 0);
        rw,stall_prev: out std_logic;
        decoded_instruction: in std_logic_vector(90 downto 0);
        instruction_z: out std_logic_vector(90 downto 0);
        bytes:out std_logic_vector(1 downto 0);

        csr_address: out std_logic_vector(11 downto 0);
        csr_write_enable: out std_logic;
        csr_bitmask: out std_logic_vector(31 downto 0);
        csr_write_data: out std_logic_vector(31 downto 0)
        
        );
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
memory_dir<=decoded_instruction(90 downto 59);

internal_result <= decoded_instruction;

process(clk,reset,decoded_instruction,SUBOPCODE,OPCODE) 
    begin 
    

    case OPCODE is 
    when"0000011" => -- las lecturas de memoria las envia directamente la memoria RAM a write, evitar ciclo de latencia de lectura
        bytes <= SUBOPCODE(1 downto 0);
        rw <= '0';
        memory_to_write <=x"00000000";  
                            
    when "0100011" =>
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
            memory_to_write <=x"00000000";
            bytes <= "00";
            rw <= '0';  
    end case;     

 end process;

process(clk,OPCODE,SUBOPCODE) begin -- CSR process. las lecturas de los CSR, como las de memoria, se mandan directamente a write para evitar el ciclo de latencia
    if(OPCODE = "1110011") then 
        csr_address <= decoded_instruction(26 downto 15);
        case SUBOPCODE(1 downto 0) is 
            when "01" => 
                csr_write_enable <= '1';
                csr_write_data <= decoded_instruction(90 downto 59);
                csr_bitmask <= x"FFFFFFFF";
            when "10" => 
                csr_write_enable <= '1';
                csr_write_data <=x"FFFFFFFF";
                csr_bitmask <= decoded_instruction(90 downto 59);
            when "11" => 
                csr_write_enable <= '1';
                csr_write_data <= x"00000000";
                csr_bitmask <= decoded_instruction(90 downto 59);
            when others =>
                csr_write_enable <= '0';
                csr_write_data <= x"00000000";
                csr_bitmask <= x"00000000";

        end case;
    else 
        csr_write_enable <= '0';
        csr_write_data <= x"00000000";
        csr_bitmask <= x"00000000";
    end if;
end process;

end Behavioral;
