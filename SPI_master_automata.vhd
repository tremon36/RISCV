library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_master_automata is
    port(
        reset,clk,spi_sender_empty : in std_logic;
        current_reception: in std_logic_vector(7 downto 0);
        load_byte: out std_logic_vector(7 downto 0);
        enable_load,chip_select: out std_logic;
        enable_initial_program_load_instr: out std_logic;
        enable_initial_program_load_data: out std_logic;
        initial_program_load_addr: out std_logic_vector(17 downto 0);
        initial_program_load_word: out std_logic_vector(7 downto 0);
        reset_pipeline: out std_logic
        );
end SPI_master_automata;

architecture Behavioral of SPI_master_automata is

signal counter_num : std_logic_vector(12 downto 0); -- count to 196 for 1ms
signal reset_counter : std_logic;
signal state : std_logic_vector(5 downto 0);
signal load_new_state,load_new_substate: std_logic;
signal new_state: std_logic_vector(5 downto 0);
signal new_substate: std_logic_vector(1 downto 0);
signal d0,d1,d2,d3,d4,d5,substate_d0,substate_d1 : std_logic;
signal enable_addr_count: std_logic;
signal enable_addr_parallel_load : std_logic;
signal addr_parallel_load: std_logic_vector(17 downto 0);
signal enable_load_addr1,enable_load_addr2,enable_load_addr3 : std_logic;
signal load_addr_1,load_addr_2,load_addr_3: std_logic_vector(7 downto 0);

signal limit_address_1,limit_address_2,limit_address_3,current_address: std_logic_vector(17 downto 0);

signal current_block: std_logic_vector(17 downto 0);
signal enable_block_count: std_logic;

signal substate: std_logic_vector(1 downto 0);

begin

-- State register

ff0: entity work.D_Flip_Flop port map (reset,clk,d0,state(0));
ff1: entity work.D_Flip_Flop port map (reset,clk,d1,state(1));
ff2: entity work.D_Flip_Flop port map (reset,clk,d2,state(2));
ff3: entity work.D_Flip_Flop port map (reset,clk,d3,state(3));
ff4: entity work.D_Flip_Flop port map (reset,clk,d4,state(4));
ff5: entity work.D_Flip_Flop port map (reset,clk,d5,state(5));

d0 <= state(0) when load_new_state = '0' else new_state(0);
d1 <= state(1) when load_new_state = '0' else new_state(1);
d2 <= state(2) when load_new_state = '0' else new_state(2);
d3 <= state(3) when load_new_state = '0' else new_state(3);
d4 <= state(4) when load_new_state = '0' else new_state(4);
d5 <= state(5) when load_new_state = '0' else new_state(5);

-- Substate register

substate_ff0: entity work.D_Flip_Flop port map(reset,clk,substate_d0,substate(0));
substate_ff1: entity work.D_Flip_Flop port map(reset,clk,substate_d1,substate(1));

substate_d0 <= substate(0) when load_new_substate = '0' else new_substate(0);
substate_d1 <= substate(1) when load_new_substate = '0' else new_substate(1);

-- counter for initialization

timer: entity work.counter_13_bit port map(reset_counter or reset,clk,counter_num);

-- Address counter 

addr_counter: entity work.address_counter port map (reset,clk,enable_addr_count,enable_addr_parallel_load,addr_parallel_load,current_address);
block_counter: entity work.address_counter port map (reset,clk,enable_block_count,'0',x"0000" & "00",current_block);

-- Address limit registers 

limit_address_1_reg : entity work.address_register port map(reset,clk,enable_load_addr1,load_addr_1,limit_address_1);
limit_address_2_reg : entity work.address_register port map(reset,clk,enable_load_addr2,load_addr_2,limit_address_2);
limit_address_3_reg : entity work.address_register port map(reset,clk,enable_load_addr3,load_addr_3,limit_address_3);

load_new_substate <= enable_addr_parallel_load;

new_substate <= "10" when state = "011010" else 
                "01" when state = "011001" else 
                "00" when state = "011000" else 
                "11";


