library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity Fetch is
    port(
        stall,hard_reset,clk,enable_parallel_load_cp: in std_logic;
        pc_parallel_load,IRAM_output: in std_logic_vector(31 downto 0);
        IRAM_addr_request: out std_logic_vector(31 downto 0);
        ins_output,pc_output: out std_logic_vector(31 downto 0)
    );
end Fetch;

architecture Behavioral of Fetch is

component CP is
    port(
        count,reset,enable_parallel_load,clock:in std_logic;
        current_num:out std_logic_vector(31 downto 0);
        load: in std_logic_vector(31 downto 0)
        );
end component CP;

component R32 is
    port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(31 downto 0);
        z: out std_logic_vector(31 downto 0)
        );      
end component R32;



signal enable_parallel_load_internal: std_logic;
signal target_address,target_address_plus_4,delay_reg_input,delay_reg_output: std_logic_vector(31 downto 0);

signal pc_current_num: std_logic_vector(31 downto 0);

begin

program_counter: CP port map(not stall,hard_reset,enable_parallel_load_internal,clk,pc_current_num,target_address_plus_4);
registro_salida: R32 port map(hard_reset,stall and not enable_parallel_load_cp,clk,delay_reg_input,delay_reg_output);

IRAM_addr_request <= target_address when enable_parallel_load_cp = '1' else 
                     delay_reg_output when stall = '1'                   else
                     target_address when enable_parallel_load_internal = '1' else 
                     pc_current_num;

target_address_plus_4 <= target_address + x"00000004";
delay_reg_input <= pc_current_num when enable_parallel_load_internal = '0' else target_address;

pc_output <= delay_reg_output when hard_reset = '0' and enable_parallel_load_cp = '0' else x"00000000";
ins_output <= IRAM_output when hard_reset = '0' and enable_parallel_load_cp = '0' else x"00000000";

process(clk,IRAM_output,enable_parallel_load_cp,hard_reset) begin 

    if(enable_parallel_load_cp = '1') then -- Cargar el contador de programa desde jump
        target_address <= pc_parallel_load;
        enable_parallel_load_internal <= '1';
    elsif(IRAM_output(6 downto 0) = "1101111" and hard_reset = '0') then 
        target_address <= x"00000010"; --Saltos incondicionales
        enable_parallel_load_internal <= '1';
    else 
        target_address <= pc_current_num;
        enable_parallel_load_internal <= '0';
    end if;

end process;

end Behavioral;
