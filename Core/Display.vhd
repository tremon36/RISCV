library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity seven_segment_display_VHDL is
    Port ( clk : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           reset : in STD_LOGIC; -- reset
           Anode_Activate : out STD_LOGIC_VECTOR (7 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
           displayed_number: in STD_LOGIC_VECTOR (31 downto 0));
end seven_segment_display_VHDL;

architecture Behavioral of seven_segment_display_VHDL is
signal one_second_counter: STD_LOGIC_VECTOR (27 downto 0);
-- counter for generating 1-second clock enable
signal one_second_enable: std_logic;
-- one second enable for counting numbers
-- counting decimal number to be displayed on 4-digit 7-segment display
signal LED_BCD: STD_LOGIC_VECTOR (3 downto 0);
signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
-- creating 10.5ms refresh period
signal LED_activating_counter: std_logic_vector(2 downto 0);
-- the other 2-bit for creating 4 LED-activating signals
-- count         0    ->  1  ->  2  ->  3
-- activates    LED1    LED2   LED3   LED4
-- and repeat
begin


-- VHDL code for BCD to 7-segment decoder
-- Cathode patterns of the 7-segment LED display 
process(LED_BCD)
begin
    case LED_BCD is
    when "0000" => LED_out <= "0000001"; -- "0"     
    when "0001" => LED_out <= "1001111"; -- "1" 
    when "0010" => LED_out <= "0010010"; -- "2" 
    when "0011" => LED_out <= "0000110"; -- "3" 
    when "0100" => LED_out <= "1001100"; -- "4" 
    when "0101" => LED_out <= "0100100"; -- "5" 
    when "0110" => LED_out <= "0100000"; -- "6" 
    when "0111" => LED_out <= "0001111"; -- "7" 
    when "1000" => LED_out <= "0000000"; -- "8"     
    when "1001" => LED_out <= "0000100"; -- "9" 
    when "1010" => LED_out <= "0000010"; -- a
    when "1011" => LED_out <= "1100000"; -- b
    when "1100" => LED_out <= "0110001"; -- C
    when "1101" => LED_out <= "1000010"; -- d
    when "1110" => LED_out <= "0110000"; -- E
    when "1111" => LED_out <= "0111000"; -- F
    when others => LED_out <= "0000000";
    end case;
end process;
-- 7-segment display controller
-- generate refresh period of 10.5ms
process(clk,reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clk)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
 LED_activating_counter <= refresh_counter(19 downto 17);
-- 4-to-1 MUX to generate anode activating signals for 4 LEDs 
process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "000" =>
        Anode_Activate <= "01111111"; 
        LED_BCD <= displayed_number(31 downto 28);
    when "001" =>
        Anode_Activate <= "10111111"; 
        LED_BCD <= displayed_number(27 downto 24);
    when "010" =>
        Anode_Activate <= "11011111"; 
        LED_BCD <= displayed_number(23 downto 20);
    when "011" =>
        Anode_Activate <= "11101111"; 
        LED_BCD <= displayed_number(19 downto 16);
    when "100" =>
        Anode_Activate <= "11110111"; 
        LED_BCD <= displayed_number(15 downto 12);
    when "101" => 
        Anode_Activate <= "11111011"; 
        LED_BCD <= displayed_number(11 downto 8);
    when "110" => 
        Anode_Activate <= "11111101"; 
        LED_BCD <= displayed_number(7 downto 4);
    when "111" => 
        Anode_Activate <= "11111110"; 
        LED_BCD <= displayed_number(3 downto 0);
        
    when others => 
        Anode_Activate <= "11111110"; 
        LED_BCD <= displayed_number(3 downto 0);
    end case;
end process;
end Behavioral;
