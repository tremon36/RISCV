library IEEE;
use IEEE.std_logic_1164.all;



entity Registros is
    port (
        r_dataBus1 : out std_logic_vector (31 downto 0);
        r_dataBus2 : out std_logic_vector (31 downto 0);
        w_dataBus : in std_logic_vector (31 downto 0);

        writeAddress : in std_logic_vector (4 downto 0);
        writeEnable : in std_logic;

        readAddress1 : in std_logic_vector (4 downto 0);
        readEnable1 : in std_logic;

        readAddress2 : in std_logic_vector (4 downto 0);
        readEnable2 : in std_logic;
        
        destinationRegister : in std_logic_vector(4 downto 0); 
        destinationEnable : in std_logic;
        
        mainReset : in std_logic;
        mainClock : in std_logic;
        
        r_f1 : out std_logic ;
        r_f2 : out std_logic ;
        r_f3 : out std_logic
    );
end Registros;

architecture Behavioral of Registros is

component MUX_32 is
    port(
    selection: in std_logic_vector(4 downto 0);
    valores: in std_logic_vector(31 downto 0);
    salida: out std_logic
    );
end component MUX_32;
    
    component register32 is
        port (
            d   : IN std_logic_vector (31 DOWNTO 0);
            ld  : IN std_logic ; 
            rd1 : IN std_logic;
            rd2 : IN std_logic;
            clr : IN std_logic; 
            clk : IN std_logic; 
            q1  : OUT std_logic_vector (31 DOWNTO 0);
            q2  : OUT std_logic_vector (31 DOWNTO 0);
            wfrd1  : out std_logic;
            wfwr : in std_logic   
        );
    end component;

    component reg_deco is port (
            dir : in std_logic_vector(4 downto 0);
            z : out std_logic_vector (31 downto 0);
            enable : in std_logic 
        );
    end component;

    signal enableRegisterToWrite : std_logic_vector (31 downto 0);
    signal enableRegisterToRead1 : std_logic_vector (31 downto 0);
    signal enableRegisterToRead2 : std_logic_vector (31 downto 0);
    signal DestinationReg  : std_logic_vector (31 downto 0);
    signal valores_flag: std_logic_vector(31 downto 0);
   

