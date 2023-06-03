library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider_9 is
    port(
        reset,clk: in std_logic;
        clock_divided: out std_logic
        );
end clock_divider_9;

architecture Behavioral of clock_divider_9 is

signal Ts : std_logic_vector(8 downto 0);
signal states : std_logic_vector(8 downto 0);


begin

ff0 : entity work.T_flip_flop port map(reset,clk,Ts(0),states(0));
ff1 : entity work.T_flip_flop port map(reset,clk,Ts(1),states(1));
ff2 : entity work.T_flip_flop port map(reset,clk,Ts(2),states(2));
ff3 : entity work.T_flip_flop port map(reset,clk,Ts(3),states(3));
ff4 : entity work.T_flip_flop port map(reset,clk,Ts(4),states(4));
ff5 : entity work.T_flip_flop port map(reset,clk,Ts(5),states(5));
ff6 : entity work.T_flip_flop port map(reset,clk,Ts(6),states(6));
ff7 : entity work.T_flip_flop port map(reset,clk,Ts(7),states(7));
ff9 : entity work.T_flip_flop port map(reset,clk,Ts(8),states(8));


Ts(0) <= '1';
Ts(1) <= states(0);
Ts(2) <= states(0) and states(1);
Ts(3) <= states(0) and states(1) and states(2);
Ts(4) <= states(0) and states(1) and states(2) and states(3);
Ts(5) <= states(0) and states(1) and states(2) and states(3) and states(4);
Ts(6) <= states(0) and states(1) and states(2) and states(3) and states(4) and states(5);
Ts(7) <= states(0) and states(1) and states(2) and states(3) and states(4) and states(5) and states(6);
Ts(8) <= states(0) and states(1) and states(2) and states(3) and states(4) and states(5) and states(6) and states(7);

clock_divided <= states(8);





end Behavioral;
