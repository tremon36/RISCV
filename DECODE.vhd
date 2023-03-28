library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;


entity DECODE is
    port(
        reset,stall,clock: in std_logic;
        instruction,data_rs2,data_rs1: in std_logic_vector(31 downto 0);
        rs2_dir,rs1_dir,rd_dir: out std_logic_vector(4 downto 0);
        stall_prev,register_r: out std_logic;
        decoded_instruction: out std_logic_vector(90 downto 0);
        will_write_flag: out std_logic
        
                
        --campos de la instruccion decodificada
        ---operando 1 				          (32 bit) --cuando solo hay un operando, lo metemos aqui
        ---operando 2				          (32 bit) --el inmediato va en el operando dos
        ---inmediato (offset)			      (12 bit) --puede actuar como inmediato en algunos casos para la alu (shifts)
        ---dirección de registro de destino   (5 bit)
        ---SUBOPCODE 			              (3 bit)
        ---OPCODE 				              (7 bit)      
          
        );
end DECODE;

architecture Behavioral of DECODE is


component Registro_Intermedio_Decodificado is
    port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(90 downto 0);
        z: out std_logic_vector(90 downto 0)
        );
        
end component Registro_Intermedio_Decodificado ;
 
signal resultado: std_logic_vector (90 downto 0);
signal OPCODE: std_logic_vector(6 downto 0);
signal SUBOPCODE: std_logic_vector(2 downto 0);

begin

OPCODE <= instruction(6 downto 0);
SUBOPCODE <= instruction(14 downto 12);
stall_prev <= '0';

registro_salida: Registro_Intermedio_Decodificado port map (reset or stall,stall,clock, resultado,decoded_instruction);

