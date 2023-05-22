library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Shift_register_8_bit is
    port(
        reset,clk,enable_parallel_load: in std_logic;
        parallel_load: in std_logic_vector(7 downto 0);
        current_output: out std_logic
    );
end Shift_register_8_bit;

architecture Behavioral of Shift_register_8_bit is

signal Ds : std_logic_vector(7 downto 0);
signal states : std_logic_vector(7 downto 0);

begin

    -- Flip Flops making the shift register

    ff0 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(0),
        states(0)
    );

    ff1 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(1),
        states(1)
    );

    ff2 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(2),
        states(2)
    );

    ff3 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(3),
        states(3)
    );   

    ff4 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(4),
        states(4)
    );

    ff5 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(5),
        states(5)
    );

    ff6 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(6),
        states(6)
    );   

    ff7 : entity work.D_Flip_Flop port map (
        reset,clk,Ds(7),
        states(7)
    );

    -- Load control:

    Ds(0) <= parallel_load(0) when enable_parallel_load = '1' else '1';
    Ds(1) <= parallel_load(1) when enable_parallel_load = '1' else states(0);
    Ds(2) <= parallel_load(2) when enable_parallel_load = '1' else states(1);
    Ds(3) <= parallel_load(3) when enable_parallel_load = '1' else states(2);        
    Ds(4) <= parallel_load(4) when enable_parallel_load = '1' else states(3);
    Ds(5) <= parallel_load(5) when enable_parallel_load = '1' else states(4);
    Ds(6) <= parallel_load(6) when enable_parallel_load = '1' else states(5);
    Ds(7) <= parallel_load(7) when enable_parallel_load = '1' else states(6);
    current_output <= states(7);

end Behavioral;
