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
			 
			 address_a            : OUT  STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 address_b            : OUT  STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 data_a               : OUT  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 data_b               : OUT  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 wren_a               : OUT  STD_LOGIC                      := '0';
			 wren_b               : OUT  STD_LOGIC                      := '0';
			 q_a                  : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 q_b                  : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0')
		);
	END ppu_controller;
ARCHITECTURE behavior OF ppu_controller IS

	 --------- PPU SIGNALS ---------	
    SIGNAL done_signal, start_signal   : STD_LOGIC                      := '0';
    SIGNAL operation                   : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (others => '0');
    SIGNAL input_a         				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL input_b         				: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL output_data    					: STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
	
	 --------- States ---------
	 
    TYPE state_type IS (IDLE, READ_FROM_MEM, COMPUTE, WRITE_TO_MEM, INCREMENT_INDEXES, COMPLETED);
    SIGNAL current_state, next_state: state_type := IDLE;
	 
	 --------- memory variables ---------
	 
	 CONSTANT ARRAY_DEPTH     : INTEGER := 1536; -- Corresponds to 3KB with 16-bit words
	 
	 CONSTANT SECTION_A_START : INTEGER := 0;
	 CONSTANT SECTION_A_END   : INTEGER := 511;
	 
	 CONSTANT SECTION_B_START : INTEGER := 512;
	 CONSTANT SECTION_B_END   : INTEGER := 1023;
	 
	 CONSTANT SECTION_C_START : INTEGER := 1024;
	 CONSTANT SECTION_C_END   : INTEGER := 1535;
	 
	 --------- memory sections ---------
		 
	 SIGNAL index_a : INTEGER RANGE SECTION_A_START TO SECTION_A_END := SECTION_A_START;
	 SIGNAL index_b : INTEGER RANGE SECTION_B_START TO SECTION_B_END := SECTION_B_START;
	 SIGNAL index_c : INTEGER RANGE SECTION_C_START TO SECTION_C_END := SECTION_C_START;
  
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
		 
		 
		PROCESS (clk, reset)
		 variable has_incremented : BOOLEAN := FALSE;
		BEGIN
			IF reset = '0' THEN
				current_state     <= IDLE;
				next_state        <= IDLE;
				ppuctl_done       <= '0';
				wren_a <= '0';
				wren_b <= '0';
				address_a  <= (others => '0');  
				address_b  <= (others => '0');
				
			ELSIF rising_edge(clk) THEN
			
				  current_state <= next_state;
				  
				  case current_state is

						when IDLE =>
							 IF ppuctl_start = '1' THEN
								  index_a <= SECTION_A_START;
								  index_b <= SECTION_B_START;
								  index_c <= SECTION_C_START;
								  next_state <= READ_FROM_MEM;
							 END IF;

							 
						when READ_FROM_MEM =>
							 wren_a <= '0';
							 wren_b <= '0';
						
						    --calculate the addresses and send them to memory as they are connected
							 address_a <= std_logic_vector(to_unsigned(index_a, address_a'length));
							 address_b <= std_logic_vector(to_unsigned(index_b, address_b'length));
							 
							 --send what is stored there into the ppu
							 input_a    <= q_a;
							 input_b    <= q_b;
							 
							 next_state <= COMPUTE;

							 
						when COMPUTE =>
							 --start the computation
							 operation    <= ppuctl_opcode;    --this could be moved to the read from memory state?
							 start_signal <= '1';
							 
							 IF done_signal = '1' THEN
								  --successfully computed
								  start_signal <= '0';
								  next_state <= WRITE_TO_MEM;
							 END IF;

							when WRITE_TO_MEM =>
							 if index_a < SECTION_A_END then
								  address_a <= std_logic_vector(to_unsigned(index_c, address_a'length));
								  data_a    <= output_data;
								  wren_a    <= '1';

								  has_incremented := FALSE; -- Reset the flag
								  next_state <= INCREMENT_INDEXES;
							 else
								  next_state <= COMPLETED;
							 end if;

						when INCREMENT_INDEXES =>
							 if not has_incremented then
								  index_a <= index_a + 1;
								  index_b <= index_b + 1;
								  index_c <= index_c + 1;

								  has_incremented := TRUE; -- Set the flag to prevent further increment
							 end if;
							 next_state <= READ_FROM_MEM;
						  
						when COMPLETED =>
							 wren_a <= '0';
							 wren_b <= '0';
							 ppuctl_done <= '1';
							 -- TODO: reset section_A and section_B
							 
						when others =>
							 ppuctl_done <= '0';
							 next_state <= IDLE;
							 
				  end case;
				  
			END IF;
		END PROCESS;
		
END behavior;
-- ADD FLIPFLOPS TO THE INPUTS AND OUTPUTS LATER