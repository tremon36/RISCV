library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity JUMP is
 Port (reset,stall,clk:in std_logic;
        instruction:in std_logic_vector(90 downto 0);
        instruction_z:out std_logic_vector(90 downto 0);
        current_pc:in std_logic_vector(31 downto 0);
        mret_pc: in std_logic_vector(31 downto 0);
        pc_actualizado:out std_logic_vector(31 downto 0);
        reset_prev,enable_parallel_cp:out std_logic;
        invalidate: in std_logic;
        invalid_flag_prev_stage: in std_logic;
        invalidate_out: out std_logic;
        is_empty: out std_logic;
        exit_ISR: out std_logic
        );
end JUMP;

architecture Behavioral of JUMP is

component EUNSIGNED 
        port(num1,num2:in std_logic_vector(31 downto 0);
        g,e,l: out std_logic);
end component;
component ESIGNED 
        port(num1,num2:in std_logic_vector(31 downto 0);
        g,e,l: out std_logic);
end component;

component Registro_Intermedio_Decodificado is
    port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(90 downto 0);
        z: out std_logic_vector(90 downto 0)
        );
        
end component Registro_Intermedio_Decodificado;
 
 signal OPCODE: std_logic_vector(6 downto 0);
 signal SUBOPCODE:std_logic_vector(2 downto 0);
 signal gu,eu,lu, g,e,l:std_logic;
 signal num1,num2,signed_offset:std_logic_vector(31 downto 0);
 signal internal_instruction_result: std_logic_vector(90 downto 0);
 signal reset_prev_internal,enable_parallel_cp_internal: std_logic;
 
begin

comparador_u:EUNSIGNED port map(num1,num2,gu,eu,lu);
comparador_s:ESIGNED port map(num1,num2,g,e,l);
registro_salida: Registro_Intermedio_Decodificado port map(reset,stall,clk,internal_instruction_result,instruction_z);
registro_invalid_flag: entity work.bit_register port map(reset,stall,clk,invalidate,invalid_flag_prev_stage,invalidate_out);

is_empty <= '1' when instruction(6 downto 0) = "0000000" else '0'; -- empty flag to control pipeline flow
exit_ISR <= '1' when (SUBOPCODE & OPCODE) = "0001110011" else '0'; -- Exit ISR on MRET

OPCODE <= instruction(6 downto 0);
SUBOPCODE <= instruction(9 downto 7);
num1<=instruction(90 downto 59);
num2<= instruction(58 downto 27);
signed_offset <= std_logic_vector(resize(signed(instruction(26 downto 15) & '0'), 32)); -- extension en signo, añadiendo el bit extra

reset_prev <= reset_prev_internal and not (invalidate or invalid_flag_prev_stage);
enable_parallel_cp <= enable_parallel_cp_internal and not invalidate; -- First compute jump, then check if instruction has been invalidated. Jump computation in the combinational process below

process(clk,reset,OPCODE,instruction,SUBOPCODE,e,signed_offset,current_pc,g,e,l,lu,gu,eu)
begin
   
        if reset = '1' then
            internal_instruction_result <=  x"0000000000000000000000" & "000";
            reset_prev_internal <='0';
            enable_parallel_cp_internal<='0';
            pc_actualizado<=x"00000000";
         else
           
            case OPCODE is 
                when "1100011" => --es BRANCH1
                internal_instruction_result <= instruction;
                
                case SUBOPCODE is
                     when "000" =>--BEQ
                         if e='1' then
                         pc_actualizado <= signed_offset + current_pc;
                         reset_prev_internal <= '1';
                         enable_parallel_cp_internal <= '1';
                         else 
                         reset_prev_internal <='0';
                         enable_parallel_cp_internal<='0';
                         pc_actualizado<=x"00000000";
                         end if;
                     when "001" =>--BNE
                        if e/='1' then
                        reset_prev_internal <= '1';
                        enable_parallel_cp_internal <= '1';
                        pc_actualizado <= signed_offset + current_pc;
                        else
                        reset_prev_internal <='0';
                        enable_parallel_cp_internal<='0';
                        pc_actualizado<=x"00000000";
                        end if;
                      when "100" =>--BLT
                        if l = '1' then
                        reset_prev_internal <= '1';
                        enable_parallel_cp_internal <= '1';
                        pc_actualizado <= signed_offset + current_pc;
                        else
                        reset_prev_internal <='0';
                        enable_parallel_cp_internal<='0';
                        pc_actualizado<=x"00000000";
                        end if;
                      when "101" =>--BGE
                        if g='1' or e='1' then
                        reset_prev_internal <= '1';
                        enable_parallel_cp_internal <= '1';
                        pc_actualizado <= signed_offset + current_pc;
                        else
                        reset_prev_internal <='0';
                        enable_parallel_cp_internal<='0';
                        pc_actualizado<=x"00000000";
                        end if;
                      when "110" =>--BLTU
                        if lu='1' then
                        reset_prev_internal <= '1';
                        enable_parallel_cp_internal <= '1';
                        pc_actualizado <= signed_offset + current_pc;
                        else
                        reset_prev_internal <='0';
                        enable_parallel_cp_internal<='0';
                        pc_actualizado<=x"00000000";
                        end if;       
                      when "111" => --BGEU 
                        if gu = '1' or eu = '1' then 
                        reset_prev_internal <= '1';
                        enable_parallel_cp_internal <= '1';
                        pc_actualizado <= signed_offset + current_pc;
                        else
                        reset_prev_internal <='0';
                        enable_parallel_cp_internal<='0';
                        pc_actualizado<=x"00000000";
                        end if;
                      when others => 
                        reset_prev_internal <='0';
                        enable_parallel_cp_internal<='0';
                        pc_actualizado<=x"00000000";
                      end case;
                --when "1101111" => -- JAL 
                --      pc_actualizado <= instruction(90 downto 59) + current_pc;
                --       reset_prev <= '1';
                --       enable_parallel_cp_internal <= '1';
                --       internal_instruction_result <= instruction;
                when "1100111" => --JALR 
                       pc_actualizado <= (x"FFFFFFF" & "1110") and (instruction(90 downto 59) + std_logic_vector(resize(signed(instruction(26 downto 15)), 32))); --porque este tiene todos los bit
                       reset_prev_internal <= '1';
                       enable_parallel_cp_internal <= '1';
                       internal_instruction_result <= instruction;
                when "1110011" => -- MRET
                      if(SUBOPCODE = "000") then 
                        pc_actualizado <= mret_pc;
                        reset_prev_internal<= '1' ;
                        enable_parallel_cp_internal <= '1';
                        internal_instruction_result <= instruction;
                      else 
                        reset_prev_internal <='0';
                        enable_parallel_cp_internal<='0';
                        pc_actualizado<=x"00000000";
                        internal_instruction_result <= instruction;
                      end if;
                when others => --otras operaciones sin salto
                       reset_prev_internal <='0';
                       enable_parallel_cp_internal<='0';
                       pc_actualizado<=x"00000000";
                       internal_instruction_result <= instruction;
                end case;
            end if; -- stall = '0';
         
        end process;
          
                       

end Behavioral;
