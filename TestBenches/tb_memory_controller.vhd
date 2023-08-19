LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_memory_controller IS
END tb_memory_controller;

ARCHITECTURE behavior OF tb_memory_controller IS

    -- Signal declarations
    SIGNAL address_a      : STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    SIGNAL address_b      : STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
    SIGNAL data_a         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL data_b         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL inclock        : STD_LOGIC := '0';
    SIGNAL outclock       : STD_LOGIC := '0';
    SIGNAL wren_a         : STD_LOGIC := '0';
    SIGNAL wren_b         : STD_LOGIC := '0';
    SIGNAL reset          : STD_LOGIC := '1';
    SIGNAL q_a            : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL q_b            : STD_LOGIC_VECTOR (15 DOWNTO 0);
	
	
	COMPONENT memory_controller 
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
	END COMPONENT; 
	
BEGIN

	
	
    -- Clock generation
    PROCESS
    BEGIN
        wait for 5 ns;
        inclock <= not inclock;
        outclock <= not outclock;
    END PROCESS;

    -- Instantiating the memory_controller
    UUT: memory_controller
    PORT MAP(
        address_a     => address_a,
        address_b     => address_b,
        data_a        => data_a,
        data_b        => data_b,
        inclock       => inclock,
        outclock      => outclock,
        wren_a        => wren_a,
        wren_b        => wren_b,
        reset         => reset,
        q_a           => q_a,
        q_b           => q_b
    );

		-- Test stimulus
		PROCESS
		BEGIN
			 -- Reset the memory_controller
			 reset <= '0'; wait for 10 ns;
			 reset <= '1'; wait for 10 ns;
			 
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

			 -- Additional test cases and assertions can be added here

			 -- End of simulation
			 wait;
		END PROCESS;


END behavior;