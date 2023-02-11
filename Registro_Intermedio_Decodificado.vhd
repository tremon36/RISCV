
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Registro_Intermedio_Decodificado is
    port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(90 downto 0);
        z: out std_logic_vector(90 downto 0)
        );
        
end Registro_Intermedio_Decodificado ;

architecture Behavioral of Registro_Intermedio_Decodificado is
signal estado: std_logic_vector(90 downto 0);


begin
    z <= estado;
    process (clk)
     begin
     if clk='1' and clk'event then
        if reset='1' then estado <=x"0000000000000000000000" & "000";
        else if stall ='0' then estado <= load;
        end if;
        end if;
     end if;
end process;
end Behavioral;
