------------------------------------------------------------------------------------------------
--- This module will manage the distribution of tasks to the PPUs.
--- It will also handle collecting results from the PPUs after computation.
--- We can have a simple FIFO or buffer system here to queue tasks
------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE iee.std_LOGIC_unsigned.all;

ENTITY ppu_controller IS
PORT(
	 opcode 		  : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Instruction opcode
	 
    clk          : IN  STD_LOGIC;
    reset        : IN  STD_LOGIC;  -- Asynchronous reset
    start_op     : IN  STD_LOGIC;  -- Signal to start an operation
    op_type      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- Type of operation (e.g., add, subtract, etc.)
    data_in_a    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input A
    data_in_b    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input B
    data_out     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data output
    op_complete  : OUT STD_LOGIC; -- Signal indicating operation completion
    error        : OUT STD_LOGIC  -- Signal indicating an error
);
END ppu_controller;

ARCHITECTURE behavior OF ppu_controller IS
    -- Internal signals and variables
    SIGNAL ppu_busy: STD_LOGIC := '0';
    SIGNAL mem_request: STD_LOGIC := '0'; -- Signal to request memory access
    SIGNAL mem_done: STD_LOGIC := '0';    -- Signal from memory indicating operation completion
    SIGNAL current_op: STD_LOGIC_VECTOR(3 DOWNTO 0); -- Current operation being processed

    -- Add other necessary internal signals and components here

BEGIN

    -- Memory Interface Process
    PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            -- Reset logic
            mem_request <= '0';
            mem_done <= '0';
        ELSIF rising_edge(clk) THEN
            -- Handle memory requests and completions
            -- This is a simplistic view and will depend on your memory_controller design
            IF mem_request = '1' THEN
                -- Interface with memory_controller to fetch/store data
            END IF;
            IF mem_done = '1' THEN
                -- Handle completion of memory operations
            END IF;
        END IF;
    END PROCESS;

    -- PPU Control Process
    PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            -- Reset logic
            ppu_busy <= '0';
            current_op <= (others => '0');
        ELSIF rising_edge(clk) THEN
            -- Main controller logic
            IF start_op = '1' AND ppu_busy = '0' THEN
                -- Set the current operation
                current_op <= op_type;
                -- Depending on the op_type, send data to PPU, set up PPU, etc.
                -- Request memory access if needed
                mem_request <= '1';
            ELSIF -- ... (other conditions)
                -- Handle other scenarios
            END IF;
        END IF;
    END PROCESS;

    -- ... (Other processes and logic)

END behavior;
