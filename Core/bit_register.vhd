library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bit_register is
    port(

        reset,stall,clk: in std_logic;
        set: in std_logic;
        data_in: in std_logic;
        data_out: out std_logic

        );
end bit_register;

architecture Behavioral of bit_register is

signal state: std_logic;

begin
    data_out <= state;
    process(clk) begin 
        if(rising_edge(clk)) then 
            if(reset = '1') then 
                state <= '0';
            elsif(set = '1') then 
                state <= '1';
            elsif(stall = '0') then 
                state <= data_in;
            end if;
        end if;
    end process;

end Behavioral;
