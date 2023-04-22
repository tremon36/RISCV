library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Pipeline_completo is
    port(
        reset,clk,csr_module_interrupt_input: in std_logic;
        debug_read_reg_addr: in std_logic_vector(4 downto 0);
        Anode_Activate : out STD_LOGIC_VECTOR (7 downto 0);-- 4 Anode signals
        LED_out : out STD_LOGIC_VECTOR (6 downto 0);
        hsync,vsync: out std_logic;
        rgb: out std_logic_vector(11 downto 0)
        );
end Pipeline_completo;

architecture Behavioral of Pipeline_completo is

 -- DEBUG signal
 signal debug_data_output: std_logic_vector(31 downto 0);

 -- Señales globales del pipeline
signal ISR_context : std_logic; 
signal csr_module_interrupt_input_internal : std_logic;
signal prev_interrupt_input: std_logic;
signal int_pulse: std_logic;

-- display de 7 segmentos
signal displayed_number : std_logic_vector (31 downto 0);

-- signals de program counter 
signal stall_pc, enable_parallel_load_pc: std_logic;
signal instruction_pointer_PC,parallel_load_data_pc: std_logic_vector(31 downto 0);

-- signals de fetch
signal stall_fetch,r_w_instruction_memory,reset_fetch: std_logic;
signal instruccion_actual_entrada_fetch,instruccion_salida_fetch,instruction_memory_dir_request: std_logic_vector(31 downto 0);
signal instruction_pointer_salida_fetch: std_logic_vector(31 downto 0);
signal instruction_size: std_logic_vector(1 downto 0);
signal rs1_dir,rs2_dir,rd_dir: std_logic_vector(4 downto 0);
signal rs1_busy_flag,rs2_busy_flag,dest_reg_busy_flag: std_logic;
signal fetch_branch_prediction_address: std_logic_vector(31 downto 0);
signal fetch_enable_parallel_cp: std_logic;
signal invalidate_out_fetch: std_logic;
signal invalidate_fetch: std_logic;

-- signals de decode
signal stall_decode,reset_decode,stall_prev,read_from_register_UNASSIGNED: std_logic;
signal data_rs1,data_rs2,instruction_pointer_salida_decode: std_logic_vector(31 downto 0);
signal rs1_dir_UNASSIGNED,rs2_dir_UNASSIGNED,rd_dir_UNASSIGNED: std_logic_vector(4 downto 0);
signal decoded_instruction: std_logic_vector(90 downto 0);
signal will_write_flag_decode:std_logic;
signal invalidate_decode,invalidate_out_decode: std_logic;
signal is_empty_decode: std_logic;

-- signals de jump 
signal stall_jump,reset_jump,reset_prev_to_jump: std_logic;
signal decoded_instruction_jump: std_logic_vector(90 downto 0);
signal jump_instruction_pointer,instruction_pointer_salida_jump,jump_result: std_logic_vector(31 downto 0);
signal enable_parallel_load_jump: std_logic;
signal invalidate_jump,invalidate_out_jump: std_logic;
signal is_empty_jump: std_logic;
signal exit_ISR: std_logic;

-- signals de execute 
signal stall_exe,reset_exe,stall_previous_exe:std_logic;
signal instruction_pointer_salida_exe: std_logic_vector(31 downto 0);
signal decoded_instruction_exe: std_logic_vector(90 downto 0);
signal invalidate_exe,invalidate_out_exe: std_logic;

-- signals de memory 
signal stall_memory,reset_memory:std_logic;
signal memory_dir,memory_data_to_write,memory_data_to_read: std_logic_vector(31 downto 0);
signal rw_memory,stall_previous_memory: std_logic;
signal decoded_instruction_memory: std_logic_vector(90 downto 0);
signal bytes_to_write_memory: std_logic_vector(1 downto 0);
signal invalidate_memory,invalidate_out_memory: std_logic;

-- signals de write 

