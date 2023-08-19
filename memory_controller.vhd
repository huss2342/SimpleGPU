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
    inclock       : IN STD_LOGIC;
    outclock      : IN STD_LOGIC;
    address_a     : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    address_b     : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    data_a        : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    data_b        : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    wren_a        : IN STD_LOGIC                      := '0';
    wren_b        : IN STD_LOGIC                      := '0';
    reset         : IN STD_LOGIC                      := '1'; 
    q_a           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
    q_b           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0')

);
END memory_controller;

ARCHITECTURE behavior OF memory_controller IS
	 
	 -- RAM instantiation
    COMPONENT ram
        PORT(
            address_a     : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            address_b     : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
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
    CONSTANT MAX_ADDRESS : STD_LOGIC_VECTOR(11 DOWNTO 0) := "111111111111";

BEGIN
		    -- RAM instantiation in memory_controller architecture
	  ram_instance: ram
		 PORT MAP(
			  address_a  => address_a,
			  address_b  => address_b,
			  data_a     => data_a,
			  data_b     => data_b,
			  inclock    => inclock,
			  outclock   => outclock,
			  wren_a     => wren_a, 
			  wren_b     => wren_b, 
			  q_a        => q_a,
			  q_b        => q_b
		 );



		-- Address Handling and Read/Write Operations
		PROCESS(inclock, reset)
		BEGIN
			IF reset = '0' THEN
				local_wren_a <= '0';
				local_wren_b <= '0';
			ELSIF rising_edge(inclock) THEN
				-- Check for address_a validity
				IF unsigned(address_a) <= unsigned(MAX_ADDRESS) THEN
					local_wren_a <= wren_a;
				ELSE
					local_wren_a <= '0'; -- Disable write to RAM for address_a
				END IF;

				-- Check for address_b validity
				IF unsigned(address_b) <= unsigned(MAX_ADDRESS) THEN
					local_wren_b <= wren_b;
				ELSE
					local_wren_b <= '0'; -- Disable write to RAM for address_b
				END IF;
			END IF;
		END PROCESS;


END behavior;



