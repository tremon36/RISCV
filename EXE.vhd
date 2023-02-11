library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

entity EXE is
  Port (op1,op2 : in std_logic_vector (31 downto 0);-- in case inmediate intruction, the inmediate op gets fech into the op2.
        ofsset : in std_logic_vector (11 downto 0);
        rd : in std_logic_vector (4 downto 0);
        sub_op_code : in std_logic_vector (2 downto 0);
        op_code : in std_logic_vector (6 downto 0);
        clk : in std_logic;
        reset, stall_in : in std_logic;
        Instructio_pointer : in std_logic_vector (31 downto 0);
        stall_out : out std_logic;
        z : out std_logic_vector (90 downto 0)
        );
end EXE;
architecture Behavioral of EXE is

component Shifter is
    port( 
        input: in std_logic_vector (31 downto 0);
        shift_amount: in std_logic_vector(4 downto 0);
        left0_right1: in std_logic;
        arithmetic: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
        
end component Shifter;

component Registro_Intermedio_Decodificado is
    port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(90 downto 0);
        z: out std_logic_vector(90 downto 0)
        );
        
end component Registro_Intermedio_Decodificado ;

signal load : std_logic_vector (90 downto 0);
signal internal_result: std_logic_vector(90 downto 0);
signal arithmetic : std_logic;
signal l_r : std_logic;
signal z_shift : std_logic_vector (31 downto 0);
signal end_of_Shift : std_logic;
signal debug_ERROR : std_logic ;                --Internal debugging signal. 

signal Shift_Module_In_Use : std_logic;

begin

    SM: Shifter port map(op1,op2(4 downto 0),l_r,arithmetic,z_shift);
    registro_salida: Registro_Intermedio_Decodificado port map (reset,stall_in,clk,internal_result,z);

    l_r <= sub_op_code(2);
    arithmetic <= ofsset(5);
    stall_out <= '0';
    
    process (clk)
    
        begin 
            --Alu reset;
            if (reset = '1')then

                internal_result <= x"0000000000000000000000" & "000";

            else
            
                case op_code is
                when "0110111" => internal_result  <= op2 & op2 & ofsset & rd & sub_op_code & op_code;                            --LUI
                when "0010111" => internal_result  <= (op1 + Instructio_pointer) & op2 & ofsset & rd & sub_op_code & op_code;        --AUIPC                            --AUIPC Add Upper Imm to PC
                when "1101111" => internal_result <= (Instructio_pointer + x"0000004") & op2 & ofsset & rd & sub_op_code & op_code; --JAL      
                When "1100111" => internal_result <= (Instructio_pointer + x"0000004") & op2 & ofsset & rd & sub_op_code & op_code; --JALR
                when "0000011" | "0100011" => internal_result <= (op1  + std_logic_vector(resize(signed(ofsset), 32))) & op2 & ofsset & rd & sub_op_code & op_code;   -- LOADS Y STORES
                when "0010011" =>
                    case sub_op_code is 
                        when "000" => internal_result <= (op1 + op2) & op2 & ofsset & rd & sub_op_code & op_code;                       --ADDI
                        when "010"  =>                                         --SLTI
                            if (op1(31) = '1')then
                                if(op2(31) = '1')then                     --los dos son neativos.
                                    if (op1 > op2)then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                                    else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code;
                                    end if;
                                else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;               --op1<0, op2>0;
                                end if;
                            else                                          
                                if(op2(31) = '1')then                     --op1>0, op2<0;
                                    internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code ;
                                else                                      --op1>0, op2>0;
                                    if (op1 > op2) then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                                    else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;
                                    end if;
                                end if;   
                            end if; 
                            if (op1 > op2)then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;
                            end if;
                        When "011" =>                                           --SLTIU 
                            if (op1 > op2)then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;
                            end if;  
                        when "100" => internal_result <= (op1 xor op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --XORI 
                        when "110" => internal_result  <= (op1 or op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --ORI
                        when "111" => internal_result  <= (op1 and op2) & op2 & ofsset & rd & sub_op_code & op_code;                    --ANDI
                        when "001" | "101" => internal_result <= z_shift & op2 & ofsset & rd & sub_op_code & op_code;  
                        when others => debug_ERROR <= '1';
                     end case;
                when "0110011" =>
                    case sub_op_code is
                        when "001" | "101" => internal_result <= z_shift & op2 & ofsset & rd & sub_op_code & op_code;    
                        when "000" =>                                        --ADD & SUB 
                            if(ofsset (5) = '0')then  internal_result <= (op1 + op2) & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= (op1 - op2) & op2 & ofsset & rd & sub_op_code & op_code;
                            end if;
                        when "010"  =>                                         --SLT
                            if (op1(31) = '1')then
                                if(op2(31) = '1')then                     --los dos son neativos.
                                    if (op1 > op2)then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                                    else internal_result<= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;
                                    end if;
                                else internal_result<= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;               --op1<0, op2>0;          
                                end if;
                            else                                          
                                if(op2(31) = '1')then                     --op1>0, op2<0;
                                    internal_result<= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                                else                                      --op1>0, op2>0;
                                    if (op1 > op2)then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                                    else internal_result<= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;
                                    end if;
                                end if;   
                            end if; 
                            if (op1 > op2)then internal_result<= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result<= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;
                            end if;
                        When "011" =>                                           --SLTU 
                            if (op1 > op2)then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code ;
                            end if; 
                        when "100" => internal_result <= (op1 xor op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --XOR
                        when "110" => internal_result <= (op1 or op2) & op2 & ofsset & rd & sub_op_code & op_code;                      --OR
                        when "111" => internal_result <= (op1 and op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --AND
                        when others => debug_ERROR <= '1';
                    end case;
                    when others => 
                    debug_ERROR <= '1';
                    internal_result <= op1  & op2 & ofsset & rd & sub_op_code & op_code;
                end case;
                
           end if;
   
    end process ;

end Behavioral;