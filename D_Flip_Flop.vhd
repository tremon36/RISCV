library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity D_Flip_Flop is
    port(
        reset,clk,D : in std_logic;
        state : out std_logic
    );
end D_Flip_Flop;

architecture Behavioral of D_Flip_Flop is

signal state_internal: std_logic;

begin

    state <= not state_internal;

    process(clk) begin
        if(rising_edge(clk)) then 
            if(reset = '1') then 
                state_internal <= '0';
            else 
                state_internal <= not D;
            end if;
        end if;
    end process;


end Behavioral;
