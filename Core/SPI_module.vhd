library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity SPI_module is
    port(

        reset,reset_short,clk: in std_logic;
        SCK,MOSI,CS: out std_logic;
        MISO : in std_logic;
        SD_RESET: out std_logic;
        enable_initial_program_load_instr: out std_logic;
        enable_initial_program_load_data: out std_logic;
        initial_program_load_addr: out std_logic_vector(17 downto 0);
        initial_program_load_word: out std_logic_vector(7 downto 0);
        reset_pipeline: out std_logic

        );
end SPI_module;

architecture Behavioral of SPI_module is

signal enable_load,is_empty: std_logic;
signal load,current_read : std_logic_vector (7 downto 0);
signal sck_internal: std_logic;
signal clk_divided : std_logic;

begin

    clock_divider : entity work.clock_divider_9 port map(
        reset_short,
        clk,
        clk_divided
    );

    sender: entity work.SPI_sender port map (
        reset => reset,
        clk => clk_divided,
        enable_load => enable_load,
        load => load,
        is_empty => is_empty,
        MOSI => MOSI,
        SCK => sck_internal
    );

    receiver: entity work.SPI_receiver port map(
        reset => reset,
        clk => sck_internal,
        MISO => MISO,
        current_read => current_read
    );

    master: entity work.SPI_master_automata port map(
        reset,clk_divided,is_empty,
        current_read,
        load,
        enable_load,
        CS,
        enable_initial_program_load_instr,
        enable_initial_program_load_data,
        initial_program_load_addr,
        initial_program_load_word,
        reset_pipeline
    );

    SCK <= sck_internal;
    SD_RESET <= '0';


end Behavioral;
