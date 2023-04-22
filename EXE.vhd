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
        z : out std_logic_vector (90 downto 0);
        invalidate: in std_logic;
        invalid_flag_prev_stage: in std_logic;
        invalidate_out: out std_logic
        );
end EXE;
architecture Behavioral of EXE is

-- Used to perform logical and arithmetic shifts

component Shifter is
    port( 
        input: in std_logic_vector (31 downto 0);
        shift_amount: in std_logic_vector(4 downto 0);
        left0_right1: in std_logic;
        arithmetic: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
        
end component Shifter;

-- Used to perform comparations (unsigned numbers)

component EUNSIGNED is
  Port (num1,num2:in std_logic_vector(31 downto 0);
        g,e,l: out std_logic );
end component EUNSIGNED;

-- Used to perform comparations (signed numbers)

component ESIGNED is
  Port (num1,num2:in std_logic_vector(31 downto 0);
        g,e,l: out std_logic );
end component ESIGNED;

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
signal output_ins_register: std_logic_vector(90 downto 0);

signal g_u,e_u,l_u,g_s,e_s,l_s : std_logic;

begin

    SM: Shifter port map(op1,op2(4 downto 0),l_r,arithmetic,z_shift);
    comp_signed: ESIGNED port map(op1,op2,g_s,e_s,l_s);
    comp_unsigned: EUNSIGNED port map(op1,op2,g_u,e_u,l_u);

    registro_salida: Registro_Intermedio_Decodificado port map (reset,stall_in,clk,output_ins_register,z);
    registro_invalid_flag: entity work.bit_register port map(reset,stall_in,clk,invalidate,invalid_flag_prev_stage,invalidate_out);

    output_ins_register <= internal_result when (invalidate = '0' and invalid_flag_prev_stage = '0') else op1  & op2 & ofsset & rd & sub_op_code & op_code;

    l_r <= sub_op_code(2);
    arithmetic <= ofsset(5);
    stall_out <= '0';
    
    process (clk,reset,op_code,op1,op2,ofsset,rd,sub_op_code,Instructio_pointer,l_s,l_u,z_shift)
    
        begin 
            --Alu reset;
            if (reset = '1')then

                internal_result <= x"0000000000000000000000" & "000";

            else
            
                case op_code is
                when "0110111" => internal_result  <= op1 & op2 & ofsset & rd & sub_op_code & op_code;                            --LUI
                when "0010111" => internal_result  <= (op1 + Instructio_pointer) & op2 & ofsset & rd & sub_op_code & op_code;        --AUIPC                            --AUIPC Add Upper Imm to PC
                when "1101111" => internal_result <= (Instructio_pointer + x"0000004") & op2 & ofsset & rd & sub_op_code & op_code; --JAL      
                When "1100111" => internal_result <= (Instructio_pointer + x"0000004") & op2 & ofsset & rd & sub_op_code & op_code; --JALR
                when "0000011" | "0100011" => internal_result <= (op1  + std_logic_vector(resize(signed(ofsset), 32))) & op2 & ofsset & rd & sub_op_code & op_code;   -- LOADS Y STORES
                when "0010011" =>
                    case sub_op_code is 
                        when "000" => internal_result <= (op1 + op2) & op2 & ofsset & rd & sub_op_code & op_code;                       --ADDI
                        when "010"  =>                                         --SLTI
                            if(l_s = '1') then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code;
                            end if;
                        When "011" =>                                           --SLTIU 
                            if(l_u = '1') then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code;
                            end if;
                        when "100" => internal_result <= (op1 xor op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --XORI 
                        when "110" => internal_result  <= (op1 or op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --ORI
                        when "111" => internal_result  <= (op1 and op2) & op2 & ofsset & rd & sub_op_code & op_code;                    --ANDI
                        when "001" | "101" => internal_result <= z_shift & op2 & ofsset & rd & sub_op_code & op_code;
                        when others => internal_result <= op1  & op2 & ofsset & rd & sub_op_code & op_code;  
                     end case;
                when "0110011" =>
                    case sub_op_code is
                        when "001" | "101" => internal_result <= z_shift & op2 & ofsset & rd & sub_op_code & op_code;    
                        when "000" =>                                        --ADD & SUB 
                            if(ofsset (5) = '0')then  internal_result <= (op1 + op2) & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= (op1 - op2) & op2 & ofsset & rd & sub_op_code & op_code;
                            end if;
                        when "010"  =>                                         --SLT
                            if(l_s = '1') then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code;
                            end if;
                        When "011" =>                                           --SLTU 
                            if(l_u = '1') then internal_result <= x"00000001" & op2 & ofsset & rd & sub_op_code & op_code;
                            else internal_result <= x"00000000" & op2 & ofsset & rd & sub_op_code & op_code;
                            end if;
                        when "100" => internal_result <= (op1 xor op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --XOR
                        when "110" => internal_result <= (op1 or op2) & op2 & ofsset & rd & sub_op_code & op_code;                      --OR
                        when "111" => internal_result <= (op1 and op2) & op2 & ofsset & rd & sub_op_code & op_code;                     --AND
                        when others => internal_result <= op1  & op2 & ofsset & rd & sub_op_code & op_code;
                    end case;
                    when others => 
                    internal_result <= op1  & op2 & ofsset & rd & sub_op_code & op_code;
                end case;
                
           end if;
   
    end process ;

end Behavioral;