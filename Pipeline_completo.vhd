library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Pipeline_completo is
    port(
        reset,clk: in std_logic;
        debug_read_reg_addr: in std_logic_vector(4 downto 0);
        Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
        LED_out : out STD_LOGIC_VECTOR (6 downto 0);
        hsync,vsync: out std_logic;
        rgb: out std_logic_vector(11 downto 0)
        );
end Pipeline_completo;

architecture Behavioral of Pipeline_completo is

 --DEBUG signal
 signal debug_data_output: std_logic_vector(31 downto 0);

--display de 7 segmentos
signal displayed_number : std_logic_vector (15 downto 0);
component seven_segment_display_VHDL is
    Port ( clk : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           reset : in STD_LOGIC; -- reset
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
           displayed_number: in STD_LOGIC_VECTOR (15 downto 0));
end component seven_segment_display_VHDL;



--REGISTROS INTERMEDIOS PARA GUARDAR DATOS RELATIVOS A signal 

component RegistroF
        port(
        reset,stall,clk: in std_logic;
        load: in std_logic_vector(31 downto 0);
        z: out std_logic_vector(31 downto 0)
        );        
end component RegistroF;

-- MEMORIA RAM 

component Dual_port_RAM is
port(
 RAM_ADDR: in std_logic_vector(14 downto 0); -- Address to write/read RAM
 RAM_ADDR2: in std_logic_vector(14 downto 0); -- Address to write/read RAM, port 2
 RAM_DATA_IN: in std_logic_vector(7 downto 0); -- Data to write into RAM
 RAM_DATA_IN2: in std_logic_vector(7 downto 0); -- Data to write into RAM, port 2
 RAM_WR: in std_logic; -- Write enable
 RAM_WR2: in std_logic; -- Write enable, port 2  
 RAM_CLOCK: in std_logic; -- clock input for RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0); -- Data output of RAM
 RAM_DATA_OUT2: out std_logic_vector(7 downto 0) -- Data output of RAM, port 2
);
end component Dual_port_RAM;

