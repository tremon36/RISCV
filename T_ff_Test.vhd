----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.04.2022 18:34:41
-- Design Name: 
-- Module Name: T_ff_Test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity T_ff_Test is
end T_ff_Test;

architecture Behavioral of T_ff_Test is

component T_ff is
    port(t,clk : in std_logic;
         q : out std_logic );
end component;

signal t, clk, q : std_logic;

begin
clk <= '0';
t <= '0';


B1 : T_ff port map (t, clk,q);

    process
    begin 
    clk <= '0' after  5ns;
    clk <= '1' after  5ns;
    end process;
    
    t <= '1' after 10 ns; t <= '0' after 20 ns; t <= '1' after 30 ns;

end Behavioral;