load_new_state <= '1' when state = "111111" and counter_num = '0' & x"0C4" else 
                  '1' when state = "111110" and counter_num = '0' & x"050" else 
                  '1' when state = "111101" and spi_sender_empty = '1' else 
                  '1' when state = "111100" and spi_sender_empty = '1' else
                  '1' when state = "111011" and spi_sender_empty = '1' else 
                  '1' when state = "111010" and spi_sender_empty = '1' else
                  '1' when state = "111001" and spi_sender_empty = '1' else
                  '1' when state = "111000" and spi_sender_empty = '1' else
                  '1' when state = "110111" and counter_num = '0' & x"045"    else
                  '1' when state = "110111" and spi_sender_empty = '1' and current_reception /= x"FF" else  -- SD returned state
                  '1' when state = "110110" and spi_sender_empty = '1' else 
                  '1' when state = "110101" and spi_sender_empty = '1' else 
                  '1' when state = "110100" and spi_sender_empty = '1' else 
                  '1' when state = "110011" and spi_sender_empty = '1' else 
                  '1' when state = "110010" and spi_sender_empty = '1' else 
                  '1' when state = "110001" and spi_sender_empty = '1' and current_reception /= x"FF" else -- SD returned state
                  '1' when state = "110001" and counter_num = '0' & x"047"    else 
                  '1' when state = "110000" and spi_sender_empty = '1' and current_reception = x"AA"  else -- echo back  = 1010 1010
                  '1' when state = "101111" and spi_sender_empty = '1' else 
                  '1' when state = "101110" and spi_sender_empty = '1' else
                  '1' when state = "101101" and spi_sender_empty = '1' else
                  '1' when state = "101100" and spi_sender_empty = '1' else
                  '1' when state = "101011" and spi_sender_empty = '1' else
                  '1' when state = "101010" and spi_sender_empty = '1' and current_reception /= x"FF" else 
                  '1' when state = "101010" and counter_num = '0' & x"047"    else 
                  '1' when state = "101001" and spi_sender_empty = '1' else 
                  '1' when state = "101000" and spi_sender_empty = '1' else 
                  '1' when state = "100111" and spi_sender_empty = '1' else 
                  '1' when state = "100110" and spi_sender_empty = '1' else 
                  '1' when state = "100101" and spi_sender_empty = '1' else 
                  '1' when state = "100100" and spi_sender_empty = '1' and current_reception = x"00" else 
                  '1' when state = "100100" and counter_num = '0' & x"047"    else 
                  '1' when state = "100011" and spi_sender_empty = '1' else 
                  '1' when state = "100010" and spi_sender_empty = '1' else 
                  '1' when state = "100001" and spi_sender_empty = '1' else 
                  '1' when state = "100000" and spi_sender_empty = '1' else 
                  '1' when state = "011111" and spi_sender_empty = '1' else 
                  '1' when state = "011110" and spi_sender_empty = '1' and current_reception /= x"FF" else 
                  '1' when state = "011110" and counter_num = '0' & x"047"    else 
                  '1' when state = "011101" and spi_sender_empty = '1' and current_reception = x"FE" else 
                  '1' when state = "011100" and counter_num = '0' & x"01F" else 
                  '1' when state = "011011" and counter_num = '0' & x"03F" else 
                  '1' when state = "011010" and counter_num = '0' & x"05F" else 
                  '1' when state = "011001" and spi_sender_empty = '1' and current_address = limit_address_1 else 
                  '1' when state = "011001" and spi_sender_empty = '1' and counter_num = '0' & x"FFF" else 
                  '1' when state = "011000" and spi_sender_empty = '1' and current_address = limit_address_2 else
                  '1' when state = "011000" and spi_sender_empty = '1' and counter_num = '0' & x"FFF" else 
                  '1' when state = "010110" and spi_sender_empty = '1' and current_address = limit_address_3 else
                  '1' when state = "010110" and spi_sender_empty = '1' and counter_num = '0' & x"FFF" else
                  '1' when state = "010111" and counter_num = '0' & x"00F" else 
                  '0';              
                  

