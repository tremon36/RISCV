library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity vga_controller_memory_interface is
    port(
        reset,clk: in std_logic;
        hsync,vsync: out std_logic;
        rgb: out std_logic_vector(11 downto 0);
        r1,r2,r3,r4: out std_logic_vector(14 downto 0);
        resp_1,resp_2,resp_3,resp_4: in std_logic_vector(7 downto 0)
    );
end vga_controller_memory_interface;

architecture Behavioral of vga_controller_memory_interface is


signal RAM_REQUEST: std_logic_vector(16 downto 0);
signal RAM_RESPONSE: std_logic_vector(23 downto 0);
signal req_plus_1: std_logic_vector(14 downto 0);
signal last_two_delay:std_logic_vector(1 downto 0);


begin

req_plus_1 <= RAM_REQUEST(16 downto 2) + "000000000000001";

main_inst: entity work.VGA_controller
  port map (
    reset => reset,
    clk   => clk,
    hsync => hsync,
    vsync => vsync,
    rgb   => rgb,
    RAM_REQUEST => RAM_REQUEST,
    RAM_RESPONSE => RAM_RESPONSE
  );

-- get last request to output response

process(clk) begin
if(rising_edge(clk)) then 
    if(RAM_REQUEST(1 downto 0) /= last_two_delay) then 
        last_two_delay <= RAM_REQUEST(1 downto 0);
    end if;
end if;
end process;

-- change ram request to each ram
process(RAM_REQUEST,req_plus_1) begin
case RAM_REQUEST(1 downto 0) is  
when "00" | "01" =>
    r1 <= RAM_REQUEST(16 downto 2);
    r2 <= RAM_REQUEST(16 downto 2);
    r3 <= RAM_REQUEST(16 downto 2);
    r4 <= RAM_REQUEST(16 downto 2);
when "11" | "10" => 
    r1 <= req_plus_1;
    r2 <= req_plus_1;
    r3 <= RAM_REQUEST(16 downto 2);
    r4 <= RAM_REQUEST(16 downto 2);
when others => 
    r1 <= RAM_REQUEST(16 downto 2);
    r2 <= RAM_REQUEST(16 downto 2);
    r3 <= RAM_REQUEST(16 downto 2);
    r4 <= RAM_REQUEST(16 downto 2);
end case;
end process;

process(clk,last_two_delay,resp_1,resp_2,resp_3,resp_4) begin 
case last_two_delay is 
when "00" => 
    RAM_RESPONSE <= resp_1 & resp_2 & resp_3;
when "11" =>
    RAM_RESPONSE <= resp_4 & resp_1 & resp_2;
when "10" => 
    RAM_RESPONSE <= resp_3 & resp_4 & resp_1;
when "01" => 
    RAM_RESPONSE <= resp_2 & resp_3 & resp_4;
when others =>
    RAM_RESPONSE <= resp_1 & resp_2 & resp_3;
end case;
end process;




end Behavioral;