signal reset_write: std_logic;
signal stall_write,enable_write_to_registers: std_logic;
signal data_to_write_to_registers: std_logic_vector(31 downto 0);
signal register_direction_to_write: std_logic_vector(4 downto 0);
signal invalidate_write,invalidate_out_write: std_logic;


-- signals de la memoria de instrucciones 

signal iram1_addr,iram2_addr,iram3_addr,iram4_addr: std_logic_vector(31 downto 0);
signal iram1_response,iram2_response,iram3_response,iram4_response : std_logic_vector(7 downto 0);

-- signals de la memoria de datos

signal memory_manager_forwarded_address: std_logic_vector(31 downto 0);
signal ram_1_response,ram_2_response,ram_3_response,ram_4_response: std_logic_vector(7 downto 0);
signal lowc_ram_1_response,lowc_ram_2_response,lowc_ram_3_response,lowc_ram_4_response: std_logic_vector(7 downto 0);
signal merge_ram_1_response,merge_ram_2_response,merge_ram_3_response,merge_ram_4_response: std_logic_vector(7 downto 0);
signal ram_1_write_data,ram_2_write_data,ram_3_write_data,ram_4_write_data: std_logic_vector(7 downto 0);
signal ram_enables: std_logic_vector(7 downto 0);
signal highest_address_bit_delay: std_logic; 

signal read_addr_r1_port2,read_addr_r2_port2,read_addr_r3_port2,read_addr_r4_port2: std_logic_vector(14 downto 0);
signal data_response_r1_port2,data_response_r2_port2,data_response_r3_port2,data_response_r4_port2 : std_logic_vector(7 downto 0);

-- signals para los control and status registers

signal csr_module_launch_ISR,write_csr : std_logic;
signal csr_module_pc_to_save,csr_module_mepc,csr_bitmask,csr_write_data,csr_read_data: std_logic_vector(31 downto 0);
signal csr_module_interrupt_cause : std_logic_vector(4 downto 0);
signal csr_module_mret_executed: std_logic;
signal csr_address: std_logic_vector(11 downto 0);



