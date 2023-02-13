library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity FETCH is

port(
    stall,reset,clock:in std_logic;
    current_pc,instruction:in std_logic_vector(31 downto 0);
    current_inst,memory_dir_request,cp_inst: out std_logic_vector (31 downto 0);
    r_w: out std_logic;
    amount:out std_logic_vector(1 downto 0);
    branch_prediction_address: out std_logic_vector(31 downto 0);
    enable_parallel_cp: out std_logic
    );

end FETCH;

architecture Behavioral of FETCH is

component RegistroF
        port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(31 downto 0);
        z: out std_logic_vector(31 downto 0)
        );        
end component RegistroF;

signal to_sum_offset: std_logic_vector(31 downto 0);

begin
F:RegistroF port map(
                     reset,stall,clock,instruction,current_inst
                     );
X:RegistroF port map(
                     reset,stall,clock,current_pc,cp_inst
                     );

r_w <= '0';
amount<="10";
                                         
memory_dir_request <= current_pc;

process(clock,to_sum_offset)
begin
if(instruction(6 downto 0) = "1101111" and reset = '0') then -- JAL instruction, inconditional jump 

to_sum_offset(31 downto 20) <= (11 downto 0 => instruction(31));
to_sum_offset(19 downto 0) <= instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & "0";
branch_prediction_address <= current_pc + to_sum_offset;
enable_parallel_cp <= '1';

else 

branch_prediction_address<=x"00000000";
enable_parallel_cp <= '0';
to_sum_offset <= x"00000000";

end if;
end process;


end Behavioral;