----------------------------------MEMORY_CONTROLLER---------------------------------------------
--- This module will handle read/write operations to/from the VRAM.
--- It will interface with the FPGA's on-chip memory.
------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY memory_controller IS
PORT(
    address_a     : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    address_b     : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    data_a        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    data_b        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    inclock       : IN STD_LOGIC;
    outclock      : IN STD_LOGIC;
    wren_a        : IN STD_LOGIC;
    wren_b        : IN STD_LOGIC;
    write_protect : IN STD_LOGIC; -- new signal for write protection
    reset         : IN STD_LOGIC; -- new reset signal
    q_a           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    q_b           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    read_activity : OUT STD_LOGIC; -- indicates a read operation
    write_activity: OUT STD_LOGIC  -- indicates a write operation
);
END memory_controller;

ARCHITECTURE behavior OF memory_controller IS
	SIGNAL local_wren_a : STD_LOGIC;
	SIGNAL local_wren_b : STD_LOGIC;
   --SIGNAL last_wren_a : STD_LOGIC := '1'; -- Declare the signal here and initialize to '1'
    
	 -- RAM instantiation
    COMPONENT ram
        PORT(
            address_a     : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            address_b     : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            data_a        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            data_b        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            inclock       : IN STD_LOGIC;
            outclock      : IN STD_LOGIC;
            wren_a        : IN STD_LOGIC;
            wren_b        : IN STD_LOGIC;
            q_a           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            q_b           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    -- Address range check for the given example (10-bit address)
    CONSTANT MAX_ADDRESS : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1111111111";

BEGIN

		-- Check addresses and set local write enables
		PROCESS(inclock,reset)
		BEGIN
			 IF reset = '0' THEN
				local_wren_a <= '0';
				local_wren_b <= '0';
			 ELSIF rising_edge(inclock) THEN
				  -- Check for address_a validity
				  IF unsigned(address_a) > unsigned(MAX_ADDRESS) THEN
						local_wren_a <= '0';  -- Disable write to RAM for address_a
				  ELSE
						local_wren_a <= wren_a AND NOT write_protect; -- Use the global wren_a and the write_protect signal
				  END IF;

				  -- Check for address_b validity
				  IF unsigned(address_b) > unsigned(MAX_ADDRESS) THEN
						local_wren_b <= '0';  -- Disable write to RAM for address_b
				  ELSE
						local_wren_b <= wren_b AND NOT write_protect; -- Use the global wren_b and the write_protect signal
				  END IF;
			 END IF;
		END PROCESS;


    -- RAM instantiation in memory_controller architecture
	  ram_instance: ram
		 PORT MAP(
			  address_a  => address_a,
			  address_b  => address_b,
			  data_a     => data_a,
			  data_b     => data_b,
			  inclock    => inclock,
			  outclock   => outclock,
			  wren_a     => local_wren_a, 
			  wren_b     => local_wren_b, 
			  q_a        => q_a,
			  q_b        => q_b
		 );

     -- Process to handle read_activity based on wren_a and clock edge
		PROCESS(inclock)
		BEGIN
			IF rising_edge(inclock) THEN
				IF wren_a = '0'  THEN
					read_activity <= '1'; -- Rising edge of read request
				ELSIF wren_a = '1' THEN
					read_activity <= '0'; -- Falling edge of read request
				END IF;
			END IF;
		END PROCESS;
		
		write_activity <= '1' WHEN (wren_a = '1' OR wren_b = '1') ELSE '0';

	 

END behavior;



