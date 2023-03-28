library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity VGA_controller is
    port (
        reset,clk : in std_logic;
        hsync,vsync: out std_logic;
        rgb : out std_logic_vector(11 downto 0);
        RAM_REQUEST: out std_logic_vector(16 downto 0);
        RAM_RESPONSE: in std_logic_vector(23 downto 0)
    );
end VGA_controller;

architecture Behavioral of VGA_controller is

signal clk_25: std_logic;
signal ff1: std_logic;
signal image_on: std_logic;
signal h_count,v_count: std_logic_vector(9 downto 0);
signal hsync_delay_reg_input,vsync_delay_reg_input,image_on_delay_reg_input,h_count_1_delayed:std_logic;
signal rgb_usage: std_logic_vector(1 downto 0);
signal RAM_REQUEST_INTERNAL: std_logic_vector(16 downto 0);

begin

  RAM_REQUEST <= RAM_REQUEST_INTERNAL;
  -- clock divider

  process(clk,ff1,reset) begin
  if(rising_edge(clk)) then
  if(reset = '1') then 
  ff1 <= '0';
  clk_25 <= '0';
  else
  ff1 <= not ff1;
  if(ff1 = '1') then 
  clk_25 <= not clk_25;
  end if;
  end if;
  end if;
  end process;

  -- Vertical and horizontal counters

  
  process(clk_25,clk,reset) begin
  
  if(rising_edge(clk_25)) then 
    if(reset = '1') then 
      h_count <= "0000000000";
      v_count <= "0000000000";
      rgb_usage <= "00";
      RAM_REQUEST_INTERNAL <= x"0000" & '0';
    else 
    
    if(h_count = "1100011111") then -- 799
        
        h_count <= "0000000000";
    else
        h_count <= h_count + "0000000001";
    end if;

    if(v_count = "1000001100" and h_count = "1100011111") then -- 525, 799
        v_count <= "0000000000";
    elsif(h_count = "1100011111") then 
        v_count <= v_count + "0000000001";
    end if;
      
    if(v_count = "1000001100" and h_count = "1100011111") then -- On new frame, reset RAM_ADDR
        RAM_REQUEST_INTERNAL <= x"0000" & '0';
    elsif(h_count = "1100011111") then -- On new line, check if substract 480
      if(v_count(0) = '0') then 
        RAM_REQUEST_INTERNAL <= RAM_REQUEST_INTERNAL - "00000000111100000";
      end if;
    elsif(h_count(1 downto 0) = "11" and image_on_delay_reg_input = '1') then -- when image is on, no more pixel, and no vsync_reset then
        RAM_REQUEST_INTERNAL <= RAM_REQUEST_INTERNAL +  "00000000000000011"; --Request next two pixels
    end if; 

  end if; 
end if;
  end process;

  -- register for delayed output signals (RAM takes 10 ns to read), so RAM output is aligned with hsync,vsync,image_on 

  process(clk) begin 
  if(rising_edge(clk)) then
  vsync <= vsync_delay_reg_input;
  hsync <= hsync_delay_reg_input;
  image_on <= image_on_delay_reg_input;
  h_count_1_delayed <= h_count(1);
  end if;
  end process;

  --hsync,vsync and image on (async)

  hsync_delay_reg_input <= '1' when h_count < "1010010000" else -- 656
           '0' when h_count < "1011110000" else -- 752
           '1';

  vsync_delay_reg_input <= '1' when v_count < "0111101010" else -- 490
           '0' when v_count < "0111101100" else -- 492
           '1';

  image_on_delay_reg_input <= '1' when h_count < "1010000000" and v_count < "0111100000" else '0'; -- 640 , 480

  
  rgb <=  RAM_RESPONSE(23 downto 20) & RAM_RESPONSE(19 downto 16) & RAM_RESPONSE(15 downto 12) when h_count_1_delayed = '0' and image_on = '1' else 
          RAM_RESPONSE(11 downto 8) & RAM_RESPONSE(7 downto 4) & RAM_RESPONSE(3 downto 0) when h_count_1_delayed = '1' and image_on = '1' else
          "000000000000";
          




end Behavioral;
