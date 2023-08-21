----------------------------------PPU_CONTROLLER---------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

	ENTITY ppu_controller IS
		PORT(
			 clk                  : IN  STD_LOGIC;
			 reset                : IN  STD_LOGIC                      := '1';
			 ppuctl_opcode        : IN  STD_LOGIC_VECTOR (7 DOWNTO 0)  := (others => '0');
			 ppuctl_start         : IN  STD_LOGIC                      := '0';
			 ppuctl_done          : OUT STD_LOGIC                      := '0';
			 
			 address_a            : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 address_b            : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 data_a               : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 data_b               : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 wren_a               : OUT STD_LOGIC                      := '0';
			 wren_b               : OUT STD_LOGIC                      := '0';
			 q_a                  : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 q_b                  : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
		
			 data_a2              : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 data_b2              : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 address_a2           : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 address_b2           : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 q_a2                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 q_b2                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 
			 memory_ready			 : IN STD_LOGIC 							  := '0'
		);
	END ppu_controller;
ARCHITECTURE behavior OF ppu_controller IS

	 --------- ALU SIGNALS ---------	
    SIGNAL done_signal, start_signal   : STD_LOGIC                      := '0';
    SIGNAL operation                   : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (others => '0');
    SIGNAL input_a         				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL input_b         				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL output_data    					: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
	
	 --------- ALU2 SIGNALS ---------	
    SIGNAL done_signal2, start_signal2 : STD_LOGIC                      := '0';   			  --might remove the start_signal2
    SIGNAL operation2                  : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (others => '0'); --might remove this
    SIGNAL input_a2        				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL input_b2         				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL output_data2   					: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
	 
	 --------- States ---------
	 
    TYPE state_type IS (IDLE, READ_FROM_MEM, WAIT_FOR_MEMORY, COMPUTE, WRITE_TO_MEM, INCREMENT_INDEXES, COMPLETED);
    SIGNAL current_state, next_state: state_type := IDLE;
	 
	 --------- memory variables ---------
	 
	 CONSTANT ARRAY_DEPTH     : INTEGER := 1536;
	 
	 CONSTANT SECTION_A_START : INTEGER := 0;
	 CONSTANT SECTION_A_END   : INTEGER := 511;
	 CONSTANT SECTION_A_MIDDLE: INTEGER := ((SECTION_A_START + SECTION_A_END) / 2)+1; --256
	 
	 CONSTANT SECTION_B_START : INTEGER := 512;
	 CONSTANT SECTION_B_END   : INTEGER := 1023;
	 CONSTANT SECTION_B_MIDDLE: INTEGER := ((SECTION_B_START + SECTION_B_END) / 2)+1; --768
	 
	 CONSTANT SECTION_C_START : INTEGER := 1024;
	 CONSTANT SECTION_C_END   : INTEGER := 1535;
	 CONSTANT SECTION_C_MIDDLE: INTEGER := ((SECTION_C_START + SECTION_C_END) / 2)+1; --1280
	 
	 --------- memory sections ---------
		 
	 SIGNAL index_a_1 : INTEGER RANGE SECTION_A_START TO SECTION_A_MIDDLE-1 := SECTION_A_START;
	 SIGNAL index_b_1 : INTEGER RANGE SECTION_B_START TO SECTION_B_MIDDLE-1 := SECTION_B_START;
	 SIGNAL index_c_1 : INTEGER RANGE SECTION_C_START TO SECTION_C_MIDDLE-1 := SECTION_C_START;
	 
	 SIGNAL index_a_2 : INTEGER RANGE SECTION_A_MIDDLE TO SECTION_A_END := SECTION_A_MIDDLE; --256
    SIGNAL index_b_2 : INTEGER RANGE SECTION_B_MIDDLE TO SECTION_B_END := SECTION_B_MIDDLE;    
    SIGNAL index_c_2 : INTEGER RANGE SECTION_C_MIDDLE TO SECTION_C_END := SECTION_C_MIDDLE;
	 
    component ppu
        PORT (
			clk          : in  STD_LOGIC;
			reset        : in  STD_LOGIC;
			  
			operation    : in  STD_LOGIC_VECTOR(7 downto 0)  := (others => '0'); 
			  
			input_a      : in  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			input_b      : in  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			output_data  : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			  
			start_signal : in  STD_LOGIC                     := '0';
			done_signal  : out STD_LOGIC                     := '0'
		 );
    end component;
  