new_state <= "111110" when state = "111111"  else
             "111101" when state = "111110"  else 
             "111100" when state = "111101"  else 
             "111011" when state = "111100"  else
             "111010" when state = "111011"  else
             "111001" when state = "111010"  else
             "111000" when state = "111001"  else 
             "110111" when state = "111000"  else
             "110110" when state = "110111" and spi_sender_empty = '1' and current_reception /= x"FF" else
             "111101" when state = "110111"  else 
             "110101" when state = "110110"  else 
             "110100" when state = "110101"  else 
             "110011" when state = "110100"  else 
             "110010" when state = "110011"  else 
             "110001" when state = "110010"  else 
             "110000" when state = "110001" and spi_sender_empty = '1' and current_reception /= x"FF" else 
             "110110" when state = "110001"  else
             "101111" when state = "110000"  else 
             "101110" when state = "101111"  else 
             "101101" when state = "101110"  else 
             "101100" when state = "101101"  else 
             "101011" when state = "101100"  else 
             "101010" when state = "101011"  else 
             "101001" when state = "101010" and spi_sender_empty = '1' and current_reception /= x"FF" else 
             "101111" when state = "101010" and counter_num = '0' & x"047" else 
             "101000" when state = "101001"  else
             "100111" when state = "101000"  else 
             "100110" when state = "100111"  else 
             "100101" when state = "100110"  else
             "100100" when state = "100101"  else 
             "100011" when state = "100100" and spi_sender_empty = '1' and current_reception = x"00" else 
             "101111" when state = "100100" and counter_num = '0' & x"047" else 
             "100010" when state = "100011"  else 
             "100001" when state = "100010"  else 
             "100000" when state = "100001"  else 
             "011111" when state = "100000"  else 
             "011110" when state = "011111"  else
             "011101" when state = "011110" and spi_sender_empty = '1' and current_reception /= x"FF" else  
             "100011" when state = "011110" and counter_num = '0' & x"047" else 
             "011100" when state = "011101" and spi_sender_empty = '1' and substate = "11" else 
             "011001" when state = "011101" and spi_sender_empty = '1' and substate = "10" else 
             "011000" when state = "011101" and spi_sender_empty = '1' and substate = "01" else 
             "010110" when state = "011101" and spi_sender_empty = '1' and substate = "00" else
             "011011" when state = "011100" and counter_num = '0' & x"01F" else 
             "011010" when state = "011011" and counter_num = '0' & x"03F" else 
             "011001" when state = "011010" and counter_num = '0' & x"05F" else 
             "010111" when state = "011001" and counter_num = '0' & x"FFF" else 
             "011000" when state = "011001" and current_address = limit_address_1 else
             "010111" when state = "011000" and counter_num = '0' & x"FFF" else  
             "010110" when state = "011000" and current_address = limit_address_2 else
             "010111" when state = "010110" and counter_num = '0' & x"FFF" else
             "010101" when state = "010110" and current_address = limit_address_3 else 
             "100011" when state = "010111" else 
             "000000";
            
             

            
             

reset_counter <= '1' when state = "111111" and counter_num = '0' & x"0C4" else 
                 '1' when state = "111000" and load_new_state = '1' else
                 '1' when state = "110010" and load_new_state = '1' else 
                 '1' when state = "101011" and load_new_state = '1' else 
                 '1' when state = "100101" and load_new_state = '1' else 
                 '1' when state = "011111" and load_new_state = '1' else
                 '1' when state = "011101" and load_new_state = '1' else
                 '1' when state = "011001" and load_new_state = '1' and new_state = "010111" else
                 '1' when state = "011000" and load_new_state = '1' and new_state = "010111" else
                 '1' when state = "010110" and load_new_state = '1' and new_state = "010111" else 
                 '0';

load_byte <= x"FF" when state = "111110" else
                                                -- CMD0
             x"40" when state = "111101" else
             x"00" when state = "111100" else
             x"00" when state = "111011" else
             x"00" when state = "111010" else 
             x"00" when state = "111001" else
             x"95" when state = "111000" else 
                                                -- CMD8
             x"48" when state = "110111" and current_reception /= x"FF" else 
             x"00" when state = "110110" else
             x"00" when state = "110101" else
             x"01" when state = "110100" else 
             x"AA" when state = "110011" else
             x"87" when state = "110010" else 
            
             x"48" when state = "110001" and counter_num = '0' & x"047" else 
             
                                                -- CMD55

             x"77" when state = "110000" and current_reception = x"AA" else
             x"00" when state = "101111" else 
             x"00" when state = "101110" else 
             x"00" when state = "101101" else 
             x"00" when state = "101100" else 
             x"01" when state = "101011" else 
             
             x"77" when state = "101010" and counter_num = '0' & x"047" else 

                                                -- ACMD41
             x"69" when state = "101010" and current_reception /= x"FF" else 
             x"40" when state = "101001" else 
             x"00" when state = "101000" else 
             x"00" when state = "100111" else 
             x"00" when state = "100110" else 
             x"01" when state = "100101" else 

             x"77" when state = "100100" and counter_num = '0' &  x"047" else  

                                                -- CMD17

             x"51" when state = "100100" and current_reception = x"00" else 
             x"00" when state = "100011" else 
             x"00" when state = "100010" else 
             x"00" when state = "100001" else 
             current_block(7 downto 0) when state = "100000" else 
             x"01" when state = "011111" else 

            
             x"51" when state = "010111" and counter_num = '0' & x"00F" else -- load another block 
            
             x"FF";

                
