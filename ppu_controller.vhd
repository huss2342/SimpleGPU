----------------------------------PPU_CONTROLLER---------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ppu_controller IS
PORT(
    clk           : IN  STD_LOGIC;
    opcode        : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
    start         : IN  STD_LOGIC;
    reset         : IN  STD_LOGIC;
    address_a     : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    address_b     : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    data_a        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    data_b        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    mem_wren_a    : OUT STD_LOGIC := '0';
    mem_wren_b    : OUT STD_LOGIC := '0';
    q_a           : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
    q_b           : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
    ppu_a         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    ppu_b         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    ppu_operation : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
    ppu_result    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    done          : OUT STD_LOGIC := '0'
);
END ppu_controller;

ARCHITECTURE behavior OF ppu_controller IS

    SIGNAL operation_done    : STD_LOGIC := '0';
    SIGNAL int_ppu_operation : STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
    SIGNAL int_ppu_a         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL int_ppu_b         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL int_ppu_result    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');

    TYPE state_type IS (IDLE, READ_FROM_MEM, COMPUTE, WRITE_TO_MEM, COMPLETED);
    SIGNAL current_state, next_state: state_type := IDLE;
	 
	 CONSTANT ARRAY_DEPTH : INTEGER := 1536; -- Corresponds to 3KB with 16-bit words
	 
 
	 -- Adding these constants to define the start and end addresses for sections A, B, and C
	 CONSTANT SECTION_A_START : INTEGER := 0;
	 CONSTANT SECTION_A_END : INTEGER := 511;
	 
	 CONSTANT SECTION_B_START : INTEGER := 512;
	 CONSTANT SECTION_B_END : INTEGER := 1023;
	 
	 CONSTANT SECTION_C_START : INTEGER := 1024;
	 CONSTANT SECTION_C_END : INTEGER := 1535;

		 
	 SIGNAL index_a : INTEGER RANGE SECTION_A_START TO SECTION_A_END := SECTION_A_START;
	 SIGNAL index_b : INTEGER RANGE SECTION_B_START TO SECTION_B_END := SECTION_B_START;
	 SIGNAL index_c : INTEGER RANGE SECTION_C_START TO SECTION_C_END := SECTION_C_START;
  
    component ppu
        Port (
			clk          : in  STD_LOGIC;
			reset        : in  STD_LOGIC;
			  
			operation    : in  STD_LOGIC_VECTOR(7 downto 0);
			  
			input_a      : in  STD_LOGIC_VECTOR(15 downto 0);
			input_b      : in  STD_LOGIC_VECTOR(15 downto 0);
			output_data  : out STD_LOGIC_VECTOR(15 downto 0);
			  
			start_signal : in  STD_LOGIC;
			done_signal  : out STD_LOGIC
		 );
    end component;

BEGIN

		-- Instantiate the PPU
		alu: ppu PORT MAP (
			 clk           => clk,
			 reset         => reset,
			 operation     => int_ppu_operation,
			 input_a       => int_ppu_a,
			 input_b       => int_ppu_b,
			 output_data   => int_ppu_result,
			 start_signal  => start,
			 done_signal   => operation_done  
		);



		ppu_operation <= int_ppu_operation;
		ppu_a <= int_ppu_a;
		ppu_b <= int_ppu_b;
		ppu_result <= int_ppu_result;
		
		
		PROCESS (clk, reset)
		BEGIN
			IF reset = '0' THEN
				current_state <= IDLE;
				  next_state <= IDLE;
				  done <= '0';
				  mem_wren_a <= '0';
				  mem_wren_b <= '0';
				  address_a <= (others => '0');  
				  address_b <= (others => '0');
			ELSIF rising_edge(clk) THEN
				  current_state <= next_state;
				  
				  case current_state is
						when IDLE =>
							 IF start = '1' THEN
								  index_a <= SECTION_A_START;
								  index_b <= SECTION_B_START;
								  index_c <= SECTION_C_START;
								  next_state <= READ_FROM_MEM;
							 END IF;

						when READ_FROM_MEM =>
							 address_a <= std_logic_vector(to_unsigned(index_a, address_a'length));
							 address_b <= std_logic_vector(to_unsigned(index_b, address_b'length));
							 int_ppu_a <= q_a;
							 int_ppu_b <= q_b;
							 next_state <= COMPUTE;

						when COMPUTE =>
							 int_ppu_operation <= opcode; 
							 IF operation_done = '1' THEN
								  next_state <= WRITE_TO_MEM;
							 END IF;

						when WRITE_TO_MEM =>
							 address_a <= std_logic_vector(to_unsigned(index_c, address_a'length));
							 data_a <= int_ppu_result;
							 mem_wren_a <= '1';
						    index_a <= index_a + 1;
						    index_b <= index_b + 1;
						    index_c <= index_c + 1;
						    next_state <= READ_FROM_MEM;
							 if index_a >= SECTION_A_END then
								  next_state <= COMPLETED;
							 end if;

						when COMPLETED =>
							 mem_wren_a <= '0';
							 mem_wren_b <= '0';
							 done <= '1';

						when others =>
							 done <= '0';
							 next_state <= IDLE;
				  end case;
				  
			END IF;
		END PROCESS;
END behavior;
