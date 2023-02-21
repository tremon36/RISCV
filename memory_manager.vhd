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
        requested_address: in std_logic_vector(6 downto 0);
        response_data1,response_data2,response_data3,response_data4 : in std_logic_vector(7 downto 0);
        write_data1,write_data2,write_data3,write_data4 : out std_logic_vector(7 downto 0);
        request_adress_forward_1,request_adress_forward_2,request_adress_forward_3,request_adress_forward_4: out std_logic_vector(6 downto 0);
        data_output_32_bit: out std_logic_vector(31 downto 0);
        write_data_enable: out std_logic_vector(3 downto 0)
    );
end memory_manager;

architecture Behavioral of memory_manager is

signal byte_amount_delay_register_output,lower_two_bit_delay_register_output: std_logic_vector(1 downto 0);
signal lower_two_bit: std_logic_vector(1 downto 0);

begin

    lower_two_bit <= requested_address(1 downto 0);

    request_adress_forward_1 <= requested_address;
    request_adress_forward_2 <= requested_address when byte_amount = "00" else  --1 byte
                                requested_address + "0000001";                  --halfword or word

    request_adress_forward_3 <= requested_address when byte_amount = "00" or (byte_amount = "01" and lower_two_bit = "10") else
                                requested_address + "0000010";
                            
    request_adress_forward_4 <= requested_address when byte_amount = "00" else
                                requested_address + "0000001" when byte_amount = "01" and lower_two_bit = "10" else 
                                requested_address + "0000011";


    data_output_32_bit <= x"000000" & response_data1 when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "00" else
                          x"000000" & response_data2 when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "01" else
                          x"000000" & response_data3 when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "10" else
                          x"000000" & response_data4 when byte_amount_delay_register_output = "00" and lower_two_bit_delay_register_output = "11" else
                          x"0000" & response_data2 & response_data1 when byte_amount_delay_register_output = "01" and lower_two_bit_delay_register_output = "00" else
                          x"0000" & response_data4 & response_data3 when byte_amount_delay_register_output = "01" and lower_two_bit_delay_register_output = "10" else
                          response_data4 & response_data3 & response_data2 & response_data1;  

    write_data_enable <= "0001" when byte_amount = "00" and rw = '1' and lower_two_bit = "00" else 
                         "0010" when byte_amount = "00" and rw = '1' and lower_two_bit = "01" else 
                         "0100" when byte_amount = "00" and rw = '1' and lower_two_bit = "10" else 
                         "1000" when byte_amount = "00" and rw = '1' and lower_two_bit = "11" else 
                         "0011" when byte_amount = "01" and rw = '1' and lower_two_bit = "00" else -- store halfword must be 2 byte aligned
                         "1100" when byte_amount = "01" and rw = '1' and lower_two_bit = "10" else 
                         "1111" when rw = '1'                                                 else 
                         "0000";                                          --no write



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
        else 
            byte_amount_delay_register_output <= byte_amount;
            lower_two_bit_delay_register_output <= lower_two_bit;
        end if;
    end if;
    end process;




end Behavioral;
