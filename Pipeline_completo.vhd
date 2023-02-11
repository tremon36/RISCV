library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Pipeline_completo is
    port(
        reset,clk: in std_logic;
        Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
        LED_out : out STD_LOGIC_VECTOR (6 downto 0)
        );
end Pipeline_completo;

architecture Behavioral of Pipeline_completo is

--display de 7 segmentos
signal displayed_number : std_logic_vector (15 downto 0);
component seven_segment_display_VHDL is
    Port ( clk : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           reset : in STD_LOGIC; -- reset
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
           displayed_number: in STD_LOGIC_VECTOR (15 downto 0));
end component seven_segment_display_VHDL;

--CONTADOR DE PROGRAMA

component CP
        port(
        count,reset,enable_parallel_load,clock:in std_logic;
        current_num:out std_logic_vector(31 downto 0);
        load: in std_logic_vector(31 downto 0)
        );
end component CP;


--REGISTROS INTERMEDIOS PARA GUARDAR DATOS RELATIVOS A signal 

component RegistroF
        port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(31 downto 0);
        z: out std_logic_vector(31 downto 0)
        );        
end component RegistroF;

--MEMORIA RAM 

component Single_port_RAM
port(
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_IN: in std_logic_vector(7 downto 0); -- Data to write into RAM
 RAM_WR: in std_logic; -- Write enable 
 RAM_CLOCK: in std_logic; -- clock input for RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end component Single_port_RAM;

--INTERFAZ PARA MEMORIA RAM

component memory_manager is
    port(
        rw  : in std_logic;
        byte_amount : in std_logic_vector(1 downto 0);
        write_data: in std_logic_vector(31 downto 0);
        requested_address: in std_logic_vector(6 downto 0);
        response_data1,response_data2,response_data3,response_data4 : in std_logic_vector(7 downto 0);
        write_data1,write_data2,write_data3,write_data4 : out std_logic_vector(7 downto 0);
        request_adress_forward_1,request_adress_forward_2,request_adress_forward_3,request_adress_forward_4: out std_logic_vector(6 downto 0);
        data_output_32_bit: out std_logic_vector(31 downto 0);
        write_data_enable: out std_logic_vector(3 downto 0)
    );
end component memory_manager;

--MEMORIA DE INSTRUCCIONES 

component Instruction_memory 
port(
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(31 downto 0) ;-- Data output of RAM
 byte_amount: in std_logic_vector(1 downto 0)
);
end component Instruction_memory;


--BANCO DE REGISTROS 

component Registros is
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
        
        r_f1 : out std_logic;
        r_f2 : out std_logic;
        r_f3 : out std_logic
    );
    end component;


--FETCH 

component FETCH
    
port(
    stall,reset,clock:in std_logic;
    current_pc,instruction:in std_logic_vector(31 downto 0);
    current_inst,memory_dir_request,cp_inst: out std_logic_vector (31 downto 0);
    r_w: out std_logic;
    amount:out std_logic_vector(1 downto 0)
    -- rs2_dir,rs1_dir,rd_dir: out std_logic_vector(4 downto 0);
   --  will_write_flag_decode: out std_logic
    );
end component FETCH;

--DECODE 

component DECODE
port(
        reset,stall,clock: in std_logic;
        instruction,data_rs2,data_rs1: in std_logic_vector(31 downto 0);
        rs2_dir,rs1_dir,rd_dir: out std_logic_vector(4 downto 0);
        stall_prev,register_r: out std_logic;
        decoded_instruction: out std_logic_vector(90 downto 0);
        will_write_flag: out std_logic
        );

end component DECODE;


--JUMP 

component JUMP
port(
        reset,stall,clk:in std_logic;
        instruction:in std_logic_vector(90 downto 0);
        instruction_z:out std_logic_vector(90 downto 0);
        current_pc:in std_logic_vector(31 downto 0);
        pc_actualizado:out std_logic_vector(31 downto 0);
        reset_prev,enable_parallel_cp:out std_logic );
        
end component JUMP;


