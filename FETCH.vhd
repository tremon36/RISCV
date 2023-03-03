library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;


entity FETCH is
    port(
        stall,hard_reset,clk,enable_parallel_load_cp: in std_logic;
        pc_parallel_load,IRAM_output: in std_logic_vector(31 downto 0);
        IRAM_addr_request: out std_logic_vector(31 downto 0);
        ins_output,pc_output: out std_logic_vector(31 downto 0)
    );
end FETCH;

architecture Behavioral of FETCH is

component CP is
    port(
        count,reset,enable_parallel_load,clock:in std_logic;
        current_num:out std_logic_vector(31 downto 0);
        load: in std_logic_vector(31 downto 0)
        );
end component CP;


component RegistroF is
    port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(31 downto 0);
        z: out std_logic_vector(31 downto 0)
        );
        
end component RegistroF;



signal enable_parallel_load_internal: std_logic;
signal target_address,target_address_plus_4,delay_reg_input,delay_reg_output,to_sum_offset,pc_parallel_load_internal,ins_output_internal: std_logic_vector(31 downto 0);
signal delayed_ins_output_reg: std_logic_vector(31 downto 0);
signal external_parallel_load_delay,stall_delayed: std_logic;

signal pc_current_num: std_logic_vector(31 downto 0);

begin

program_counter: CP port map(not stall,hard_reset,enable_parallel_load_internal,clk,pc_current_num,pc_parallel_load_internal);
registro_salida: RegistroF port map(hard_reset,stall and not enable_parallel_load_cp,clk,delay_reg_input,delay_reg_output);
registro_delay_ins: RegistroF port map(hard_reset,stall_delayed,clk,ins_output_internal,delayed_ins_output_reg);

ins_output <= ins_output_internal;
IRAM_addr_request <= target_address when enable_parallel_load_internal = '1' else -- search target address in RAM only for inconditional jumps, else search pc content
                     pc_current_num;                                                                        

pc_parallel_load_internal <= target_address_plus_4 when enable_parallel_load_cp = '0' else pc_parallel_load; -- load pc with internal+4 if inconditional jump, with external load without + 4

target_address_plus_4 <= target_address + x"00000004";
delay_reg_input <= pc_current_num when enable_parallel_load_internal = '0' or enable_parallel_load_cp = '1' else target_address; --delay reg input always PC except for inconditional jumps

pc_output <= delay_reg_output when hard_reset = '0'  and external_parallel_load_delay = '0' else x"00000000"; -- Output instruction is only not zero when no external parallel load in the cycle before
ins_output_internal <= IRAM_output when hard_reset = '0'  and external_parallel_load_delay = '0' and stall_delayed = '0' else
              delayed_ins_output_reg when stall_delayed = '1' and external_parallel_load_delay = '0'  else x"00000000";

process(clk) begin      -- Delay register for enable parallel load
if(rising_edge(clk)) then
if(hard_reset = '1') then 
external_parallel_load_delay <= '0';
stall_delayed <= '0';
else 
external_parallel_load_delay <= enable_parallel_load_cp;
stall_delayed <= stall;
end if;
end if;
end process;


to_sum_offset(31 downto 20) <= (11 downto 0 => ins_output_internal(31));
to_sum_offset(19 downto 0) <= ins_output_internal(19 downto 12) & ins_output_internal(20) & ins_output_internal(30 downto 21) & "0";

target_address <= delay_reg_output + to_sum_offset;

process(clk,enable_parallel_load_cp,pc_parallel_load,IRAM_output,hard_reset,delay_reg_output,pc_current_num,to_sum_offset) begin

    if(enable_parallel_load_cp = '1' or (ins_output_internal(6 downto 0) = "1101111" and hard_reset = '0')) then -- Cargar el contador de programa desde jump o salto inmediato
        enable_parallel_load_internal <= '1';

    else
        enable_parallel_load_internal <= '0';
    end if;

end process;

end Behavioral;