process(clock,instruction,data_rs1,data_rs2,reset,stall,OPCODE,SUBOPCODE) begin      
         
    case OPCODE is 
            
          when "0110111" | "0010111" =>  --auipc,lui
              rs1_dir <= "00000";
              rs2_dir <= "00000";
              resultado <= instruction(31 downto 12) & X"000" & X"00000000" & X"000" & instruction(11 downto 7) &"000" & instruction(6 downto 0);
              register_r<='1';
              will_write_flag <= '1' and (not reset) and (not stall);
              rd_dir<= instruction(11 downto 7);
          
          when  "1101111" => --jal
              rs1_dir <= "00000";
              rs2_dir <= "00000";
              resultado <= instruction(31) & instruction(31) & instruction(31) & instruction(31) & instruction(31) & instruction(31) & instruction(31) & instruction(31) & instruction(31) & instruction(31) & instruction(31) & 
                           instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & "0" & x"00000000" & x"000" & instruction(11 downto 7) &  "000" & instruction(6 downto 0);       
               register_r<='1';
               will_write_flag <= '1' and (not reset) and (not stall);
               rd_dir<= instruction(11 downto 7);
                           -- CAMPOS MUY MEZCLADOS, MIRAR DOCUMENTACION--                   
                        
          when "1100111" => --jalr 
              rs1_dir <= instruction(19 downto 15);
              rs2_dir <= "00000";
          
              resultado <= data_rs1 & X"00000000" & instruction(31 downto 20) & instruction(11 downto 7) & "000" & instruction(6 downto 0);
                        --   OP1          OP2           OFFSET                        RD                    SUB           OPCODE
               register_r<='1';
               will_write_flag <= '1' and (not reset) and (not stall);
               rd_dir<= instruction(11 downto 7);
                        
          when "1100011" => -- Todos los del tipo B (BRANCH)
             rs1_dir <= instruction(19 downto 15);
             rs2_dir <= instruction(24 downto 20);
             
              register_r<='1';
              will_write_flag <= '0';
              rd_dir<= "00000";
              resultado <= data_rs1 & data_rs2 & instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 9) & "0" & "00000" & instruction(14 downto 12) & instruction(6 downto 0);
                         --   OP1       OP2      -- OFFSET DESCOLOCADO EN LA INSTRUCCION, Y TRUNCAR A 0---------------------------------------     RD = 0         SUBOPCODE                       OPCODE
         when "0000011" => --Instrucciones del tipo load 
              rs1_dir <= instruction(19 downto 15);
              rs2_dir <= "00000";   
                           
              resultado <= data_rs1 & X"00000000" & instruction(31 downto 20) & instruction (11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
                         --  BASE       UNS                   OFF                       RD                         SUBOPCODE                  OPCODE
              register_r<='1';
              will_write_flag <= '1' and (not reset) and (not stall);
              rd_dir<= instruction(11 downto 7);
         when "0100011" => --Instrucciones del tipo store 
             rs1_dir <= instruction(19 downto 15);
             rs2_dir <= instruction(24 downto 20);
             
              register_r<='1';
              will_write_flag <= '0';
              rd_dir<= "00000";
              resultado <= data_rs1 & data_rs2 & instruction(31 downto 25) & instruction(11 downto 7) & "00000" & instruction(14 downto 12) & instruction(6 downto 0);
                         -- BASE        SRC      --- OFFSET (DIVIDIDO)-------------------------------    RD = 0         SUBOPCODE                  OPCODE  
                         
         when "0010011" => -- Instrucciones de tipo Inmediato en la ALU
            rs1_dir <= instruction(19 downto 15);
            rs2_dir <= "00000"; 
            register_r <= '1';
            will_write_flag <= '1' and (not reset) and (not stall);
            rd_dir <= instruction(11 downto 7);
           if(SUBOPCODE = "001" or SUBOPCODE = "101") then --instrucciones de shift logico (tienen shamt)
              resultado <= data_rs1 & X"000000" & "000" & instruction(24 downto 20) & "00000" & instruction(31 downto 25) & instruction(11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
            --              OP1      -------- OP2 -> shamt extendido sin signo ----   ---------- OFFSET = TAG -----------        RD                             SUBOPCODE                OPCODE
           else                                   
              
              if(SUBOPCODE = "011") then  --Diferenciacion entre los unsigned y los signed, aplicar sign-extend
              resultado <= data_rs1 & X"00000" & instruction(31 downto 20) & X"000" & instruction(11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
                        --  OP1       -------OP2 (UNSIGNED) -------------    OFFSET    ------RD----------------           SUBOPCODE                  OPCODE
              else 
              if(instruction(31) = '1') then 
              resultado <= data_rs1 & X"FFFFF" & instruction(31 downto 20) & X"000" & instruction(11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
                        --  OP1       -------OP2 (SIGNED) ---------------    OFFSET    ------RD----------------           SUBOPCODE                  OPCODE
              else 
              resultado <= data_rs1 & X"00000" & instruction(31 downto 20) & X"000" & instruction(11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
                        --  OP1       -------OP2 (SIGNED) ---------------    OFFSET    ------RD----------------           SUBOPCODE                  OPCODE                    
              end if;
              end if;
           end if;
               
         when "0110011" => -- Instrucciones de la ALU sin operandos inmediatos
              rs1_dir <= instruction(19 downto 15);
              rs2_dir <= instruction(24 downto 20);
              register_r<='1';
              will_write_flag <= '1' and (not reset) and (not stall);
              rd_dir<= instruction(11 downto 7);
              resultado <= data_rs1 & data_rs2 & "00000" & instruction(31 downto 25) & instruction (11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
              --              OP1        OP2     ---------- OFFSET = TAG -----------           RD                          SUBOPCODE                   OPCODE
        
        when "1110011" => -- Instrucciones para CSR (Control status registers)

              case SUBOPCODE is 
              
              when "001" | "010" |"011"  => -- csrrw,csrrs,csrrc
                rs1_dir <= instruction(19 downto 15);
                rs2_dir <= "00000";
                register_r <= '1';
                will_write_flag <=  reset nor stall;
                rd_dir <= instruction(11 downto 7);
                resultado <= data_rs1 & x"00000000" & instruction(31 downto 20) & instruction(11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
                            -- OP1 --  -- NO OP2 --  -- OFFSET = CSR ADDRESS --   --      RD            --   --      SUBOPCODE      --          OPCODE 

              when "101" | "110" | "111" => -- csrrwi,csrrsi,csrrci
                rs1_dir <= "00000";
                rs2_dir <= "00000";
                register_r <= '0';
                will_write_flag <=  reset nor stall;
                rd_dir <= instruction(11 downto 7);
                resultado <= x"000000"&"000"&instruction(19 downto 15) & x"00000000" & instruction(31 downto 20) & instruction(11 downto 7) & instruction(14 downto 12) & instruction(6 downto 0);
                            --              OP1                     --  -- NO OP2 --  -- OFFSET = CSR ADDRESS --   --      RD            --   --      SUBOPCODE      --          OPCODE 
              when others => -- NOP
                rs1_dir <= "00000";
                rs2_dir <= "00000";
                register_r<='0';
                will_write_flag <= '0';
                rd_dir<= "00000";
                resultado <=  x"0000000000000000000000" & "000";
              
              end case;
              
              
        when others => -- NO OPERATION
              rs1_dir <= "00000";
              rs2_dir <= "00000";
              register_r<='0';
              will_write_flag <= '0';
              rd_dir<= "00000";
              resultado <=  x"0000000000000000000000" & "000";

    end case;
        
   end process;

end Behavioral;