--EXECUTE 

component EXE
Port (op1,op2 : in std_logic_vector (31 downto 0);-- in case inmediate intruction, the inmediate op gets fech into the op2.
        ofsset : in std_logic_vector (11 downto 0);
        rd : in std_logic_vector (4 downto 0);
        sub_op_code : in std_logic_vector (2 downto 0);
        op_code : in std_logic_vector (6 downto 0);
        clk : in std_logic;
        reset, stall_in : in std_logic;
        Instructio_pointer : in std_logic_vector (31 downto 0);
        stall_out : out std_logic;
        z: out std_logic_vector(90 downto 0)
        );
 end component EXE;
 
 --MEMORY 
 
 component MEMORY   
     port(
        stall,reset,clk: in std_logic;
        memory_dir,memory_to_write: out std_logic_vector(31 downto 0);
        memory_data: in std_logic_vector(31 downto 0);
        rw,stall_prev: out std_logic;
        decoded_instruction: in std_logic_vector(90 downto 0);
        instruction_z: out std_logic_vector(90 downto 0);
        bytes:out std_logic_vector(1 downto 0));
end component MEMORY;

--WRITE

component WRITE
 Port ( decode_instruction : in std_logic_vector (90 downto 0);
        reset : in std_logic;
        clk : in std_logic;
        stall_in : in std_logic;
        data_out : out std_logic_vector (31 downto 0);
        dir_out : out std_logic_vector (4 downto 0);
        write_enable : out std_logic
  );
 end component WRITE;

--signals de program counter 
signal stall_pc, enable_parallel_load: std_logic;
signal instruction_pointer_PC,jump_result: std_logic_vector(31 downto 0);

--signals de fetch
signal stall_fetch,r_w_instruction_memory,reset_fetch: std_logic;
signal instruccion_actual_entrada_fetch,instruccion_salida_fetch,instruction_memory_dir_request: std_logic_vector(31 downto 0);
signal instruction_pointer_salida_fetch: std_logic_vector(31 downto 0);
signal instruction_size: std_logic_vector(1 downto 0);
signal rs1_dir,rs2_dir,rd_dir: std_logic_vector(4 downto 0);
signal rs1_busy_flag,rs2_busy_flag,dest_reg_busy_flag: std_logic;

--signals de decode
signal stall_decode,reset_decode,stall_prev,read_from_register_UNASSIGNED: std_logic;
signal data_rs1,data_rs2,instruction_pointer_salida_decode: std_logic_vector(31 downto 0);
signal rs1_dir_UNASSIGNED,rs2_dir_UNASSIGNED,rd_dir_UNASSIGNED: std_logic_vector(4 downto 0);
signal decoded_instruction: std_logic_vector(90 downto 0);
signal will_write_flag_decode:std_logic;

--signals de jump 
signal stall_jump,reset_jump,reset_prev_to_jump: std_logic;
signal decoded_instruction_jump: std_logic_vector(90 downto 0);
signal jump_instruction_pointer,instruction_pointer_salida_jump: std_logic_vector(31 downto 0);

--signals de execute 
signal stall_exe,reset_exe,stall_previous_exe:std_logic;
signal instruction_pointer_salida_exe: std_logic_vector(31 downto 0);
signal decoded_instruction_exe: std_logic_vector(90 downto 0);

--signals de memory 
signal stall_memory,reset_memory:std_logic;
signal memory_dir,memory_data_to_write,memory_data_to_read: std_logic_vector(31 downto 0);
signal rw_memory,stall_previous_memory: std_logic;
signal decoded_instruction_memory: std_logic_vector(90 downto 0);
signal bytes_to_write_memory: std_logic_vector(1 downto 0);

--signals de write 

signal reset_write: std_logic;
signal stall_write,enable_write_to_registers: std_logic;
signal data_to_write_to_registers: std_logic_vector(31 downto 0);
signal register_direction_to_write: std_logic_vector(4 downto 0);


--signals de la memoria de instrucciones 

