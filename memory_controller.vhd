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
		 reset         : IN STD_LOGIC                      := '1'; -- TODO, ADD LOGIC TO THIS LATER
		 
		 mem_address_a : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
		 mem_address_b : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
		 mem_data_a    : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
		 mem_data_b    : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
		 mem_wren_a    : IN STD_LOGIC                      := '0';
		 mem_wren_b    : IN STD_LOGIC                      := '0';
		 mem_q_a       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
		 mem_q_b       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
		 
		 
		 mem_address_a2: IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0'); 
		 mem_address_b2: IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0'); 
		 mem_data_a2   : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0'); 
		 mem_data_b2   : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0'); 
		 mem_wren_a2   : IN STD_LOGIC                      := '0';             
		 mem_wren_b2   : IN STD_LOGIC                      := '0';             
		 mem_q_a2      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0'); 
		 mem_q_b2      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
		 
		 memory_ready  : OUT STD_LOGIC 							:= '0'
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

	SIGNAL read_request : STD_LOGIC := '0';
	SIGNAL read_counter : INTEGER := 0;
	SIGNAL read_delay   : INTEGER := 3; -- Number of cycles to wait for read
	SIGNAL prev_address_a, prev_address_b, prev_address_a2, prev_address_b2: STD_LOGIC_VECTOR (11 DOWNTO 0);
	 
BEGIN

	  -- RAM instantiation in memory_controller architecture
	  ram_instance: ram
		 PORT MAP(
		  inclock    => inclock,
		  outclock   => outclock,
		  
		  address_a  => mem_address_a,
		  address_b  => mem_address_b,
		  data_a     => mem_data_a,
		  data_b     => mem_data_b,
		  wren_a     => mem_wren_a, 
		  wren_b     => mem_wren_b, 
		  q_a        => mem_q_a,
		  q_b        => mem_q_b
		 );

    -- New RAM instantiation: the second Ram
    ram_instance2: ram
	  PORT MAP(
		 inclock    => inclock,
		 outclock   => outclock,
		 
		 address_a  => mem_address_a2,
		 address_b  => mem_address_b2,
		 data_a     => mem_data_a2,
		 data_b     => mem_data_b2,
		 wren_a     => mem_wren_a2,
		 wren_b     => mem_wren_b2,
		 q_a        => mem_q_a2,
		 q_b        => mem_q_b2
	  );

	process(inclock, reset)
	begin
		if reset = '0' then
			read_request <= '0';
			read_counter <= 0;
			memory_ready <= '0';
			prev_address_a <= (others => '0');
			prev_address_b <= (others => '0');
			prev_address_a2 <= (others => '0');
			prev_address_b2 <= (others => '0');
		elsif rising_edge(inclock) then
			-- Logic to detect a read request
			if (mem_address_a /= prev_address_a) or (mem_address_b /= prev_address_b) or
				(mem_address_a2 /= prev_address_a2) or (mem_address_b2 /= prev_address_b2) then
				read_request <= '1';
				read_counter <= 0; -- Reset counter on new read request
			end if;

			-- Handle read request
			if read_request = '1' then
				if read_counter < read_delay then
					read_counter <= read_counter + 1;
					memory_ready <= '0';
				else
					memory_ready <= '1';
					read_request <= '0'; -- Clear read request
					read_counter <= 0; -- Reset counter
				end if;
			else
				memory_ready <= '0';
			end if;

			-- Store previous addresses
			prev_address_a <= mem_address_a;
			prev_address_b <= mem_address_b;
			prev_address_a2 <= mem_address_a2;
			prev_address_b2 <= mem_address_b2;
		end if;
	end process;

	
END behavior;



