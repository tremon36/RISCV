library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity address_register is
        port(
            reset,clk: in std_logic;
            enable_load: in std_logic;
            load: in std_logic_vector(7 downto 0);
            stored_addr: out std_logic_vector(17 downto 0)
            );
end address_register;

architecture Behavioral of address_register is

signal state: std_logic_vector(17 downto 0);
signal Ds : std_logic_vector(17 downto 0);

signal automata_state: std_logic_vector(1 downto 0);
signal automata_Ds: std_logic_vector(1 downto 0);

begin

state_ff0: entity work.D_Flip_Flop port map(reset,clk,automata_Ds(0),automata_state(0));
state_ff1: entity work.D_Flip_Flop port map(reset,clk,automata_Ds(1),automata_state(1));

automata_Ds(0) <= not automata_state(0) when enable_load = '1' else automata_state(0);
automata_Ds(1) <= automata_state(1) xor automata_state(0) when enable_load = '1' else automata_state(1);

ff0: entity work.D_Flip_Flop port map (reset,clk,Ds(0),state(0));
ff1: entity work.D_Flip_Flop port map (reset,clk,Ds(1),state(1));
ff2: entity work.D_Flip_Flop port map (reset,clk,Ds(2),state(2));
ff3: entity work.D_Flip_Flop port map (reset,clk,Ds(3),state(3));
ff4: entity work.D_Flip_Flop port map (reset,clk,Ds(4),state(4));
ff5: entity work.D_Flip_Flop port map (reset,clk,Ds(5),state(5));
ff6: entity work.D_Flip_Flop port map (reset,clk,Ds(6),state(6));
ff7: entity work.D_Flip_Flop port map (reset,clk,Ds(7),state(7));
ff8: entity work.D_Flip_Flop port map (reset,clk,Ds(8),state(8));
ff9: entity work.D_Flip_Flop port map (reset,clk,Ds(9),state(9));
ff10: entity work.D_Flip_Flop port map (reset,clk,Ds(10),state(10));
ff11: entity work.D_Flip_Flop port map (reset,clk,Ds(11),state(11));
ff12: entity work.D_Flip_Flop port map (reset,clk,Ds(12),state(12));
ff13: entity work.D_Flip_Flop port map (reset,clk,Ds(13),state(13));
ff14: entity work.D_Flip_Flop port map (reset,clk,Ds(14),state(14));
ff15: entity work.D_Flip_Flop port map (reset,clk,Ds(15),state(15));
ff16: entity work.D_Flip_Flop port map (reset,clk,Ds(16),state(16));
ff17: entity work.D_Flip_Flop port map (reset,clk,Ds(17),state(17));

Ds(0) <= state(0) when enable_load = '0' else load(0) when automata_state ="11" else state(0);
Ds(1) <= state(1) when enable_load = '0' else load(1) when automata_state ="11" else state(1);
Ds(2) <= state(2) when enable_load = '0' else load(2) when automata_state ="11" else state(2);
Ds(3) <= state(3) when enable_load = '0' else load(3) when automata_state ="11" else state(3);
Ds(4) <= state(4) when enable_load = '0' else load(4) when automata_state ="11" else state(4);
Ds(5) <= state(5) when enable_load = '0' else load(5) when automata_state ="11" else state(5);
Ds(6) <= state(6) when enable_load = '0' else load(6) when automata_state ="11" else state(6);
Ds(7) <= state(7) when enable_load = '0' else load(7) when automata_state ="11" else state(7);
Ds(8) <= state(8) when enable_load = '0' else load(0) when automata_state ="00" else state(8);
Ds(9) <= state(9) when enable_load = '0' else load(1) when automata_state ="00" else state(9);
Ds(10) <= state(10) when enable_load = '0' else load(2) when automata_state ="00" else state(10);
Ds(11) <= state(11) when enable_load = '0' else load(3) when automata_state ="00" else state(11);
Ds(12) <= state(12) when enable_load = '0' else load(4) when automata_state ="00" else state(12);
Ds(13) <= state(13) when enable_load = '0' else load(5) when automata_state ="00" else state(13);
Ds(14) <= state(14) when enable_load = '0' else load(6) when automata_state ="00" else state(14);
Ds(15) <= state(15) when enable_load = '0' else load(7) when automata_state ="00" else state(15);
Ds(16) <= state(16) when enable_load = '0' else load(0) when automata_state = "01" else state(16);
Ds(17) <= state(17) when enable_load = '0' else load(1) when automata_state = "01" else state(17);

stored_addr <= state;



end Behavioral;
