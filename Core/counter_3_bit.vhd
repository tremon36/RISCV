library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- This unit counts backwards in order to represent how many bits are left in the shift register of the SPI unit
entity counter_3_bit is
    port(
        reset,clk: in std_logic;
        bits_left: out std_logic_vector(2 downto 0)
        );
end counter_3_bit;

architecture Behavioral of counter_3_bit is

signal Ts : std_logic_vector(2 downto 0);
signal states : std_logic_vector(2 downto 0);
signal count: std_logic;


begin

ff0 : entity work.T_flip_flop port map(reset,clk,Ts(0),states(0));
ff1 : entity work.T_flip_flop port map(reset,clk,Ts(1),states(1));
ff2 : entity work.T_flip_flop port map(reset,clk,Ts(2),states(2));

count <= not (states(0) and states(1) and states(2)); -- no overflow

Ts(0) <= count;
Ts(1) <= states(0) and count;
Ts(2) <= states(0) and states(1) and count;

bits_left <= states(2) & states(1) & states(0);


end Behavioral;
