library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity external_interrupts_module is
    port(
        interrupt,reset,clk: in std_logic;
        interrupt_pulse: out std_logic
    );
end external_interrupts_module;

architecture Behavioral of external_interrupts_module is

signal number: std_logic_vector(3 downto 0);
signal t0,t1,t2,t3 : std_logic;
signal count : std_logic;
signal reset_internal : std_logic;

begin

reset_internal <= '1' when interrupt = '0' or reset = '1' else '0';

ff0: entity work.T_flip_flop port map(
    reset_internal,
    clk,
    t0,
    number(0)
);

ff1: entity work.T_flip_flop port map(
    reset_internal,
    clk,
    t1,
    number(1)
);


ff2: entity work.T_flip_flop port map(
    reset_internal,
    clk,
    t2,
    number(2)
);


ff3: entity work.T_flip_flop port map(
    reset_internal,
    clk,
    t3,
    number(3)
);

t0 <= count;
t1 <= count and number(0);
t2 <= count and number(0) and number(1);
t3 <= count and number(0) and number(1) and number(2);

count <= '0' when number(3 downto 2) = "11" else '1';

interrupt_pulse <= '1' when number = "1010" else '0';

end Behavioral;
