----------------------------------MEMORY_CONTROLLER---------------------------------------------
--- This module will handle read/write operations to/from the VRAM.
--- It will interface with the FPGA's on-chip memory.
------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;

--to do, add a reset function to the ram

ENTITY memory_controller IS
PORT(
    inclock       : IN STD_LOGIC;
    outclock      : IN STD_LOGIC;
    mem_address_a     : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    mem_address_b     : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    mem_data_a        : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    mem_data_b        : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    mem_wren_a        : IN STD_LOGIC                      := '0';
    mem_wren_b        : IN STD_LOGIC                      := '0';
    reset             : IN STD_LOGIC                      := '1'; 
    mem_q_a           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
    mem_q_b           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0')

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
			  address_a  => mem_address_a,
			  address_b  => mem_address_b,
			  data_a     => mem_data_a,
			  data_b     => mem_data_b,
			  inclock    => inclock,
			  outclock   => outclock,
			  wren_a     => mem_wren_a, 
			  wren_b     => mem_wren_b, 
			  q_a        => mem_q_a,
			  q_b        => mem_q_b
		 );






END behavior;



