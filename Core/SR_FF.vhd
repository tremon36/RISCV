library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SR_FF is
    port(
        set,reset,clk : in std_logic;
        data_out : out std_logic
    );
end SR_FF;

architecture Behavioral of SR_FF is
signal state: std_logic;
begin

    process(clk) begin 
        if(rising_edge(clk)) then 
            if(set = '1') then 
                state <= '1';
            elsif(reset = '1') then 
                state <= '0';
            end if;
        end if;
    end process;

end Behavioral;