BEGIN

		-- Instantiate the PPU
		alu: ppu PORT MAP (
			 clk           => clk,
			 reset         => reset,
			 
			 operation     => operation,
			 
			 input_a       => input_a,
			 input_b       => input_b,
			 output_data   => output_data,
			 
			 start_signal  => start_signal,
			 done_signal   => done_signal  
		);
		
		alu2: ppu PORT MAP(
			 clk           => clk,
			 reset         => reset,
			 
			 operation     => operation2, --both ALUs have the same operation
			 
			 input_a       => input_a2,
			 input_b       => input_b2,
			 output_data   => output_data2,
			 
			 start_signal  => start_signal2, --both ALUs will be started at the same time
			 done_signal   => done_signal2
		);
	
		 
		PROCESS (clk, reset)
		variable has_incremented : BOOLEAN := FALSE;
		BEGIN
			IF reset = '0' THEN
				--zeros out the outputs
				current_state <= IDLE;
				next_state    <= IDLE;
				ppuctl_done   <= '0';
				wren_a     	  <= '0';
				wren_b 	  	  <= '0';
				address_a     <= (others => '0');  
				address_b     <= (others => '0');
				address_a2    <= (others => '0');
				address_b2    <= (others => '0');
				
				
			ELSIF rising_edge(clk) THEN
			
				  current_state <= next_state;
				  
				  case current_state is

						when IDLE =>
							 IF ppuctl_start = '1' THEN
								  wren_a <= '0';
								  wren_b <= '0';
							 
								  index_a_1 <= SECTION_A_START;
								  index_b_1 <= SECTION_B_START;
								  index_c_1 <= SECTION_C_START;
								  
								  index_a_2 <= SECTION_A_MIDDLE;
								  index_b_2 <= SECTION_B_MIDDLE;
								  index_c_2 <= SECTION_C_MIDDLE;
								  
								  next_state <= READ_FROM_MEM;
							 END IF;

							 
						when READ_FROM_MEM =>
							 wren_a <= '0';
							 wren_b <= '0';
						
						    --calculate the addresses and send them to memory as they are connected
							 address_a  <= std_logic_vector(to_unsigned(index_a_1, address_a'length));
							 address_b  <= std_logic_vector(to_unsigned(index_b_1, address_b'length));
							 
							 address_a2 <= std_logic_vector(to_unsigned(index_a_2, address_a'length));
							 address_b2 <= std_logic_vector(to_unsigned(index_b_2, address_b'length));
							 
							 next_state <= WAIT_FOR_MEMORY;
						
						when WAIT_FOR_MEMORY =>
							if memory_ready = '1' then
								next_state <= COMPUTE;
							end if;
							 
						when COMPUTE =>
							 --send what is stored there into the ppu
							 input_a    <= q_a;
							 input_b    <= q_b;
							 
							 input_a2   <= q_a2;
							 input_b2   <= q_b2;
							 --start the computation
							 operation     <= ppuctl_opcode;
							 operation2    <= ppuctl_opcode;
							 
							 start_signal  <= '1';
							 start_signal2 <= '1';
							 
							 IF done_signal = '1' AND done_signal2 = '1' THEN
								  --successfully computed
								  start_signal  <= '0';
								  start_signal2 <= '0';
								  
								  next_state <= WRITE_TO_MEM;
							 END IF;

							when WRITE_TO_MEM =>
							 if (index_a_1 < (SECTION_A_MIDDLE-1) OR index_a_2 < (SECTION_A_END) ) then --if it's still within the range
							 
								  address_a  <= std_logic_vector(to_unsigned(index_c_1, address_a'length));
								  address_b  <= std_logic_vector(to_unsigned(index_c_2, address_a'length));
								  
								  address_a2 <= std_logic_vector(to_unsigned(index_c_1, address_a'length));
								  address_b2 <= std_logic_vector(to_unsigned(index_c_2, address_a'length));
								  
								  data_a     <= output_data;
								  data_b     <= output_data2;
								  
								  data_a2    <= output_data;
								  data_b2    <= output_data2;
								  
								  wren_a     <= '1';
								  wren_b     <= '1';

								  has_incremented := FALSE; -- Reset the flag
								  next_state <= INCREMENT_INDEXES;
							 
							 else
								  next_state <= COMPLETED;
							 end if;

						when INCREMENT_INDEXES =>
							 if not has_incremented then
							 
								  if index_a_1 < SECTION_A_MIDDLE-1 then
										index_a_1 <= index_a_1 + 1;
								  end if;
								  if index_b_1 < SECTION_B_MIDDLE-1 then
										index_b_1 <= index_b_1 + 1;
								  end if;
								  if index_c_1 < SECTION_C_MIDDLE-1 then
										index_c_1 <= index_c_1 + 1;
								  end if;
								  if index_a_2 < SECTION_A_END then
										index_a_2 <= index_a_2 + 1;
								  end if;
								  if index_b_2 < SECTION_B_END then
										index_b_2 <= index_b_2 + 1;
								  end if;
								  if index_c_2 < SECTION_C_END then
										index_c_2 <= index_c_2 + 1;
								  end if;
								  
								  has_incremented := TRUE; -- Set the flag to prevent further increment
							 end if;
							 next_state <= READ_FROM_MEM;
						  
						when COMPLETED =>
							 wren_a <= '0';
							 wren_b <= '0';
							 
							 ppuctl_done <= '1';
							 
							 --reseting the indexes
							 index_a_1 <= SECTION_A_START;
							 index_b_1 <= SECTION_B_START;
							 index_c_1 <= SECTION_C_START;
							  
							 index_a_2 <= SECTION_A_MIDDLE;
							 index_b_2 <= SECTION_B_MIDDLE;
							 index_c_2 <= SECTION_C_MIDDLE;
							 
						when others =>
							 ppuctl_done <= '0';
							 next_state <= IDLE;
							 
				  end case;
				  
			END IF;
		END PROCESS;
		
END behavior;
-- ADD FLIPFLOPS TO THE INPUTS AND OUTPUTS LATER