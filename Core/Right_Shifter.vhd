library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Right_Shifter is
    port(
        operando: in std_logic_vector(31 downto 0);
        shift_amount: in std_logic_vector(4 downto 0);
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end Right_Shifter;

architecture Behavioral of Right_Shifter is

component Right_Shift_16 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end component Right_Shift_16;

component Right_Shift_8 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end component Right_Shift_8;

component Right_Shift_4 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end component Right_Shift_4;

component Right_Shift_2 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end component Right_Shift_2;

component Right_Shift_1 is
    port(
        input : in std_logic_vector(31 downto 0);
        enable: in std_logic;
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end component Right_Shift_1;


signal internal_16,internal_8,internal_4,internal_2: std_logic_vector(31 downto 0);

begin

s16: Right_Shift_16 port map (operando,shift_amount(4),internal_16,fill_bit);
s8: Right_Shift_8 port map (internal_16,shift_amount(3),internal_8,fill_bit);
s4: Right_Shift_4 port map (internal_8,shift_amount(2),internal_4,fill_bit);
s2: Right_Shift_2 port map (internal_4,shift_amount(1),internal_2,fill_bit);
s1: Right_Shift_1 port map (internal_2,shift_amount(0),output,fill_bit);



end Behavioral;
