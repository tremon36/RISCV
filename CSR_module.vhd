library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity CSR_module is
    port(
        reset,clk,interrupt: in std_logic;
        pc_to_save: in std_logic_vector (31 downto 0);
        interruption_cause: in std_logic_vector(4 downto 0);
        saved_pc: out std_logic_vector(31 downto 0);
        launch_ISR: out std_logic;
        exit_ISR: in std_logic;

        write_csr: in std_logic;
        bitmask: in std_logic_vector(31 downto 0);
        csr_address: in std_logic_vector(11 downto 0);
        csr_write_data: in std_logic_vector(31 downto 0);
        csr_lecture: out std_logic_vector(31 downto 0)

    );
end CSR_module;

architecture Behavioral of CSR_module is

signal mstatus : std_logic_vector(1 downto 0);
signal mip,mie: std_logic_vector(2 downto 0);
signal mcause: std_logic_vector(31 downto 0);
signal mvtec: std_logic_vector(31 downto 0);
signal mtval,mepc,mscratch: std_logic_vector(31 downto 0);
signal execute_interrupt_internal: std_logic;

signal i_temp,i_software,i_external: std_logic;

begin

    -- Decide to execute interrupt depending on MIE register. Each interrupt cause asociated with one bit in mie.

    i_software <= mie(0) when interruption_cause = "00011" else '0';
    i_temp     <= mie(1) when interruption_cause = "00111" else '0';
    i_external <= mie(2) when interruption_cause = "01011" else '0';

    execute_interrupt_internal <= interrupt and mstatus(0) and (i_software or i_temp or i_external);

    -- One clock cycle delay to send the signals to execute interruption to fetch (give time to write to registers)

    process(clk, execute_interrupt_internal) begin
        if(rising_edge(clk)) then 
            launch_ISR <= execute_interrupt_internal;
        end if;
    end process;

    -- One register (process) for each CSR. This processes manage the write part
    
    process(clk,reset,execute_interrupt_internal,mstatus) begin -- mstatus [MPIE, MIE]
        if(rising_edge(clk)) then 
            if(reset = '1') then 
                mstatus <= "00"; -- initially all interrupts are disabled
            else 
                if(write_csr = '1' and csr_address = x"300") then 
                    mstatus <= ((csr_write_data(7) and bitmask(7)) or (mstatus(1) and not bitmask(7))) & ((csr_write_data(3) and bitmask(3)) or (mstatus(0) and not bitmask(3))); --write according to bitmask
                elsif(execute_interrupt_internal = '1') then 
                    mstatus <= mstatus(0) & '0';        --copy MIE to MPIE, set MIE to 0
                elsif(exit_ISR = '1') then 
                    mstatus <= '0' & mstatus(1);        -- On MRET, copy MPIE to MIE (restore)
                end if;
            end if;
        end if;
    end process;


    process(clk,reset,mie) begin -- mie
        if(rising_edge(clk)) then 
            if(reset = '1') then 
                mie <= "111"; -- initially all interrupt enables are disabled.
            else 
                if(write_csr = '1' and csr_address = x"304") then 
                    mie <= ((csr_write_data(11) and bitmask(11)) or (mie(2) and not bitmask(11))) & ((csr_write_data(7) and bitmask(7)) or (mie(1) and not bitmask(7))) & ((csr_write_data(3) and bitmask(3)) or (mie(0) and not bitmask(3))); --write according to bitmask
                end if;
            end if;
        end if;
    end process;

    process(clk,reset,execute_interrupt_internal) begin -- mcause
        if(rising_edge(clk)) then 
            if(reset = '1') then 
                mcause <= x"00000000";
            else
                if(execute_interrupt_internal = '1') then 
                    mcause <= "1" & x"000000" & "00" & interruption_cause; -- On interrupt arrival, set the interruption cause. Not prepared for exceptions at the moment
                elsif (write_csr = '1' and csr_address = x"342") then 
                    mcause <= (csr_write_data and bitmask) or (mcause and not bitmask); -- software write according to bitmask
                end if;
            end if;
        end if;
    end process;

    -- mvtec is not writtable in this implementation. Hardcoded address of interrupt vectors in hardware

    process(clk,reset,execute_interrupt_internal) begin -- mepc
        if(rising_edge(clk)) then 
            if(reset = '1') then
                mepc <= x"00000000";
            elsif(execute_interrupt_internal = '1') then 
                mepc <= pc_to_save;                                             -- save PC before jumping to ISR
            elsif(write_csr = '1' and csr_address = x"341") then 
                mepc <= (csr_write_data and bitmask) or (mepc and not bitmask); -- software write according to bitmask
            end if;
        end if;
    end process;

    saved_pc <= mepc;

    -- mtval is always 0 in this implementation

    process(clk,reset) begin --mscratch
            if(rising_edge(clk)) then 
                if(reset = '1') then
                    mscratch <= x"00000000";
                elsif (write_csr = '1' and csr_address = x"340") then 
                    mscratch <= (csr_write_data and bitmask) or (mscratch and not bitmask); -- software write according to bitmask
                end if;
            end if;
    end process;


    process(clk) begin --read registers process
        if(rising_edge(clk)) then 
                case csr_address is
                    when x"300" => --  mstatus
                        csr_lecture <=  x"000000" & '0' & mstatus(1) & "000" & mstatus(0) & "00";
                    when x"304" => -- mie
                        csr_lecture <= x"00000" & '0' & mie(2) & "000" & mie(1) & "000" & mie(0) & "00";
                    when x"342" => -- mcause
                        csr_lecture <= mcause;
                    when x"305" => -- mvtec 
                        csr_lecture <= x"55555554";--DIR_VECTOR_INTERRUPCIONES_32_BIT_ALIGN & "00";
                    when x"341" => -- mepc
                        csr_lecture <= mepc;
                    when x"340" => --mscratch
                        csr_lecture <= mscratch;
                    when others => 
                        csr_lecture <= x"00000000";
                end case;
        end if;
    end process;

    





end Behavioral;
