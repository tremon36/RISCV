library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Left_Shifter is
    port(
        operando: in std_logic_vector(31 downto 0);
        shift_amount: in std_logic_vector(4 downto 0);
        output: out std_logic_vector(31 downto 0)
        );
end Left_Shifter;

architecture Behavioral of Left_Shifter is

component Shift_16 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end component Shift_16;

component Shift_8 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end component Shift_8;

component Shift_4 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end component Shift_4;

component Shift_2 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end component Shift_2;

component Shift_1 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end component Shift_1;

signal internal_16,internal_8,internal_4,internal_2: std_logic_vector(31 downto 0);

begin

s16: Shift_16 port map (operando,shift_amount(4),internal_16);
s8: Shift_8 port map (internal_16,shift_amount(3),internal_8);
s4: Shift_4 port map (internal_8,shift_amount(2),internal_4);
s2: Shift_2 port map (internal_4,shift_amount(1),internal_2);
s1: Shift_1 port map (internal_2,shift_amount(0),output);

end Behavioral;
