library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;


entity memory_manager is
    port(
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

signal addr_plus_1,addr_plus_2,addr_plus_3 : std_logic_vector(6 downto 0);

begin

    request_adress_forward_1 <= requested_address;
    request_adress_forward_2 <= requested_address + "0000001";
    request_adress_forward_3 <= requested_address + "0000010";
    request_adress_forward_4 <= requested_address + "0000011";


    data_output_32_bit <= response_data4 & response_data3 & response_data2 & response_data1;

    write_data_enable <= "0001" when byte_amount = "00" and rw = '1' else --write byte (only ram1)
                         "0011" when byte_amount = "01" and rw = '1' else --write halfword (only ram1 and 2)
                         "1111" when rw = '1'                        else --write complete word (all ram)
                         "0000";                                          --no writes

    write_data1 <= write_data(7 downto 0);
    write_data2 <= write_data(15 downto 8);
    write_data3 <= write_data(23 downto 16);
    write_data4 <= write_data(31 downto 24);


end Behavioral;
