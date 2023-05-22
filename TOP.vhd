library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP is
    port(
        --  Pipeline ports
        reset,clk,csr_module_interrupt_input: in std_logic;
        debug_read_reg_addr: in std_logic_vector(4 downto 0);
        Anode_Activate : out STD_LOGIC_VECTOR (7 downto 0);-- 8 Anode signals
        LED_out : out STD_LOGIC_VECTOR (6 downto 0);
        hsync,vsync: out std_logic;
        rgb: out std_logic_vector(11 downto 0);

        --  SPI communication ports
        
        SCK,MOSI,CS: out std_logic;
        MISO : in std_logic;
        SD_RESET: out std_logic
        );
end TOP;

architecture Behavioral of TOP is

signal enable_initial_program_load_data,enable_initial_program_load_instr: std_logic;
signal initial_program_load_word: std_logic_vector(7 downto 0);
signal initial_program_load_addr: std_logic_vector(17 downto 0);
signal reset_short: std_logic;
signal reset_pipeline: std_logic;

begin

    pipeline: entity work.Pipeline_completo port map(
            reset => reset_pipeline,
            clk => clk,
            csr_module_interrupt_input => csr_module_interrupt_input,
            debug_read_reg_addr => debug_read_reg_addr,
            Anode_Activate => Anode_Activate,
            LED_out => LED_out,
            hsync => hsync,
            vsync => vsync,
            rgb => rgb,
            enable_initial_program_load_instr => enable_initial_program_load_instr,
            enable_initial_program_load_data => enable_initial_program_load_data,
            initial_program_load_addr => initial_program_load_addr,
            initial_program_load_word => initial_program_load_word
    );

    CardReader: entity work.SPI_module port map(
            reset => reset,
            reset_short => '0',
            clk => clk,
            SCK => SCK,
            MOSI => MOSI,
            CS => CS,
            MISO => MISO,
            SD_RESET => SD_RESET,
            enable_initial_program_load_instr => enable_initial_program_load_instr,
            enable_initial_program_load_data => enable_initial_program_load_data,
            initial_program_load_addr => initial_program_load_addr,
            initial_program_load_word => initial_program_load_word,
            reset_pipeline => reset_pipeline
    );

end Behavioral;
