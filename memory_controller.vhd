------------------------------------------------------------------------------------------------
--- This module will handle read/write operations to/from the VRAM.
--- It will interface with the FPGA's on-chip memory.
------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

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
    -- Signal declarations for memory_controller
    
    SIGNAL local_wren_a : STD_LOGIC;
    SIGNAL local_wren_b : STD_LOGIC;

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

    -- Address range check logic
    PROCESS(inclock)
    BEGIN
        IF rising_edge(inclock) THEN
            IF address_a > MAX_ADDRESS OR address_b > MAX_ADDRESS THEN
                -- You can add error handling here, like setting an error flag or ignoring the request
            END IF;
        END IF;
    END PROCESS;

    -- Write protection logic
    local_wren_a <= '0' WHEN write_protect = '1' ELSE wren_a;
    local_wren_b <= '0' WHEN write_protect = '1' ELSE wren_b;

    -- Activity indicators
    read_activity <= '1' WHEN (wren_a = '0' OR wren_b = '0') ELSE '0';
    write_activity <= '1' WHEN (wren_a = '1' OR wren_b = '1') ELSE '0';

   

	 

END behavior;



