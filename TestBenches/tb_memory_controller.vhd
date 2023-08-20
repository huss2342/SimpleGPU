LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_memory_controller IS
END tb_memory_controller;

ARCHITECTURE behavior OF tb_memory_controller IS

   -- Signal declarations
	SIGNAL inclock        : STD_LOGIC := '0';
   SIGNAL outclock       : STD_LOGIC := '0';
   SIGNAL reset          : STD_LOGIC := '1';   

	SIGNAL address_a      : STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
   SIGNAL address_b      : STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
   SIGNAL data_a         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
   SIGNAL data_b         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
   SIGNAL wren_a         : STD_LOGIC := '0';
   SIGNAL wren_b         : STD_LOGIC := '0';
   SIGNAL q_a            : STD_LOGIC_VECTOR (15 DOWNTO 0);
   SIGNAL q_b            : STD_LOGIC_VECTOR (15 DOWNTO 0);
	
	SIGNAL address_a2      : STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
	SIGNAL address_b2      : STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
	SIGNAL data_a2         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
	SIGNAL data_b2         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
	SIGNAL wren_a2         : STD_LOGIC := '0';
	SIGNAL wren_b2         : STD_LOGIC := '0';
	SIGNAL q_a2            : STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL q_b2            : STD_LOGIC_VECTOR (15 DOWNTO 0);
	
	
	COMPONENT memory_controller 
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
		 mem_q_b2      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0')  
	);
	END COMPONENT; 
	
BEGIN

   inclock <= not inclock after 5 ns;
   outclock <= not outclock after 5 ns;


	-- Instantiating the memory_controller
	UUT: memory_controller
	PORT MAP(
		 inclock       => inclock,
		 outclock      => outclock,
		 reset         => reset,
		 
		 mem_address_a => address_a,
		 mem_address_b => address_b,
		 mem_data_a    => data_a,
		 mem_data_b    => data_b,
		 mem_wren_a    => wren_a,
		 mem_wren_b    => wren_b,
		 mem_q_a       => q_a,
		 mem_q_b       => q_b,
		 
		 mem_address_a2 => address_a2,
		 mem_address_b2 => address_b2,
		 mem_data_a2   => data_a2,
		 mem_data_b2   => data_b2,
		 mem_wren_a2   => wren_a2,
		 mem_wren_b2   => wren_b2,
		 mem_q_a2      => q_a2,
		 mem_q_b2      => q_b2
	);


	-- Test stimulus for address_a and address_b
	PROCESS
	BEGIN
		wait for 10 ns;

		 -- Write data to memory for address_a
		 address_a <= "000000000001";
		 data_a <= "0000000000111111";
		 wren_a <= '1'; wait for 10 ns;
		 wren_a <= '0'; wait for 10 ns;

		 -- Read data from memory for address_a
		 address_a <= "000000000001";
		 wait for 10 ns;

		 -- Write data to memory for address_b
		 address_b <= "000000000010";
		 data_b <= "1111111100000000";
		 wren_b <= '1'; wait for 10 ns;
		 wren_b <= '0'; wait for 10 ns;

		 -- Read data from memory for address_b
		 address_b <= "000000000010"; 
		 wait for 10 ns;

		 wait;
	END PROCESS;

	-- Test stimulus for address_a2 and address_b2
	PROCESS
	BEGIN
		wait for 10 ns;

		 -- Write data to memory for address_a2
		 address_a2 <= "000000000001";
		 data_a2 <= "0000000000010101";
		 wren_a2 <= '1'; wait for 10 ns;
		 wren_a2 <= '0'; wait for 10 ns;

		 -- Read data from memory for address_a2
		 address_a2 <= "000000000001";
		 wait for 10 ns;

		 -- Write data to memory for address_b2
		 address_b2 <= "000000000010";
		 data_b2 <= "0101010100000000";
		 wren_b2 <= '1'; wait for 10 ns;
		 wren_b2 <= '0'; wait for 10 ns;

		 -- Read data from memory for address_b2
		 address_b2 <= "000000000010";
		 wait for 10 ns;

		 wait;
	END PROCESS;



END behavior;