component low_capacity_RAM is
port(
 RAM_ADDR: in std_logic_vector(12 downto 0); -- Address to write/read RAM
 RAM_DATA_IN: in std_logic_vector(7 downto 0); -- Data to write into RAM
 RAM_WR: in std_logic; -- Write enable 
 RAM_CLOCK: in std_logic; -- clock input for RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end component low_capacity_RAM;

--INTERFAZ PARA MEMORIA RAM

component memory_manager is
    port(
        clk,stall,reset: in std_logic;
        rw  : in std_logic;
        byte_amount : in std_logic_vector(1 downto 0);
        write_data: in std_logic_vector(31 downto 0);
        requested_address: in std_logic_vector(17 downto 0);
        response_data1,response_data2,response_data3,response_data4 : in std_logic_vector(7 downto 0);
        lowc_ram_1_response,lowc_ram_2_response,lowc_ram_3_response,lowc_ram_4_response: in std_logic_vector(7 downto 0);
        write_data1,write_data2,write_data3,write_data4 : out std_logic_vector(7 downto 0);
        request_adress_forward: out std_logic_vector(14 downto 0);
        data_output_32_bit: out std_logic_vector(31 downto 0);
        write_data_enable: out std_logic_vector(7 downto 0)
    );
end component memory_manager;

-- MEMORIA DE INSTRUCCIONES (1,2,3,4) (mas adelante se utilizara un solo componente, mientras sea ROM es necesario 4)

component Instruction_memory is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end component instruction_memory;

component Instruction_memory_2 is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end component instruction_memory_2;

component Instruction_memory_3 is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end component instruction_memory_3;

component Instruction_memory_4 is
port(
 clk: in std_logic;
 RAM_ADDR: in std_logic_vector(6 downto 0); -- Address to write/read RAM
 RAM_DATA_OUT: out std_logic_vector(7 downto 0) -- Data output of RAM
);
end component instruction_memory_4;



-- INTERFAZ PARA MEMORIA DE INSTRUCCIONES 

component IRAM_memory_manager is
    port(
        RAM_ADDR: in std_logic_vector(31 downto 0);
        ram1_response,ram2_response,ram3_response,ram4_response: in std_logic_vector(7 downto 0);
        RAM_1_ADDR,RAM_2_ADDR,RAM_3_ADDR,RAM_4_ADDR, RAM_RESPONSE: out std_logic_vector(31 downto 0)
        );
end component IRAM_memory_manager; 


--BANCO DE REGISTROS 

component Registros is
        port (
        r_dataBus1 : out std_logic_vector (31 downto 0);
        r_dataBus2 : out std_logic_vector (31 downto 0);
        r_dataBus_debug: out std_logic_vector(31 downto 0); -- DEBUG
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
        r_f3 : out std_logic;

        debug_read_reg_addr: in std_logic_vector(4 downto 0) -- DEBUG
    );
    end component;

-- VGA memory interface and output 

component vga_controller_memory_interface is
    port(
        reset,clk: in std_logic;
        hsync,vsync: out std_logic;
        rgb: out std_logic_vector(11 downto 0);
        r1,r2,r3,r4: out std_logic_vector(14 downto 0);
        resp_1,resp_2,resp_3,resp_4: in std_logic_vector(7 downto 0)
    );
end component vga_controller_memory_interface;


--FETCH 


component FETCH is
    port(
        stall,hard_reset,clk,enable_parallel_load_cp: in std_logic;
        pc_parallel_load,IRAM_output: in std_logic_vector(31 downto 0);
        IRAM_addr_request: out std_logic_vector(31 downto 0);
        ins_output,pc_output: out std_logic_vector(31 downto 0)
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
        memory_data_response: in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector (31 downto 0);
        dir_out : out std_logic_vector (4 downto 0);
        write_enable : out std_logic
  );
 end component WRITE;

--signals de program counter 
signal stall_pc, enable_parallel_load_pc: std_logic;
signal instruction_pointer_PC,parallel_load_data_pc: std_logic_vector(31 downto 0);

--signals de fetch
signal stall_fetch,r_w_instruction_memory,reset_fetch: std_logic;
signal instruccion_actual_entrada_fetch,instruccion_salida_fetch,instruction_memory_dir_request: std_logic_vector(31 downto 0);
signal instruction_pointer_salida_fetch: std_logic_vector(31 downto 0);
signal instruction_size: std_logic_vector(1 downto 0);
signal rs1_dir,rs2_dir,rd_dir: std_logic_vector(4 downto 0);
signal rs1_busy_flag,rs2_busy_flag,dest_reg_busy_flag: std_logic;
signal fetch_branch_prediction_address: std_logic_vector(31 downto 0);
signal fetch_enable_parallel_cp: std_logic;

--signals de decode
signal stall_decode,reset_decode,stall_prev,read_from_register_UNASSIGNED: std_logic;
signal data_rs1,data_rs2,instruction_pointer_salida_decode: std_logic_vector(31 downto 0);
signal rs1_dir_UNASSIGNED,rs2_dir_UNASSIGNED,rd_dir_UNASSIGNED: std_logic_vector(4 downto 0);
signal decoded_instruction: std_logic_vector(90 downto 0);
signal will_write_flag_decode:std_logic;

--signals de jump 
signal stall_jump,reset_jump,reset_prev_to_jump: std_logic;
signal decoded_instruction_jump: std_logic_vector(90 downto 0);
signal jump_instruction_pointer,instruction_pointer_salida_jump,jump_result: std_logic_vector(31 downto 0);
signal enable_parallel_load_jump: std_logic;

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

signal iram1_addr,iram2_addr,iram3_addr,iram4_addr: std_logic_vector(31 downto 0);
signal iram1_response,iram2_response,iram3_response,iram4_response : std_logic_vector(7 downto 0);

--signals de la memoria de datos

signal memory_manager_forwarded_address: std_logic_vector(31 downto 0);
signal ram_1_response,ram_2_response,ram_3_response,ram_4_response: std_logic_vector(7 downto 0);
signal lowc_ram_1_response,lowc_ram_2_response,lowc_ram_3_response,lowc_ram_4_response: std_logic_vector(7 downto 0);
signal merge_ram_1_response,merge_ram_2_response,merge_ram_3_response,merge_ram_4_response: std_logic_vector(7 downto 0);
signal ram_1_write_data,ram_2_write_data,ram_3_write_data,ram_4_write_data: std_logic_vector(7 downto 0);
signal ram_enables: std_logic_vector(7 downto 0);
signal highest_address_bit_delay: std_logic; 

signal read_addr_r1_port2,read_addr_r2_port2,read_addr_r3_port2,read_addr_r4_port2: std_logic_vector(14 downto 0);
signal data_response_r1_port2,data_response_r2_port2,data_response_r3_port2,data_response_r4_port2 : std_logic_vector(7 downto 0);



begin
    

    fetch_stage: FETCH port map(
        stall_fetch,                                   
        reset,                                          -- No es necesario un reset al saltar para esta etapa (enable parallel hace esa funcion)                                
        clk,
        enable_parallel_load_jump,                      -- enable de carga paralela de una direccion en el contador de programa (lo envia jump)
        jump_result,                                    -- direccion a cargar en el contador de programa si el enable anterior esta activo
        instruccion_actual_entrada_fetch,               -- resultado de la busqueda en memoria de la instruccion, se envía directamente al pipeline
        instruction_pointer_PC,                         -- direccion en la que buscar una instruccion en memoria, se envia a IRAM_memory_manager
        instruccion_salida_fetch,                       -- salida de la instruccion actual al pipeline, se envia a decode
        instruction_pointer_salida_fetch                -- Contador de programa asociado a la instruccion que se pasa por el pipeline
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
            enable_parallel_load_jump);         -- Indicar al PC si debe ejecutar el salto (hacer carga paralela)
            
            
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
           memory_data_to_read,                   -- Datos resultado de leer en memoria (los envia el modulo de memoria)
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
        
   --memoria de instrucciones
     
   iram1: Instruction_memory port map(clk,iram1_addr(6 downto 0),iram1_response);
   iram2: Instruction_memory_2 port map(clk,iram2_addr(6 downto 0),iram2_response);  
   iram3: Instruction_memory_3 port map(clk,iram3_addr(6 downto 0),iram3_response);  
   iram4: Instruction_memory_4 port map(clk,iram4_addr(6 downto 0),iram4_response);       
                                         
   -- interfaz para memoria de instrucciones

    i_memory_manager: IRAM_memory_manager port map(
        instruction_pointer_PC,
        iram1_response, iram2_response, iram3_response, iram4_response,
        iram1_addr,iram2_addr,iram3_addr,iram4_addr,
        instruccion_actual_entrada_fetch
    );
   -- memorias de datos
        
   ram_1: Dual_port_RAM port map(
        memory_manager_forwarded_address(14 downto 0),                   -- Direccion de memoria que viene del memory manager
        read_addr_r1_port2,                                              -- Direccion de memoria que busca VGA controller memory interface en el puerto 2
        ram_1_write_data,                                                 -- Datos que memory manager desea escribir
        x"00",                                                            -- Puero 2 es solo para lectura del frame, nunca se escribe
        ram_enables(0),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        '0',                                                              -- Puerto 2 es solo para la lectura del frame, nunca se escribe
        clk,
        ram_1_response,                                                   -- Resultado de la busqueda en la memoria, se pasa a memory manager
        data_response_r1_port2                                            -- Resultado de la busqueda en memoria, se envia a VGA controller memory interface
        );

   ram_2: Dual_port_RAM port map(
        memory_manager_forwarded_address(14 downto 0),                   -- Direccion de memoria que viene del memory manager
        read_addr_r2_port2,                                              -- Direccion de memoria que busca VGA controller memory interface en el puerto 2
        ram_2_write_data,                                                 -- Datos que memory manager desea escribir
        x"00",                                                            -- Puero 2 es solo para lectura del frame, nunca se escribe
        ram_enables(1),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        '0',                                                              -- Puerto 2 es solo para la lectura del frame, nunca se escribe
        clk,
        ram_2_response,                                                    -- Resultado de la busqueda en la memoria, se pasa a memory manager
        data_response_r2_port2                                            -- Resultado de la busqueda en memoria, se envia a VGA controller memory interface
        );   

   ram_3: Dual_port_RAM port map(
        memory_manager_forwarded_address(14 downto 0),                   -- Direccion de memoria que viene del memory manager
        read_addr_r3_port2,                                              -- Direccion de memoria que busca VGA controller memory interface en el puerto 2
        ram_3_write_data,                                                 -- Datos que memory manager desea escribir
        x"00",                                                            -- Puero 2 es solo para lectura del frame, nunca se escribe
        ram_enables(2),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        '0',                                                              -- Puerto 2 es solo para la lectura del frame, nunca se escribe
        clk,
        ram_3_response,                                                    -- Resultado de la busqueda en la memoria, se pasa a memory manager
        data_response_r3_port2                                            -- Resultado de la busqueda en memoria, se envia a VGA controller memory interface
        );   

   ram_4: Dual_port_RAM port map(
        memory_manager_forwarded_address(14 downto 0),                   -- Direccion de memoria que viene del memory manager
        read_addr_r4_port2,                                              -- Direccion de memoria que busca VGA controller memory interface en el puerto 2
        ram_4_write_data,                                                 -- Datos que memory manager desea escribir
        x"00",                                                            -- Puero 2 es solo para lectura del frame, nunca se escribe
        ram_enables(3),                                                   -- Enable de escritura en memoria, lo proporciona memory manager
        '0',                                                              -- Puerto 2 es solo para la lectura del frame, nunca se escribe
        clk,
        ram_4_response,                                                    -- Resultado de la busqueda en la memoria, se pasa a memory manager
        data_response_r4_port2                                            -- Resultado de la busqueda en memoria, se envia a VGA controller memory interface
        );

   low_capacity_RAM_1 : low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_1_write_data,
        ram_enables(4),            
        clk,
        lowc_ram_1_response
   );

   low_capacity_RAM_2 : low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_2_write_data,
        ram_enables(5),            
        clk,
        lowc_ram_2_response
   ); 

   low_capacity_RAM_3 : low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_3_write_data,
        ram_enables(6),            
        clk,
        lowc_ram_3_response
   );

   low_capacity_RAM_4 : low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_4_write_data,
        ram_enables(7),                                                     -- if highest bit of memory address is 1, then search on low capacity RAM
        clk,
        lowc_ram_4_response
   );



    
  interfaz_RAM: memory_manager port map(
        clk,'0',reset,                                                                  -- At least for now, this phase never stalls
        rw_memory,                                                                      -- Enable de escritura en memoria, lo proporciona la etapa memory
        bytes_to_write_memory,                                                          -- Cantidad de bits a escribir (00 -> 8 bit, 01 -> 16 bit, else 32 bit). Lo proporciona memory
        memory_data_to_write,                                                           -- Datos a escribir en memoria, lo proporciona memory
        memory_dir(17 downto 0),                                                         -- Direccion en la que escribir en memoria, lo proporciona memory
        ram_1_response,ram_2_response,ram_3_response,ram_4_response,                    -- Respuestas de las memorias RAM, contienen datos a juntar. 
        lowc_ram_1_response,lowc_ram_2_response,lowc_ram_3_response,lowc_ram_4_response, -- datos enviados por las memorias de poca capacidad
        ram_1_write_data,ram_2_write_data,ram_3_write_data,ram_4_write_data,            -- Datos separados enviados a cada banco RAM para escribir en ellos
        memory_manager_forwarded_address(14 downto 0),                                   -- Direccion en la que escribir en memoria, reenviado por la interfaz a cada RAM
        memory_data_to_read,                                                            -- Datos leidos de la RAM, se envian a memory
        ram_enables                                                                     -- Enable de escritura de las 4 RAM. la cuarta contiene la direccion mas pequeña
  );
        
        
   banco_registros: Registros port map(
       data_rs1,                                    -- Datos de lectura de rs1, se envia a decode (primer operando)
       data_rs2,                                    -- Datos de lectura de rs2, se envia a decode (segundo operando) 
       debug_data_output,                            -- DEBUG
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
       dest_reg_busy_flag,
       debug_read_reg_addr
   
   );

    vga: vga_controller_memory_interface port map(
        reset,
        clk,
        hsync,
        vsync,
        rgb,
        read_addr_r1_port2,
        read_addr_r2_port2,
        read_addr_r3_port2,
        read_addr_r4_port2,
        data_response_r1_port2,
        data_response_r2_port2,
        data_response_r3_port2,
        data_response_r4_port2
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

   displayed_number <= debug_data_output(15 downto 0);


    
   
   

end Behavioral;