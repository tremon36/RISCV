library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity T_flip_flop is
    port(
        reset,clk,t: in std_logic;
        state: out std_logic
    );
end T_flip_flop;

architecture Behavioral of T_flip_flop is
signal internal_state : std_logic;
begin
    state <= internal_state;
    process(clk) begin
        if(rising_edge(clk)) then 
            if(reset = '1') then 
                internal_state <= '0';
            else 
                internal_state <= internal_state xor t;
            end if;
        end if;
    end process;

end Behavioral;
