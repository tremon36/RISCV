library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_sender is
    port(
        reset,clk,enable_load: in std_logic;
        load: in std_logic_vector(7 downto 0);
        is_empty : out std_logic;
        MOSI: out std_logic;
        SCK: out std_logic
        );
end SPI_sender;

architecture Behavioral of SPI_sender is

signal reset_counter : std_logic;
signal bits_left : std_logic_vector(2 downto 0);
signal is_empty_internal,is_empty_internal_delay: std_logic;

begin

shift_reg: entity work.Shift_register_8_bit port map (
    reset,clk,enable_load,
    load,
    MOSI
);

left_count: entity work.counter_3_bit port map (
    reset_counter,clk,
    bits_left
);

reset_counter <= reset or enable_load;
is_empty_internal <= bits_left(0) and bits_left(1) and bits_left(2); -- When this happens, there is only one bit left in the shift register. if parallel loadaded in this
                                                                     -- cycle, no delay between one byte and the next one. Therefore, is_empty should be considered an asynchronous input in the controller
                                                                     -- automata.

-- SCK generator 

is_empty <= is_empty_internal;
is_empty_internal_delay_reg: entity work.D_Flip_Flop port map(
    reset,clk,is_empty_internal,
    is_empty_internal_delay
);

SCK <= not clk and ( is_empty_internal nand is_empty_internal_delay);

end Behavioral;
