library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity SYNTH_TEST_display is
    Port ( clock_100Mhz : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           reset : in STD_LOGIC; -- reset
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0));-- Cathode patterns of 7-segment signal
end SYNTH_TEST_display;

architecture Behavioral of SYNTH_TEST_display is

component seven_segment_display_VHDL is
    Port ( clock_100Mhz : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           reset : in STD_LOGIC; -- reset
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
           displayed_number: in STD_LOGIC_VECTOR (15 downto 0));
end component seven_segment_display_VHDL;

signal number : std_logic_vector(15 downto 0);

begin
    display: seven_segment_display_VHDL port map (clock_100Mhz,reset,Anode_Activate,LED_out,number);
    
    number <= x"FAFA";

end Behavioral;
