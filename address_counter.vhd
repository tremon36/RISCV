library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity address_counter is
    port(
        reset,clk,count: in std_logic;
        enable_parallel_load: in std_logic;
        load: in std_logic_vector(17 downto 0);
        number: out std_logic_vector(17 downto 0)
        );
end address_counter;

architecture Behavioral of address_counter is

signal Ts : std_logic_vector(17 downto 0);
signal states : std_logic_vector(17 downto 0);


begin

ff0 : entity work.T_flip_flop port map(reset,clk,Ts(0),states(0));
ff1 : entity work.T_flip_flop port map(reset,clk,Ts(1),states(1));
ff2 : entity work.T_flip_flop port map(reset,clk,Ts(2),states(2));
ff3 : entity work.T_flip_flop port map(reset,clk,Ts(3),states(3));
ff4 : entity work.T_flip_flop port map(reset,clk,Ts(4),states(4));
ff5 : entity work.T_flip_flop port map(reset,clk,Ts(5),states(5));
ff6 : entity work.T_flip_flop port map(reset,clk,Ts(6),states(6));
ff7 : entity work.T_flip_flop port map(reset,clk,Ts(7),states(7));
ff8 : entity work.T_flip_flop port map(reset,clk,Ts(8),states(8));
ff9 : entity work.T_flip_flop port map(reset,clk,Ts(9),states(9));
ff10 : entity work.T_flip_flop port map(reset,clk,Ts(10),states(10));
ff11 : entity work.T_flip_flop port map(reset,clk,Ts(11),states(11));
ff12 : entity work.T_flip_flop port map(reset,clk,Ts(12),states(12));
ff13 : entity work.T_flip_flop port map(reset,clk,Ts(13),states(13));
ff14 : entity work.T_flip_flop port map(reset,clk,Ts(14),states(14));
ff15 : entity work.T_flip_flop port map(reset,clk,Ts(15),states(15));
ff16 : entity work.T_flip_flop port map(reset,clk,Ts(16),states(16));
ff17 : entity work.T_flip_flop port map(reset,clk,Ts(17),states(17));


Ts(0) <= count when enable_parallel_load = '0' else load(0) xor states(0);
Ts(1) <= states(0) and count when enable_parallel_load = '0' else load(1) xor states(1);
Ts(2) <= states(0) and states(1) and count when enable_parallel_load = '0' else load(2) xor states(2);
Ts(3) <= states(0) and states(1) and states(2) and count when enable_parallel_load = '0' else load(3) xor states(3);
Ts(4) <= states(0) and states(1) and states(2) and states(3) and count when enable_parallel_load = '0' else load(4) xor states(4);
Ts(5) <= states(0) and states(1) and states(2) and states(3) and states(4) and count when enable_parallel_load = '0' else load(5) xor states(5);
Ts(6) <= states(0) and states(1) and states(2) and states(3) and states(4) and states(5) and count when enable_parallel_load = '0' else load(6) xor states(6);
Ts(7) <= states(0) and states(1) and states(2) and states(3) and states(4) and states(5) and states(6) and count when enable_parallel_load = '0' else load(7) xor states(7);
Ts(8) <= Ts(7) and states(7) and count when enable_parallel_load = '0' else load(8) xor states(8);
Ts(9) <= Ts(8) and states(8) and count when enable_parallel_load = '0' else load(9) xor states(9);
Ts(10) <= Ts(9) and states(9) and count when enable_parallel_load = '0' else load(10) xor states(10);
Ts(11) <= Ts(10) and states(10) and count when enable_parallel_load = '0' else load(11) xor states(11);
Ts(12) <= Ts(11) and states(11) and count when enable_parallel_load = '0' else load(12) xor states(12);
Ts(13) <= Ts(12) and states(12) and count when enable_parallel_load = '0' else load(13) xor states(13);
Ts(14) <= Ts(13) and states(13) and count when enable_parallel_load = '0' else load(14) xor states(14);
Ts(15) <= Ts(14) and states(14) and count when enable_parallel_load = '0' else load(15) xor states(15);
Ts(16) <= Ts(15) and states(15) and count when enable_parallel_load = '0' else load(16) xor states(16);
Ts(17) <= Ts(16) and states(16) and count when enable_parallel_load = '0' else load(17) xor states(17);

number <= states;



end Behavioral;
