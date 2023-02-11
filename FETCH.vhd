library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FETCH is

port(
    stall,reset,clock:in std_logic;
    current_pc,instruction:in std_logic_vector(31 downto 0);
    current_inst,memory_dir_request,cp_inst: out std_logic_vector (31 downto 0);
    r_w: out std_logic;
    amount:out std_logic_vector(1 downto 0)
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


end Behavioral;
