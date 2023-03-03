library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;


entity memory_manager is
    port(
        clk,stall,reset: in std_logic;
        rw  : in std_logic;
        byte_amount : in std_logic_vector(1 downto 0);
        write_data: in std_logic_vector(31 downto 0);
        requested_address: in std_logic_vector(17 downto 0);
        response_data1,response_data2,response_data3,response_data4 : in std_logic_vector(7 downto 0);
        lowc_ram_1_response,lowc_ram_2_response,lowc_ram_3_response,lowc_ram_4_response: in std_logic_vector(7 downto 0);
        write_data1,write_data2,write_data3,write_data4 : out std_logic_vector(7 downto 0);
        request_adress_forward: out std_logic_vector(14 downto 0);
        data_output_32_bit: out std_logic_vector(31 downto 0);
        write_data_enable: out std_logic_vector(7 downto 0) -- lowest 4 high capacity, highest 4 low capacity
    );
end memory_manager;

architecture Behavioral of memory_manager is

signal byte_amount_delay_register_output,lower_two_bit_delay_register_output: std_logic_vector(1 downto 0);
signal merge_ram_1_response,merge_ram_2_response,merge_ram_3_response,merge_ram_4_response: std_logic_vector(7 downto 0);
signal lower_two_bit: std_logic_vector(1 downto 0);
signal highest_bit,highest_bit_delay: std_logic;

begin

    lower_two_bit <= requested_address(1 downto 0);
    highest_bit <= requested_address(17);

    request_adress_forward <= requested_address(16 downto 2);

    merge_ram_1_response <= response_data1 when highest_bit_delay = '0' else lowc_ram_1_response;
    merge_ram_2_response <= response_data2 when highest_bit_delay = '0' else lowc_ram_2_response;
    merge_ram_3_response <= response_data3 when highest_bit_delay = '0' else lowc_ram_3_response;
    merge_ram_4_response <= response_data4 when highest_bit_delay = '0' else lowc_ram_4_response;


    data_output_32_bit <= x"000000" & merge_ram_1_response when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "00" else
                          x"000000" & merge_ram_2_response when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "01" else
                          x"000000" & merge_ram_3_response when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "10" else
                          x"000000" & merge_ram_4_response when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "11" else
                          x"0000" & merge_ram_2_response & merge_ram_1_response when byte_amount_delay_register_output = "01" and lower_two_bit_delay_register_output = "00" else
                          x"0000" & merge_ram_4_response & merge_ram_3_response when byte_amount_delay_register_output = "01" and lower_two_bit_delay_register_output = "10" else
                          merge_ram_4_response & merge_ram_3_response & merge_ram_2_response & merge_ram_1_response;  

    write_data_enable <= "00000001" when byte_amount = "00" and rw = '1' and lower_two_bit = "00" and highest_bit = '0' else 
                         "00000010" when byte_amount = "00" and rw = '1' and lower_two_bit = "01" and highest_bit = '0' else 
                         "00000100" when byte_amount = "00" and rw = '1' and lower_two_bit = "10" and highest_bit = '0' else 
                         "00001000" when byte_amount = "00" and rw = '1' and lower_two_bit = "11" and highest_bit = '0' else 
                         "00000011" when byte_amount = "01" and rw = '1' and lower_two_bit = "00" and highest_bit = '0' else -- store halfword must be 2 byte aligned
                         "00001100" when byte_amount = "01" and rw = '1' and lower_two_bit = "10" and highest_bit = '0' else 
                         "00001111" when rw = '1' and highest_bit = '0'                                                 else 
                          
                         "00010000" when byte_amount = "00" and rw = '1' and lower_two_bit = "00" else -- now low capacity RAM
                         "00100000" when byte_amount = "00" and rw = '1' and lower_two_bit = "01" else 
                         "01000000" when byte_amount = "00" and rw = '1' and lower_two_bit = "10" else 
                         "10000000" when byte_amount = "00" and rw = '1' and lower_two_bit = "11" else 
                         "00110000" when byte_amount = "01" and rw = '1' and lower_two_bit = "00" else -- store halfword must be 2 byte aligned
                         "11000000" when byte_amount = "01" and rw = '1' and lower_two_bit = "10" else 
                         "11110000" when rw = '1'                                                 else
                         "00000000";



    write_data1 <= write_data(7 downto 0);
    write_data2 <= write_data(7 downto 0) when byte_amount = "00" else write_data(15 downto 8);
    write_data3 <= write_data(7 downto 0) when byte_amount = "00" or (byte_amount = "01" and lower_two_bit = "10") else write_data(23 downto 16);
    write_data4 <= write_data(7 downto 0) when byte_amount = "00" else write_data(15 downto 8) when byte_amount = "01" and lower_two_bit = "10" else write_data(31 downto 24);

    --register for delay (response data instruction is on writeBack, not Memory)

    process(clk,stall,reset) begin 
    if(rising_edge(clk)) then 
        if (reset = '1') then 
            byte_amount_delay_register_output <= "00";
            lower_two_bit_delay_register_output <="00";
            highest_bit_delay <= '0';
        else 
            byte_amount_delay_register_output <= byte_amount;
            lower_two_bit_delay_register_output <= lower_two_bit;
            highest_bit_delay <= highest_bit;
        end if;
    end if;
    end process;




end Behavioral;
