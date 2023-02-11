library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Shifter is
    port( 
        input: in std_logic_vector (31 downto 0);
        shift_amount: in std_logic_vector(4 downto 0);
        left0_right1: in std_logic;
        arithmetic: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
        
end Shifter;

architecture Behavioral of Shifter is

component Left_Shifter is
    port(
        operando: in std_logic_vector(31 downto 0);
        shift_amount: in std_logic_vector(4 downto 0);
        output: out std_logic_vector(31 downto 0)
        );
end component Left_Shifter;

component Right_Shifter is
    port(
        operando: in std_logic_vector(31 downto 0);
        shift_amount: in std_logic_vector(4 downto 0);
        output: out std_logic_vector(31 downto 0);
        fill_bit: in std_logic
        );
end component Right_Shifter;

signal out_left,out_right: std_logic_vector(31 downto 0);

begin

ls: Left_Shifter port map(input,shift_amount,out_left);
rs: Right_Shifter port map(input,shift_amount,out_right,arithmetic and input(31));

output <= out_left when left0_right1 = '0' else out_right;

end Behavioral;