enable_load <= '1'              when state = "111110" else 
               spi_sender_empty when state = "111101" else
               spi_sender_empty when state = "111100" else
               spi_sender_empty when state = "111011" else 
               spi_sender_empty when state = "111010" else
               spi_sender_empty when state = "111001" else
               spi_sender_empty when state = "111000" else
               spi_sender_empty when state = "110111" else 
               spi_sender_empty when state = "110110" else
               spi_sender_empty when state = "110101" else
               spi_sender_empty when state = "110100" else
               spi_sender_empty when state = "110011" else
               spi_sender_empty when state = "110010" else
               spi_sender_empty when state = "110001" else
               spi_sender_empty when state = "110000" else
               spi_sender_empty when state = "101111" else
               spi_sender_empty when state = "101110" else
               spi_sender_empty when state = "101101" else
               spi_sender_empty when state = "101100" else 
               spi_sender_empty when state = "101011" else
               spi_sender_empty when state = "101010" else
               spi_sender_empty when state = "101001" else
               spi_sender_empty when state = "101000" else
               spi_sender_empty when state = "100111" else
               spi_sender_empty when state = "100110" else
               spi_sender_empty when state = "100101" else
               spi_sender_empty when state = "100100" else
               spi_sender_empty when state = "100011" else
               spi_sender_empty when state = "100010" else
               spi_sender_empty when state = "100001" else
               spi_sender_empty when state = "100000" else
               spi_sender_empty when state = "011111" else
               spi_sender_empty when state = "011110" else
               spi_sender_empty when state = "011101" else
               spi_sender_empty when state = "011100" else
               spi_sender_empty when state = "011011" else
               spi_sender_empty when state = "011010" else
               spi_sender_empty when state = "011001" else
               spi_sender_empty when state = "011000" else
               spi_sender_empty when state = "010111" else
               spi_sender_empty when state = "010110" else
               '0';
               


chip_select <= '1' when state = "111111" else 
               '1' when state = "111110" else '0';    


-- Addresses and limits

enable_load_addr1 <= '1' when state = "011100" and spi_sender_empty = '1' else '0';
enable_load_addr2 <= '1' when state = "011011" and spi_sender_empty = '1' else '0';
enable_load_addr3 <= '1' when state = "011010" and spi_sender_empty = '1' else '0';

load_addr_1 <= current_reception;
load_addr_2 <= current_reception;
load_addr_3 <= current_reception;

-- Address counter and data output for RISCV CORE

enable_addr_count <= spi_sender_empty when state = "011001" else 
                     spi_sender_empty when state = "011000" else
                     spi_sender_empty when state = "010110" else 
                     '0';

enable_addr_parallel_load <= '1' when state = "011010" and load_new_state = '1' else 
                             '1' when state = "011001" and load_new_state = '1' and current_address = limit_address_1 else
                             '1' when state = "011000" and load_new_state = '1' and current_address = limit_address_2 else
                             '0';

addr_parallel_load <= x"0000" & "00" when state = "011010" else 
                      x"07D0" & "00" when state = "011001" else --  MTVAL (Interrupt Vector Address)
                      x"0000" & "00" when state = "011000" else 
                      x"0000" & "00";

enable_initial_program_load_instr <= '1' when state = "011001" else '1' when state = "011000" else '0';

enable_initial_program_load_data  <= '1' when state = "010110" else '0';

initial_program_load_addr <= current_address;
initial_program_load_word <= current_reception;

reset_pipeline <= '0' when state = "010101" else '1';

-- Block request for sd card

enable_block_count <= '1' when state = "010111" and load_new_state = '1' else '0';


end Behavioral;
