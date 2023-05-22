library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_receiver is
    port(
        reset,clk,MISO: in std_logic;
        current_read: out std_logic_vector(7 downto 0)
        );
end SPI_receiver;

architecture Behavioral of SPI_receiver is

signal states : std_logic_vector(7 downto 0);
signal Ds: std_logic_vector(7 downto 0);

begin

current_read <= states(0) & states(1) & states(2) & states(3) & states(4) & states(5) & states(6) & states(7); -- Invert, because first data is most significant bit

ff0: entity work.D_Flip_Flop port map (reset,clk,Ds(0),states(0));
ff1: entity work.D_Flip_Flop port map (reset,clk,Ds(1),states(1));
ff2: entity work.D_Flip_Flop port map (reset,clk,Ds(2),states(2));
ff3: entity work.D_Flip_Flop port map (reset,clk,Ds(3),states(3));
ff4: entity work.D_Flip_Flop port map (reset,clk,Ds(4),states(4));
ff5: entity work.D_Flip_Flop port map (reset,clk,Ds(5),states(5));
ff6: entity work.D_Flip_Flop port map (reset,clk,Ds(6),states(6));
ff7: entity work.D_Flip_Flop port map (reset,clk,Ds(7),states(7));

Ds(7) <= MISO;
Ds(6) <= states(7);
Ds(5) <= states(6);
Ds(4) <= states(5);
Ds(3) <= states(4);
Ds(2) <= states(3);
Ds(1) <= states(2);
Ds(0) <= states(1);



end Behavioral;