begin

     -- @TODO replace with correct value
     csr_module_interrupt_cause <= "00000";

    
    fetch_stage: entity work.FETCH port map(
        stall_fetch,                                   
        reset,                                          -- No es necesario un reset al saltar para esta etapa (enable parallel hace esa funcion)                                
        clk,
        enable_parallel_load_jump,                         -- enable de carga paralela de una direccion en el contador de programa (lo envia jump o interrupcion)
        jump_result,                          -- direccion a cargar en el contador de programa si el enable anterior esta activo
        instruccion_actual_entrada_fetch,               -- resultado de la busqueda en memoria de la instruccion, se envía directamente al pipeline
        instruction_pointer_PC,                         -- direccion en la que buscar una instruccion en memoria, se envia a IRAM_memory_manager
        instruccion_salida_fetch,                       -- salida de la instruccion actual al pipeline, se envia a decode
        instruction_pointer_salida_fetch,               -- Contador de programa asociado a la instruccion que se pasa por el pipeline
        invalidate_fetch,                               -- Invalidar la instruccion de la que se esta haciendo fetch. Señal externa para interrupciones
        invalidate_out_fetch                            -- Flag de invalidacion de salida de la instruccion
        );

    
    decode_stage: entity work.DECODE port map(
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
            decoded_instruction,               -- Instruccion procesada y decodificada, para continuar por el pipeline
            will_write_flag_decode,
            invalidate_decode,                   -- Inmediately (asynchronously) invalidate the current instruction in the decode stage
            invalidate_out_fetch,              
            invalidate_out_decode,
            is_empty_decode
            );                                  
            
    jump_stage: entity work.JUMP port map(
            reset_jump,
            stall_jump,
            clk,
            decoded_instruction,                -- Instruccion decodificada que viene de la etapa decode
            decoded_instruction_jump,           -- Reenviar la instruccion decodificada por el pipeline, un ciclo despues de que llegue
            instruction_pointer_salida_decode,  -- PC asociado a la instruccion que esta pasando por la etapa
            csr_module_mepc,
            jump_result,                        -- Direccion de instruccion a la que saltar de ser necesario (es el valor de parallel load del PC)
            reset_prev_to_jump,                 -- Resetear las etapas anteriores si se salta, pues contienen instrucciones que no hay que ejecutar
            enable_parallel_load_jump,          -- Indicar al PC si debe ejecutar el salto (hacer carga paralela)
            invalidate_jump,                    -- Inmediately (asynchronously) invalidate the current instruction in the jump stage
            invalidate_out_decode,
            invalidate_out_jump,
            is_empty_jump,                       -- Indicates whether jump is processing an instruction or not. Used for interrupt and exception handling
            exit_ISR                             -- Sent to the CSR module when MRET instruction executes its jump stage
            
            );         
            
            
    execute_stage: entity work.EXE port map(                    -- Campos de la instruccion decodificada
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
           decoded_instruction_exe,                  -- salida de instruccion de exe para pasar por el pipeline
           invalidate_exe,
           invalidate_out_jump,
           invalidate_out_exe
           
           );                
           
   memory_stage: entity work.MEMORY port map( 
           stall_memory,
           reset_memory,
           clk,
           memory_dir,                             -- Direccion de memoria de la que se va a leer/escribir 
           memory_data_to_write,                   -- Datos que se van a escribir en memoria (se envia al modulo de memoria)
           rw_memory,                              -- Indicacion a la memoria de si se va a leer (0) o a escribir (1)
           stall_previous_memory,                  -- Parada del pipeline hasta obtener un resultado de memoria 
           decoded_instruction_exe,                -- Instruccion que pasa la etapa execute a las siguientes
           decoded_instruction_memory,             -- Instruccion a propagar a las siguientes etapas del pipeline
           bytes_to_write_memory,                   -- Cantidad de bytes que van a ser escritos/leidos en memoria

           csr_address,                            -- CSR address to read/write. Sent to the CSR module
           write_csr,                              -- Enable write on the CSR. Sent to the csr module
           csr_bitmask,                            -- bitmask to write CSR. Sent to the csr module            
           csr_write_data,                          -- data to be written in CSR. Sent to the csr module

           invalidate_memory,
           invalidate_out_exe,
           invalidate_out_memory
           
           );                 
           
   write_stage: entity work.WRITE port map(
           decoded_instruction_memory,            -- Instruccion que pasa la etapa memory 
           reset_write,                           
           clk,
           stall_write,
           memory_data_to_read,                   -- Datos resultado de leer en memoria (los envia el modulo de memoria)
           csr_read_data,                         -- Datos resultado de leer CSR (los envia modulo CSR)
           data_to_write_to_registers,            -- datos de escritura en registros (mandar a los registros)
           register_direction_to_write,           -- direccion de escritura en los registros
           enable_write_to_registers,             -- Indicar a los registros si se debe escribir o no
           invalidate_write,
           invalidate_out_memory,
           invalidate_out_write
           
           );            
                   
            
   --registros que contienen el contador de programa asociado a la instrucccion que se esta ejecutando en esa etapa del pipeline 
   
   registro_decode_cp: entity work.RegistroF port map (
        reset_decode,stall_decode,clk,instruction_pointer_salida_fetch,instruction_pointer_salida_decode);
        
   registro_jump_cp: entity work.RegistroF port map (
        reset_jump,stall_jump,clk,instruction_pointer_salida_decode,instruction_pointer_salida_jump);
        
   registro_exe_cp: entity work.RegistroF port map (
        reset_exe,stall_exe,clk,instruction_pointer_salida_jump,instruction_pointer_salida_exe);
        
   --memoria de instrucciones
     
   iram1: entity work.Instruction_memory port map(clk,iram1_addr(6 downto 0),iram1_response);
   iram2: entity work.Instruction_memory_2 port map(clk,iram2_addr(6 downto 0),iram2_response);  
   iram3: entity work.Instruction_memory_3 port map(clk,iram3_addr(6 downto 0),iram3_response);  
   iram4: entity work.Instruction_memory_4 port map(clk,iram4_addr(6 downto 0),iram4_response);       
                                         
   -- interfaz para memoria de instrucciones

    i_memory_manager: entity work.IRAM_memory_manager port map(
        instruction_pointer_PC,
        iram1_response, iram2_response, iram3_response, iram4_response,
        iram1_addr,iram2_addr,iram3_addr,iram4_addr,
        instruccion_actual_entrada_fetch
    );
   -- memorias de datos
        
   ram_1: entity work.Dual_port_RAM port map(
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

   ram_2: entity work.Dual_port_RAM port map(
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

   ram_3: entity work.Dual_port_RAM port map(
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

   ram_4: entity work.Dual_port_RAM port map(
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

   low_capacity_RAM_1 : entity work.low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_1_write_data,
        ram_enables(4),            
        clk,
        lowc_ram_1_response
   );

   low_capacity_RAM_2 : entity work.low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_2_write_data,
        ram_enables(5),            
        clk,
        lowc_ram_2_response
   ); 

   low_capacity_RAM_3 : entity work.low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_3_write_data,
        ram_enables(6),            
        clk,
        lowc_ram_3_response
   );

   low_capacity_RAM_4 : entity work.low_capacity_RAM port map(
        memory_manager_forwarded_address(12 downto 0),                      -- Solamente tiene 13 bits la de poca capacidad
        ram_4_write_data,
        ram_enables(7),                                                     -- if highest bit of memory address is 1, then search on low capacity RAM
        clk,
        lowc_ram_4_response
   );



    
  interfaz_RAM: entity work.memory_manager port map(
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
        
        
   banco_registros: entity work.Registros port map(
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
       invalidate_out_write,                        -- Flag de invalidacion de escritura. Se escriben los flags, pero no los datos
       debug_read_reg_addr
   
   );

   -- CSR registers

   csr: entity work.CSR_module port map(
     reset,clk,
     csr_module_interrupt_input_internal,   -- Interrupt request sent by the interrupt controller module 
     csr_module_pc_to_save,                 -- Program counter to save in MEPC register when an interrupt happens. Served by jump*
     csr_module_interrupt_cause,            -- Cause of the exception/interruption. Refer to documentation. 
     csr_module_mepc,                       -- Saved program counter to be restored after an ISR ends. MEPC register
     invalidate_fetch,                      -- Load program counter with interruption vector address request.
     exit_ISR,                              -- signal sent to restore interruption-related CSR when a MRET instruction is executed
     write_csr,                             -- flag to write/read csr. 0 = read.Served by memory stage
     csr_bitmask,                           -- bitmask to apply to the write data. Served by memory stage
     csr_address,                           -- address to read/write CSR. Served by memory
     csr_write_data,                        -- data to be written in CSR. Served by memory stage
     csr_read_data                          -- data to be read from the CSR. Send to writeback stage
);

    vga: entity work.vga_controller_memory_interface port map(
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
   
   segmento: entity work.seven_segment_display_VHDL port map (clk,reset,Anode_Activate,LED_out,displayed_number );
        
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

   displayed_number <= debug_data_output;

   -- control de invalidaciones


   invalidate_decode <= invalidate_fetch; -- Invalidate instruction at decode on ISR
   invalidate_jump <= invalidate_fetch;   -- Invalidate instruction at jump on ISR
   invalidate_exe <= '0';
   invalidate_memory <= '0';
   invalidate_write <= '0';

   csr_module_pc_to_save <= instruction_pointer_salida_decode when is_empty_jump = '0' else 
                            instruction_pointer_salida_fetch when is_empty_decode = '0' else 
                            instruction_pointer_PC;                                            -- Save PC of the instruction at the branch stage when interrupt arrives. If it is empty, go back until
                                                                                               -- the currently checked stage is not.
   

    extern_int_handler: entity work.external_interrupts_module port map (  -- Stabilize interrupt for rising edge. Minimun of ten cycles to launch ISR
               csr_module_interrupt_input,
               reset,
               clk,
               csr_module_interrupt_input_internal
    );
   
   

end Behavioral;