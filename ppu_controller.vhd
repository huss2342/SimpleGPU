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
    address_a     : OUT STD_LOGIC_VECTOR (9 DOWNTO 0) := (others => '0');
    address_b     : OUT STD_LOGIC_VECTOR (9 DOWNTO 0) := (others => '0');
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
	 
    SIGNAL index_a : INTEGER RANGE 0 TO ARRAY_DEPTH - 1 := 0;        -- Range for array A
	 SIGNAL index_b : INTEGER RANGE 0 TO ARRAY_DEPTH - 1 := ARRAY_DEPTH - 1; -- Range for array B
  

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
				  -- Initialization code...
			 ELSIF rising_edge(clk) THEN
				  current_state <= next_state;
				  case current_state is
						when IDLE =>
							 IF start = '1' THEN
								  index_a <= 0;
								  index_b <= ARRAY_DEPTH - 1; -- Start from the end of array B
								  next_state <= READ_FROM_MEM;
							 END IF;

						when READ_FROM_MEM =>
							 address_a <= std_logic_vector(to_unsigned(index_a, address_a'length));
							 address_b <= std_logic_vector(to_unsigned(index_b, address_b'length));
							 int_ppu_a <= q_a;
							 int_ppu_b <= q_b;
							 next_state <= COMPUTE;

						when COMPUTE =>
							 IF operation_done = '1' THEN
								  next_state <= WRITE_TO_MEM;
							 END IF;

						when WRITE_TO_MEM =>
							 address_a <= std_logic_vector(to_unsigned(index_a + ARRAY_DEPTH, address_a'length)); -- Write to array C
							 data_a <= int_ppu_result;
							 mem_wren_a <= '1';
							 if index_a < ARRAY_DEPTH - 1 then
								  index_a <= index_a + 1;
								  index_b <= index_b - 1;
								  next_state <= READ_FROM_MEM;
							 else
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

    -- done <= operation_done AND NOT reset;
END behavior;
