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
    address_a     : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    address_b     : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    data_a        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    data_b        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    mem_wren_a    : OUT STD_LOGIC;
    mem_wren_b    : OUT STD_LOGIC;
    q_a           : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
    q_b           : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
    ppu_a         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    ppu_b         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    ppu_operation : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    ppu_result    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    done          : OUT STD_LOGIC
);
END ppu_controller;

ARCHITECTURE behavior OF ppu_controller IS

    SIGNAL current_address : STD_LOGIC_VECTOR (9 DOWNTO 0) := (others => '0');
    SIGNAL operation_done  : STD_LOGIC := '0';
	 
	 SIGNAL int_ppu_operation : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL int_ppu_a : STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL int_ppu_b : STD_LOGIC_VECTOR (15 DOWNTO 0);


    TYPE state_type IS (IDLE, READ_FROM_MEM, COMPUTE, WRITE_TO_MEM, COMPLETED);
    SIGNAL current_state, next_state: state_type;
	 SIGNAL int_ppu_result : STD_LOGIC_VECTOR(15 DOWNTO 0);

    CONSTANT ARRAY_DEPTH : INTEGER := 1024;

    component ppu
        Port (
			clk          : in  STD_LOGIC;
			reset        : in  STD_LOGIC;
			  
			operation    : in  STD_LOGIC_VECTOR(7 downto 0); -- Assuming 8-bit control for operations
			  
			input_a      : in  STD_LOGIC_VECTOR(15 downto 0); -- Assuming 16-bit operands
			input_b      : in  STD_LOGIC_VECTOR(15 downto 0);
			output_data  : out STD_LOGIC_VECTOR(15 downto 0);
			  
			start_signal : in  STD_LOGIC;
			done_signal  : out STD_LOGIC
		 );
    end component;

BEGIN

    -- Instantiate the PPU
		alu: ppu PORT MAP (
			 operation    => int_ppu_operation,
			 input_a      => int_ppu_a,
			 input_b      => int_ppu_b,
			 output_data  => int_ppu_result
		);



		ppu_operation <= int_ppu_operation;
		ppu_a <= int_ppu_a;
		ppu_b <= int_ppu_b;
		ppu_result <= int_ppu_result;
		
		
		FSM: PROCESS (clk, reset)
		BEGIN
			 IF reset = '0' THEN
				  current_state <= IDLE;
				  done <= '0';
				  mem_wren_a <= '0';
				  mem_wren_b <= '0';
			 ELSIF rising_edge(clk) THEN
				  IF start = '1' THEN
						current_state <= next_state;
				  END IF;
			 END IF;
		END PROCESS;

		FSM_LOGIC: PROCESS (clk, reset)
		BEGIN
			 IF reset = '0' THEN
				  next_state <= IDLE;
			 ELSIF rising_edge(clk) THEN
				  case current_state is
						when IDLE =>
							 IF start = '1' THEN
								  current_address <= (others => '0');
								  next_state <= READ_FROM_MEM;
							 END IF;

						when READ_FROM_MEM =>
							 mem_wren_a <= '0';
							 mem_wren_b <= '0';
							 next_state <= COMPUTE;

						when COMPUTE =>
							 mem_wren_a <= '0';
							 mem_wren_b <= '0';
							 next_state <= WRITE_TO_MEM;

						when WRITE_TO_MEM =>
							 address_a <= std_logic_vector(unsigned(current_address) + to_unsigned(512, 10));
							 -- Im using the to_unsigned function to convert the integer value 512 
							 -- (which is the decimal representation of the binary value 1000000000) 
							 -- to an unsigned type with a size of 10 bits.
							 data_a <= int_ppu_result;
							 mem_wren_a <= '1';
							 if unsigned(current_address) < to_unsigned(ARRAY_DEPTH - 1, current_address'length)  then
								  current_address <= std_logic_vector(unsigned(current_address) + to_unsigned(1, current_address'length));
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


    -- Interface to memory_controller
    address_a <= current_address;
    address_b <= current_address;

    -- Interface to PPU
    ppu_a <= q_a;
    ppu_b <= q_b;
    ppu_operation <= opcode;

    done <= operation_done;
END behavior;