signal load_instruction: std_logic_vector(31 downto 0);
signal load_dir_instruction_memory: std_logic_vector(31 downto 0);
signal load_enable_instruction_memory: std_logic;
signal load_bytes_instruction_memory: std_logic_vector(1 downto 0);

--signals de la memoria de datos

signal memory_manager_forwarded_address_4,memory_manager_forwarded_address_3,memory_manager_forwarded_address_2,memory_manager_forwarded_address_1: std_logic_vector(31 downto 0);
signal ram_1_response,ram_2_response,ram_3_response,ram_4_response: std_logic_vector(7 downto 0);
signal ram_1_write_data,ram_2_write_data,ram_3_write_data,ram_4_write_data: std_logic_vector(7 downto 0);
signal ram_enables: std_logic_vector(3 downto 0);



begin
    
    programCounter: CP port map ( --TODO a�adir stall_out de todos los siguientes 
            stall_pc,             
            reset,
            enable_parallel_load,   --tiene que ser 1 cuando se vaya a actualizar el PC por la etapa JUMP
            clk,
            instruction_pointer_PC, --la direccion guardada el contador de programa
            jump_result);           --la direccion a la que actualizar el contador de programa en un salto
            
    fetch_stage: FETCH port map (
            stall_fetch,
            reset_fetch,
            clk,
            instruction_pointer_PC,             -- la direccion que el PC le pasa a fetch
            instruccion_actual_entrada_fetch,   -- resultado de buscar en la memoria de instrucciones
            instruccion_salida_fetch,           -- salida de fetch (instruccion a pasar por el pipeline)
            instruction_memory_dir_request,     -- Direccion de peticion de busqueda a la memoria
            instruction_pointer_salida_fetch,   -- Puntero de instruccion asociado a la instruccion de salida
            r_w_instruction_memory,             -- Indicacion a la memoria de que se va a leer o a escribir (deberia ser siempre 0, read)
            instruction_size
            );

    decode_stage: DECODE port map(
            reset_decode,                       
            stall_decode,
            clk,
            instruccion_salida_fetch,           -- Instruccion sin decodificar, salida de fetch
            data_rs2,                           -- Datos leidos del registro rs2 (ADD rd,rs1,rs2 ejemplo de innstruccion)
            data_rs1,                           -- Datos leidos del registro rs1 
            rs2_dir,                 -- Direccion del registro rs2 (desde 0 a 31)
            rs1_dir,                 -- Direccion del registro rs1 (desde 0 a 31)
            rd_dir,                 -- Direccion del registro de destino (rd) (desde 0 a 31)
            stall_prev,                         -- Parar las etapas anteriores si hay riesgo RAW
            read_from_register_UNASSIGNED,      -- Indicar al banco de registros si se va a leer o no
            decoded_instruction,
            will_write_flag_decode
            );                                  -- Instruccion procesada y decodificada, para continuar por el pipeline
            
    jump_stage: JUMP port map(
            reset_jump,
            stall_jump,
            clk,
            decoded_instruction,                -- Instruccion decodificada que viene de la etapa decode
            decoded_instruction_jump,           -- Reenviar la instruccion decodificada por el pipeline, un ciclo despues de que llegue
            instruction_pointer_salida_decode,  -- PC asociado a la instruccion que esta pasando por la etapa
            jump_result,                        -- Direccion de instruccion a la que saltar de ser necesario (es el valor de parallel load del PC)
            reset_prev_to_jump,                 -- Resetear las etapas anteriores si se salta, pues contienen instrucciones que no hay que ejecutar
            enable_parallel_load );             -- Indicar al PC si debe ejecutar el salto (hacer carga paralela)
            
            
    execute_stage: EXE port map(                    -- Campos de la instruccion decodificada
           decoded_instruction_jump(90 downto 59),  -- Operando 1 
           decoded_instruction_jump(58 downto 27),  -- Operando 2 
           decoded_instruction_jump(26 downto 15),  -- Offset 
           decoded_instruction_jump(14 downto 10),  -- Registro de destino 
           decoded_instruction_jump(9 downto 7),    -- Subopcode 
           decoded_instruction_jump(6 downto 0),    -- codigo de operacion (opcode)
           clk,
           reset_exe,
           stall_exe,
           instruction_pointer_salida_jump,
           stall_previous_exe,
           decoded_instruction_exe);                -- @TODO salida de instruccion de exe para pasar por el pipeline
           
   memory_stage: MEMORY port map( 
           stall_memory,
           reset_memory,
           clk,
           memory_dir,                             -- Direccion de memoria de la que se va a leer/escribir 
           memory_data_to_write,                   -- Datos que se van a escribir en memoria (se envia al modulo de memoria)
           memory_data_to_read,                    -- Datos resultado de leer en memoria (los envia el modulo de memoria)
           rw_memory,                              -- Indicacion a la memoria de si se va a leer (0) o a escribir (1)
           stall_previous_memory,                  -- Parada del pipeline hasta obtener un resultado de memoria 
           decoded_instruction_exe,                -- Instruccion que pasa la etapa execute a las siguientes
           decoded_instruction_memory,             -- Instruccion a propagar a las siguientes etapas del pipeline
           bytes_to_write_memory);                 -- Cantidad de bytes que van a ser escritos/leidos en memoria
           
   write_stage: WRITE port map(
            decoded_instruction_memory,            -- Instruccion que pasa la etapa memory 
            reset_write,                           
            clk,
            stall_write,
            data_to_write_to_registers,            -- datos de escritura en registros (mandar a los registros)
            register_direction_to_write,           -- direccion de escritura en los registros
            enable_write_to_registers);            -- Indicar a los registros si se debe escribir o no
                   
            
   --registros que contienen el contador de programa asociado a la instrucccion que se esta ejecutando en esa etapa del pipeline 
   
   registro_decode_cp: RegistroF port map (
        reset_decode,stall_decode,clk,instruction_pointer_salida_fetch,instruction_pointer_salida_decode);
        
   registro_jump_cp: RegistroF port map (
        reset_jump,stall_jump,clk,instruction_pointer_salida_decode,instruction_pointer_salida_jump);
        
   registro_exe_cp: RegistroF port map (
        reset_exe,stall_exe,clk,instruction_pointer_salida_jump,instruction_pointer_salida_exe);
        
   --memoria de instrucciones y de datos

   
   memoria_instrucciones: Instruction_memory  port map(
        instruction_pointer_PC(6 downto 0),         -- Direccion de instruccion a buscar
        instruccion_actual_entrada_fetch,           -- Instruccion de la que se va a hacer fetch (resultado de la busqueda en la memoria)
        "10");                                      -- Cantidad de bytes que se van a leer, deberia ser siempre 4 (10 o 11)
        
   ram_1: Single_port_RAM port map(
        memory_manager_forwarded_address_1(6 downto 0),                   -- Direccion de memoria que viene del memory manager
        ram_1_write_data,                                                 -- Datos que memory manager desea escribir
        ram_enables(0),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        clk,
        ram_1_response                                                    -- Resultado de la busqueda en la memoria, se pasa a memory manager
        );

   ram_2: Single_port_RAM port map(
        memory_manager_forwarded_address_2(6 downto 0),                   -- Direccion de memoria que viene del memory manager
        ram_2_write_data,                                                 -- Datos que memory manager desea escribir
        ram_enables(1),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        clk,
        ram_2_response                                                    -- Resultado de la busqueda en la memoria, se pasa a memory manager
        );   

   ram_3: Single_port_RAM port map(
        memory_manager_forwarded_address_3(6 downto 0),                   -- Direccion de memoria que viene del memory manager
        ram_3_write_data,                                                 -- Datos que memory manager desea escribir
        ram_enables(2),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        clk,
        ram_3_response                                                    -- Resultado de la busqueda en la memoria, se pasa a memory manager
        );   

   ram_4: Single_port_RAM port map(
        memory_manager_forwarded_address_4(6 downto 0),                   -- Direccion de memoria que viene del memory manager
        ram_4_write_data,                                                 -- Datos que memory manager desea escribir
        ram_enables(3),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        clk,
        ram_4_response                                                    -- Resultado de la busqueda en la memoria, se pasa a memory manager
        );                                             
    
  interfaz_RAM: memory_manager port map(
        rw_memory,                                                                      -- Enable de escritura en memoria, lo proporciona la etapa memory
        bytes_to_write_memory,                                                          -- Cantidad de bits a escribir (00 -> 8 bit, 01 -> 16 bit, else 32 bit). Lo proporciona memory
        memory_data_to_write,                                                           -- Datos a escribir en memoria, lo proporciona memory
        memory_dir(6 downto 0),                                                         -- Direccion en la que escribir en memoria, lo proporciona memory
        ram_1_response,ram_2_response,ram_3_response,ram_4_response,                    -- Respuestas de las memorias RAM, contienen datos a juntar. 
        ram_1_write_data,ram_2_write_data,ram_3_write_data,ram_4_write_data,            -- Datos separados enviados a cada banco RAM para escribir en ellos
        memory_manager_forwarded_address_1(6 downto 0),                                             -- Direccion en la que escribir en memoria, reenviado por la interfaz a cada RAM
        memory_manager_forwarded_address_2(6 downto 0), 
        memory_manager_forwarded_address_3(6 downto 0), 
        memory_manager_forwarded_address_4(6 downto 0), 
        memory_data_to_read,                                                            -- Datos leidos de la RAM, se envian a memory
        ram_enables                                                                     -- Enable de escritura de las 4 RAM. la cuarta contiene la direccion mas pequeña
  );
        
        
   banco_registros: Registros port map(
       data_rs1,                                    -- Datos de lectura de rs1, se envia a decode (primer operando)
       data_rs2,                                    -- Datos de lectura de rs2, se envia a decode (segundo operando) 
       data_to_write_to_registers,                  -- Datos que envia Write para escribir en los registros
       register_direction_to_write,                 -- Direccion en la que se van a escribir los datos que envia write
       enable_write_to_registers,                   -- Enable que debe poner a 1 write para escribir
       rs1_dir,                                     -- Direccion de lectura de rs1, lo proporciona decode
       '1',                                         -- Enable del read de los registros, lo proporciona decode
       rs2_dir,                                     -- Direccion de lectura de rs2, lo proporciona decode
       '1',                                         -- Es igual al anterior porque se lee siempre de dos registros
       rd_dir,                                      -- Direccion del registro en que se va a escribir el flag de willWrite. Lo proporciona decode (riesgos RAW)
       will_write_flag_decode,                      -- Poner el flag a 1 o 0
       reset,                       
       clk,
       rs1_busy_flag,
       rs2_busy_flag,
       dest_reg_busy_flag
   
   );
   
   --display de 7 segmentos
   
   segmento: seven_segment_display_VHDL port map (clk,reset,Anode_Activate,LED_out,displayed_number );
        
    -- control de las señales de reset y stall del pipeline
    -- en general stall(etapa) = stall(etapa + 1) or stall(etapa + 2)....
    
   reset_fetch <= reset or reset_prev_to_jump;
   stall_fetch <= stall_previous_exe or stall_previous_memory or stall_prev or rs1_busy_flag or rs2_busy_flag or dest_reg_busy_flag;
   
   reset_decode <= reset or reset_prev_to_jump;
   stall_decode <= stall_previous_exe or stall_previous_memory or rs1_busy_flag or rs2_busy_flag or dest_reg_busy_flag;
   
   reset_jump <= reset;
   stall_jump <= stall_previous_exe or stall_previous_memory;
   
   reset_exe <= reset;
   stall_exe <= stall_previous_exe or stall_previous_memory;
   
   stall_memory <= '0';
   stall_pc <= not stall_fetch;
   reset_memory <= reset;
   
   reset_write <= reset;
   stall_write <= '0';

    displayed_number <= data_to_write_to_registers(15 downto 0);
    
   
   

end Behavioral;