begin

    -- Decodificador para la escritura en registro que corresponda.
    decode_write_address : reg_deco  port map (
        dir => writeAddress,
        z => enableRegisterToWrite,
        enable => writeEnable
    );  
    -- Decodificadores para leer el registro.
    decode_read_address1 : reg_deco  port map (
        dir => readAddress1,
        z => enableRegisterToRead1,
        enable => readEnable1
    );
    
    decode_read_address2 : reg_deco  port map (
        dir => readAddress2,
        z => enableRegisterToRead2,
        enable => readEnable2
    );
    
    --Decodificador para destination reg (flag)
    decode_destination_reg : reg_deco port map (
        dir => destinationRegister,
        z => DestinationReg,
        enable => destinationEnable
    );
    
    --multiplexor de eleccion de salida de flags: DIR1, DIR2, y DestDIR
    
    mux_flag1: MUX_32 port map (
        readAddress1,
        valores_flag,
        r_f1
    );
    
    mux_flag2: MUX_32 port map (
        readAddress2,
        valores_flag,
        r_f2
    );
    
    mux_flag_WAW: MUX_32 port map (
        destinationRegister,
        valores_flag,
        r_f3
    );

    -- Los 32 registros, del R0 al R31.
    register_R0 : register32  port map (
        d => x"00000000" ,
        ld => enableRegisterToWrite(0),
        rd1 => enableRegisterToRead1(0),
        rd2 => enableRegisterToRead2(0),     
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(0) ,
        wfwr => '0'
    );
    
        register_R1 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(1),
        rd1 => enableRegisterToRead1(1),
        rd2 => enableRegisterToRead2(1),     
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(1),
        wfwr => DestinationReg(1)
    );
    
        register_R2 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(2),
        rd1 => enableRegisterToRead1(2), 
        rd2 => enableRegisterToRead2(2),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(2),
        wfwr => DestinationReg(2) 
    );
    
        register_R3 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(3),
        rd1 => enableRegisterToRead1(3),
        rd2 => enableRegisterToRead2(3),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(3),
        wfwr => DestinationReg(3)
    );
    
        register_R4 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(4),
        rd1 => enableRegisterToRead1(4), 
        rd2 => enableRegisterToRead2(4),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 =>valores_flag(4) ,
        wfwr => DestinationReg(4) 
    );
    
        register_R5 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(5),
        rd1 => enableRegisterToRead1(5),  
        rd2 => enableRegisterToRead2(5),  
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(5),
        wfwr => DestinationReg(5) 
    );
    
        register_R6 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(6),
        rd1 => enableRegisterToRead1(6),
        rd2 => enableRegisterToRead2(6),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(6) ,
        wfwr => DestinationReg(6) 
    );
    
        register_R7 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(7),
        rd1 => enableRegisterToRead1(7),
        rd2 => enableRegisterToRead2(7),     
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(7) ,
        
        wfwr => DestinationReg(7) 
    );
    
        register_R8 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(8),
        rd1 => enableRegisterToRead1(8),    
        rd2 => enableRegisterToRead2(8), 
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(8) ,
        
        wfwr => DestinationReg(8) 
    );
    
        register_R9 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(9),
        rd1 => enableRegisterToRead1(9),    
        rd2 => enableRegisterToRead2(9), 
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(9) ,
        
        wfwr => DestinationReg(9) 
    );
    
        register_R10 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(10),
        rd1 => enableRegisterToRead1(10),   
        rd2 => enableRegisterToRead2(10), 
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(10),
       
        wfwr => DestinationReg(10) 
    );
    
        register_R11 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(11),
        rd1 => enableRegisterToRead1(11), 
        rd2 => enableRegisterToRead2(11),
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(11) ,
        
        wfwr => DestinationReg(11) 
    );
    
        register_R12 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(12),
        rd1 => enableRegisterToRead1(12), 
        rd2 => enableRegisterToRead2(12),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(12) ,
        
        wfwr => DestinationReg(12) 
    );
    
        register_R13 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(13),
        rd1 => enableRegisterToRead1(13), 
        rd2 => enableRegisterToRead2(13),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(13) ,
        
        wfwr => DestinationReg(13) 
    );
    
        register_R14 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(14),
        rd1 => enableRegisterToRead1(14), 
        rd2 => enableRegisterToRead2(14),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 =>valores_flag(14) ,
        
        wfwr => DestinationReg(14) 
    );
    
        register_R15 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(15),
        rd1 => enableRegisterToRead1(15), 
        rd2 => enableRegisterToRead2(15),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(15),
        
        wfwr => DestinationReg(15) 
    );
    
        register_R16 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(16),
        rd1 => enableRegisterToRead1(16),
        rd2 => enableRegisterToRead2(16),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(16) ,
        
        wfwr => DestinationReg(16) 
    );
    
        register_R17 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(17),
        rd1 => enableRegisterToRead1(17),
        rd2 => enableRegisterToRead2(17) ,   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(17) ,
       
        wfwr => DestinationReg(17) 
    );
    
        register_R18 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(18),
        rd1 => enableRegisterToRead1(18), 
        rd2 => enableRegisterToRead2(18),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(18) ,
        
        wfwr => DestinationReg(18) 
    );
    
        register_R19 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(19),
        rd1 => enableRegisterToRead1(19), 
        rd2 => enableRegisterToRead2(19),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(19) ,
       
        wfwr => DestinationReg(19) 
    );
    
        register_R20 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(20),
        rd1 => enableRegisterToRead1(20),
        rd2 => enableRegisterToRead2(20),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(20) ,
        
        wfwr => DestinationReg(20) 
    );
    
        register_R21 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(21),
        rd1 => enableRegisterToRead1(21),
        rd2 => enableRegisterToRead2(21),     
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(21) ,
        
        wfwr => DestinationReg(21) 
    );
    
        register_R22 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(22),
        rd1 => enableRegisterToRead1(22), 
        rd2 => enableRegisterToRead2(22),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(22) ,
        
        wfwr => DestinationReg(22) 
    );
    
        register_R23 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(23),
        rd1 => enableRegisterToRead1(23),
        rd2 => enableRegisterToRead2(23),     
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(23) ,
        
        wfwr => DestinationReg(23) 
    );
    
        register_R24 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(24),
        rd1 => enableRegisterToRead1(24), 
        rd2 => enableRegisterToRead2(24),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(24) ,
        
        wfwr => DestinationReg(24)
    );
    
        register_R25 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(25),
        rd1 => enableRegisterToRead1(25),
        rd2 => enableRegisterToRead2(25),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(25),
        
        wfwr => DestinationReg(25) 
    );
    
        register_R26 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(26),
        rd1 => enableRegisterToRead1(26),
        rd2 => enableRegisterToRead2(26),     
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(26) ,
    
        wfwr => DestinationReg(26) 
    );
    
        register_R27 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(27),
        rd1 => enableRegisterToRead1(27),
        rd2 => enableRegisterToRead2(27),    
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(27) ,

        wfwr => DestinationReg(27) 
    );
    
        register_R28 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(28),
        rd1 => enableRegisterToRead1(28),  
        rd2 => enableRegisterToRead2(28),  
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(28) ,
        wfwr => DestinationReg(28)
    );
    
        register_R29 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(29),
        rd1 => enableRegisterToRead1(29),  
        rd2 => enableRegisterToRead2(29),
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(29) ,
        wfwr => DestinationReg(29)
    );
    
        register_R30 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(30),
        rd1 => enableRegisterToRead1(30), 
        rd2 => enableRegisterToRead2(30),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(30) ,
        
        wfwr => DestinationReg(30) 
    );
    
        register_R31 : register32  port map (
        d => w_dataBus ,
        ld => enableRegisterToWrite(31),
        rd1 => enableRegisterToRead1(31),  
        rd2 => enableRegisterToRead2(31),   
        clr => mainReset,
        clk => mainClock,
        q1 => r_dataBus1,
        q2 => r_dataBus2,
        wfrd1 => valores_flag(31) ,
        wfwr => DestinationReg(31) 
    );
    
    

   

end Behavioral;